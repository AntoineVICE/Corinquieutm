extends Node
## Ink owns narrative variables; flags/decisions below are read-only projections for the world UI.
signal changed

const SAVE_VERSION = 3
const SAVE_PATH = "user://story_day1_ink_v3.json"
const LOCATION_IDS = ["dorm", "courtyard", "garden", "cloister", "cloister_east", "cloister_north", "cloister_west", "kitchen", "refectory", "chapter_hall", "library", "infirmary"]
const LOCATION_WIDTHS = {"dorm": 1600, "courtyard": 1600, "garden": 3164, "cloister": 3273, "cloister_east": 3273, "cloister_north": 3273, "cloister_west": 3273, "kitchen": 2260, "refectory": 2254, "chapter_hall": 1918, "library": 2219, "infirmary": 2920}
const FLAG_IDS = ["dorm_wakeup_done", "courtyard_intro_seen", "oats_request_known", "oats_question_asked", "cloister_intro_seen"]
const OBSERVATION_IDS = ["bed", "desk", "cross", "chest"]
const CHOICE_VALUES = {
	"wake_response": ["spoken", "silent"],
	"courtyard_response": ["ask", "silent"],
	"oats_response": ["ask", "accept"]
}
const OBSERVATION_NAMES = {"bed": "床", "desk": "书桌", "cross": "十字架", "chest": "床尾的箱子"}

const STORY_PATH = "res://story/day1.json"
# This exact append-only build preserves all original knots and their saved paths.
# Future script changes must be verified before adding another compatibility pair.
const APPENDED_STORY_HASH = "b833b3169f002ed766b05877d6e71aefce59e6ea591e717d364cb4ab401578f9"
const PREVIOUS_STORY_HASH = "e1ec322d7a3d12195909c66306b4aa87239b38751bc38cca6e7e0ff5f993ff50"
var story: InkStory
var compiled_story: String = ""

var location_id: String = "dorm"
var player_position: Vector2 = Vector2(550, 654)
var facing: int = 1
var flags: Dictionary = {}
var observations: Array = []
var decisions: Dictionary = {}

func reset() -> void:
	location_id = "dorm"
	player_position = Vector2(550, 654)
	facing = 1
	story = make_story()
	sync_from_ink()

func has_flag(id: String) -> bool:
	return bool(flags.get(id, false))

func meets(required_flags: Array) -> bool:
	for id in required_flags:
		if not has_flag(str(id)):
			return false
	return true

func make_story() -> InkStory:
	if compiled_story.is_empty():
		compiled_story = FileAccess.get_file_as_string(STORY_PATH)
	var result = InkStory.new(compiled_story, get_node("/root/__InkRuntime"))
	result.on_error.connect(func(message, _type): push_error("Ink: " + str(message)))
	return result

func sync_from_ink() -> void:
	flags = {}
	observations = []
	decisions = {}
	for id in FLAG_IDS:
		if story.variables_state.get_variable(id) == true:
			flags[id] = true
	for id in OBSERVATION_IDS:
		if story.variables_state.get_variable("observed_" + id) == true:
			observations.append(id)
	for id in CHOICE_VALUES:
		var value = story.variables_state.get_variable(id)
		if value in CHOICE_VALUES[id]:
			decisions[id] = value
	changed.emit()

func objective() -> String:
	if not has_flag("dorm_wakeup_done"):
		return "钟声已响。扬正在叫你起床。"
	if has_flag("oats_request_known"):
		return "前往章会厅找扬；告诉他，修道院没有燕麦喂马了。"
	return "前往章会厅，与扬会合。"

func journal_text() -> String:
	var lines: Array[String] = ["[b]晨祷 · 当前安排[/b]\n" + objective()]
	if has_flag("oats_request_known"):
		lines.append("[b]菲利普的口信[/b]\n修道院没有燕麦喂马了。菲利普请你告诉扬，并担心奥尔德里希大人到来之前仍无法解决。")
	if not observations.is_empty():
		var names: Array[String] = []
		for id in observations:
			names.append(OBSERVATION_NAMES[id])
		lines.append("[b]宿舍 · 已查看[/b]\n" + "、".join(names))
	return "\n\n".join(lines)

