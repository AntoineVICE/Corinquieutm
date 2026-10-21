extends Control
## Title screen: logo on the right, a random portrait on the left, four options.

const PORTRAIT_DIR := "res://assets/characters/portraits"
const PORTRAIT_BOXES := "res://assets/characters/portraits/portrait_boxes.json"
const MAIN_SCENE := "res://scenes/main.tscn"

const PORTRAIT_HEIGHT := 567.0
const PORTRAIT_CENTER_X := 313.0
const PORTRAIT_BOTTOM := 670.0
const HOVER_TEXT := Color(0.96, 0.93, 0.86)

const CREDITS: Array[String] = []

@onready var portrait: TextureRect = $PortraitArea/Portrait
@onready var credits_panel: Control = $CreditsPanel
@onready var credits_text: Label = $CreditsPanel/Panel/Content/Lines
@onready var new_game: TextureButton = $Buttons/NewGame
@onready var continue_game: TextureButton = $Buttons/Continue
@onready var credits_button: TextureButton = $Buttons/Credits
@onready var quit_button: TextureButton = $Buttons/Quit
@onready var saved_at: Label = $Buttons/SavedAt

var boxes: Dictionary = {}
var pool: Array[String] = []
var current: String = ""
var bounce_tween: Tween


func _ready() -> void:
	_load_portraits()
	_wire_button(new_game, _start_new_game)
	_wire_button(continue_game, _continue_game)
	_wire_button(credits_button, _open_credits)
	_wire_button(quit_button, func() -> void: get_tree().quit())
	$CreditsPanel/Panel/Content/Close.pressed.connect(_close_credits)
	$PortraitArea.gui_input.connect(_on_portrait_area_gui_input)
	_refresh_continue()
	credits_text.text = "\n".join(CREDITS)
	_set_random_portrait()


func _wire_button(button: TextureButton, action: Callable) -> void:
	button.pressed.connect(action)
	var label: Label = button.get_node("Label")
	button.mouse_entered.connect(func() -> void: label.add_theme_color_override("font_color", HOVER_TEXT))
	button.mouse_exited.connect(func() -> void: label.remove_theme_color_override("font_color"))


func _load_portraits() -> void:
	if FileAccess.file_exists(PORTRAIT_BOXES):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PORTRAIT_BOXES))
		if parsed is Dictionary:
			boxes = parsed
	for name in DirAccess.get_files_at(PORTRAIT_DIR):
		if name.to_lower().ends_with(".png"):
			pool.append(name)
	pool.sort()


func _refresh_continue() -> void:
	var has_save := FileAccess.file_exists(GameState.SAVE_PATH)
	continue_game.disabled = not has_save
	continue_game.modulate.a = 1.0 if has_save else 0.4
	saved_at.visible = has_save
	if has_save:
		saved_at.text = _format_saved_at(FileAccess.get_modified_time(GameState.SAVE_PATH))


func _format_saved_at(unix_time: int) -> String:
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0))
	var date := Time.get_datetime_dict_from_unix_time(unix_time + bias * 60)
	return "上次存档 %d月%d日 %02d:%02d" % [date["month"], date["day"], date["hour"], date["minute"]]


func _set_random_portrait() -> void:
	if pool.is_empty():
		return
	var pick := current
	var guard := 0
	while pick == current and pool.size() > 1 and guard < 32:
		pick = pool[randi() % pool.size()]
		guard += 1
	current = pick
	_apply_portrait(pick)


func _apply_portrait(name: String) -> void:
	var texture: Texture2D = load(PORTRAIT_DIR + "/" + name)
	if texture == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, texture.get_width(), texture.get_height())
	if boxes.has(name):
		var b: Array = boxes[name]
		atlas.region = Rect2(b[0], b[1], b[2] - b[0], b[3] - b[1])
	portrait.texture = atlas
	var region := atlas.region.size
	var factor := PORTRAIT_HEIGHT / maxf(1.0, region.y)
	var size := Vector2(region.x * factor, PORTRAIT_HEIGHT)
	portrait.size = size
	portrait.position = Vector2(PORTRAIT_CENTER_X - size.x * 0.5, PORTRAIT_BOTTOM - PORTRAIT_HEIGHT)
	portrait.pivot_offset = Vector2(size.x * 0.5, size.y)


func _on_portrait_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_bounce_and_swap()
		accept_event()


func _bounce_and_swap() -> void:
	if is_instance_valid(bounce_tween) and bounce_tween.is_valid():
		bounce_tween.kill()
	portrait.scale = Vector2.ONE
	bounce_tween = create_tween()
	bounce_tween.tween_property(portrait, "scale", Vector2(1.07, 1.07), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_callback(_set_random_portrait)
	bounce_tween.tween_property(portrait, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _start_new_game() -> void:
	if FileAccess.file_exists(GameState.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(GameState.SAVE_PATH))
	GameState.reset()
	get_tree().change_scene_to_file(MAIN_SCENE)


func _continue_game() -> void:
	if GameState.load_game() != OK:
		_refresh_continue()
		return
	get_tree().change_scene_to_file(MAIN_SCENE)


func _open_credits() -> void:
	credits_panel.visible = true


func _close_credits() -> void:
	credits_panel.visible = false