func snapshot() -> Dictionary:
	var ink_state = story.state.to_json()
	return {"version": SAVE_VERSION, "day": 1, "location": location_id,
		"position": [player_position.x, player_position.y], "facing": facing,
		"flags": flags.duplicate(true), "observations": observations.duplicate(),
		"decisions": decisions.duplicate(true), "ink_state": ink_state,
		"ink_state_hash": ink_state.sha256_text(), "story_hash": compiled_story.sha256_text()}

func save_game(path: String = SAVE_PATH) -> Error:
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(snapshot(), "\t"))
	file.flush()
	var result = file.get_error()
	file.close()
	if result != OK:
		return result
	return DirAccess.rename_absolute(path + ".tmp", path)

func load_game(path: String = SAVE_PATH) -> Error:
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not _valid_save(parsed):
		return ERR_FILE_CORRUPT
	var candidate = make_story()
	candidate.state.load_json(parsed["ink_state"])
	if candidate.has_error:
		return ERR_FILE_CORRUPT
	story = candidate
	location_id = parsed["location"]
	player_position = Vector2(parsed["position"][0], parsed["position"][1])
	facing = int(parsed["facing"])
	sync_from_ink()
	return OK

func _valid_save(value: Variant) -> bool:
	if not value is Dictionary or value.get("version") != SAVE_VERSION or value.get("day") != 1:
		return false
	var state_text = value.get("ink_state")
	if not state_text is String or state_text.sha256_text() != value.get("ink_state_hash"):
		return false
	if compiled_story.is_empty():
		compiled_story = FileAccess.get_file_as_string(STORY_PATH)
	var current_hash = compiled_story.sha256_text()
	var saved_hash = value.get("story_hash")
	var compatible_append = current_hash == APPENDED_STORY_HASH and saved_hash == PREVIOUS_STORY_HASH
	if saved_hash != current_hash and not compatible_append:
		return false
	var ink_state = JSON.parse_string(state_text)
	if not ink_state is Dictionary or not ink_state.get("flows") is Dictionary or not ink_state.get("variablesState") is Dictionary:
		return false
	if not value.get("location") in LOCATION_IDS:
		return false
	var pos = value.get("position")
	if not pos is Array or pos.size() != 2:
		return false
	for number in pos:
		if not (number is int or number is float) or not is_finite(float(number)):
			return false
	if pos[0] < 60 or pos[0] > LOCATION_WIDTHS[value["location"]] - 60 or pos[1] < 0 or pos[1] > 720:
		return false
	var direction = value.get("facing")
	if not (direction is int or direction is float) or (direction != -1 and direction != 1):
		return false
	if not value.get("flags") is Dictionary or not value.get("observations") is Array or not value.get("decisions") is Dictionary:
		return false
	for id in value["flags"]:
		if id not in FLAG_IDS or not value["flags"][id] is bool:
			return false
	var seen: Array = []
	for id in value["observations"]:
		if id not in OBSERVATION_IDS or id in seen:
			return false
		seen.append(id)
	for key in value["decisions"]:
		if not CHOICE_VALUES.has(key) or value["decisions"][key] not in CHOICE_VALUES[key]:
			return false
	var saved_flags: Dictionary = value["flags"]
	if value["location"] != "dorm" and not saved_flags.get("dorm_wakeup_done", false):
		return false
	if saved_flags.get("dorm_wakeup_done", false) and not value["decisions"].has("wake_response"):
		return false
	if saved_flags.get("oats_request_known", false) and not saved_flags.get("courtyard_intro_seen", false):
		return false
	if saved_flags.get("oats_question_asked", false) and not saved_flags.get("oats_request_known", false):
		return false
	return true
