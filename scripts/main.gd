extends Node2D
## Persistent shell: replace only LocationSlot; keep player, HUD and audio alive.

const LOCATIONS = {
	"dorm": "res://scenes/locations/dorm.tscn",
	"courtyard": "res://scenes/locations/courtyard.tscn",
	"garden": "res://scenes/locations/garden.tscn",
	"cloister": "res://scenes/locations/cloister.tscn",
	"cloister_east": "res://scenes/locations/cloister_east.tscn",
	"cloister_north": "res://scenes/locations/cloister_north.tscn",
	"cloister_west": "res://scenes/locations/cloister_west.tscn",
	"kitchen": "res://scenes/locations/kitchen.tscn",
	"refectory": "res://scenes/locations/refectory.tscn",
	"chapter_hall": "res://scenes/locations/chapter_hall.tscn",
	"library": "res://scenes/locations/library.tscn",
	"infirmary": "res://scenes/locations/infirmary.tscn"
}

@export var auto_save_enabled: bool = true
@export var startup_restore: bool = true

@onready var player: DayOnePlayer = $World/Player
@onready var hud: DayOneHUD = $HUD
@onready var location_slot: Node2D = $World/LocationSlot

var current_location: DayOneLocation
var target: DayOneInteractable
var transitioning: bool = false
var initialized: bool = false
var windowed_size: Vector2i = Vector2i(1280, 720)

func _ready() -> void:
	_setup_input()
	get_window().min_size = Vector2i(960, 540)
	hud.fullscreen_requested.connect(toggle_fullscreen)
	get_window().size_changed.connect(_refresh_display_mode)
	_refresh_display_mode()
	hud.save_requested.connect(_manual_save)
	hud.load_requested.connect(_manual_load)
	hud.restart_requested.connect(_restart)
	hud.dialogue_finished.connect(_after_dialogue)
	var restored = false
	var bad_save = false
	if startup_restore and FileAccess.file_exists(GameState.SAVE_PATH):
		restored = GameState.load_game() == OK
		bad_save = not restored
		if bad_save:
			auto_save_enabled = false
	if not restored:
		GameState.reset()
	await change_location(GameState.location_id, "Start", restored, false)
	initialized = true
	if bad_save:
		hud.toast("存档无法读取，已保留原文件并暂停自动保存。可从菜单重新开始。")
	elif not hud.is_dialogue_open():
		hud.toast("已继续上次进度" if restored else "A / D 移动，靠近目标后按 E")

func _setup_input() -> void:
	var bindings = {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"interact": [KEY_E], "journal": [KEY_J], "menu": [KEY_TAB], "pause_game": [KEY_ESCAPE],
		"advance_dialogue": [KEY_SPACE, KEY_ENTER],
		"toggle_fullscreen": [KEY_F11]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event = InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)

	var alt_enter = InputEventKey.new()
	alt_enter.physical_keycode = KEY_ENTER
	alt_enter.alt_pressed = true
	if not InputMap.action_has_event("toggle_fullscreen", alt_enter):
		InputMap.action_add_event("toggle_fullscreen", alt_enter)

func _input(event: InputEvent) -> void:
	# Catch before GUI input so Alt+Enter never activates a focused dialogue choice.
	if event.is_action_pressed("toggle_fullscreen") and not event.is_echo():
		toggle_fullscreen()
		get_viewport().set_input_as_handled()

func toggle_fullscreen() -> void:
	var window = get_window()
	if window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]:
		window.mode = Window.MODE_WINDOWED
		var usable = DisplayServer.screen_get_usable_rect(window.current_screen)
		var available = usable.size - Vector2i(64, 96)
		window.size = Vector2i(mini(windowed_size.x, available.x), mini(windowed_size.y, available.y))
		window.position = usable.position + (usable.size - window.size) / 2
	else:
		if window.mode == Window.MODE_WINDOWED:
			windowed_size = window.size
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	_refresh_display_mode()

func _refresh_display_mode() -> void:
	hud.set_fullscreen_state(get_window().mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN])

func _physics_process(_delta: float) -> void:
	player.control_enabled = initialized and not transitioning and not hud.is_modal_open()
	if is_instance_valid(target):
		target.set_focused(false)
	target = null
	for item in get_tree().get_nodes_in_group("interactables"):
		if item is DayOneInteractable:
			item.set_prompt_enabled(player.control_enabled)
			item.set_reachable(player.control_enabled and item.is_available() and player.global_position.distance_to(item.global_position) <= item.interaction_distance)
	if player.control_enabled:
		var nearest = INF
		for candidate in get_tree().get_nodes_in_group("interactables"):
			if not candidate is DayOneInteractable or not candidate.is_available():
				continue
			var distance = player.global_position.distance_to(candidate.global_position)
			if distance <= candidate.interaction_distance and distance < nearest:
				target = candidate
				nearest = distance
	if target != null:
		target.set_focused(true)

func _unhandled_input(event: InputEvent) -> void:
	if not initialized or transitioning or event.is_echo():
		return
	if event.is_action_pressed("pause_game"):
		hud.toggle_pause()
	elif event.is_action_pressed("menu") or event.is_action_pressed("journal"):
		hud.toggle_tab_menu()
	elif hud.is_dialogue_open():
		if event.is_action_pressed("interact") or event.is_action_pressed("advance_dialogue"):
			hud.advance_dialogue()
	elif event.is_action_pressed("interact") and not hud.is_modal_open():
		activate_target()
	else:
		return
	get_viewport().set_input_as_handled()

func activate_target() -> void:
	_activate_interactable(target)

func _activate_interactable(item: DayOneInteractable) -> void:
	if transitioning or hud.is_modal_open() or not is_instance_valid(item):
		return
	# Recheck on activation so stale UI focus cannot bypass conditions.
	if not item.is_available() or player.global_position.distance_to(item.global_position) > item.interaction_distance:
		return
	player.control_enabled = false
	player.velocity = Vector2.ZERO
	if item.kind == DayOneInteractable.Kind.EXIT:
		change_location(item.target_location, item.target_spawn)
	else:
		hud.start_dialogue(item.dialogue_id)

func change_location(id: String, spawn: String = "Start", restore_position: bool = false, persist: bool = true) -> void:
	if transitioning or not LOCATIONS.has(id):
		return
	transitioning = true
	player.control_enabled = false
	player.velocity = Vector2.ZERO
	if is_instance_valid(target):
		target.set_focused(false)
	target = null
	if is_instance_valid(current_location):
		await hud.fade_to(1.0)
	# Present a fully covered frame before loading or replacing the panorama.
	await RenderingServer.frame_post_draw
	if is_instance_valid(current_location):
		location_slot.remove_child(current_location)
		current_location.queue_free()
	# Load only the current panorama instead of retaining every large PNG at startup.
	current_location = load(LOCATIONS[id]).instantiate()
	location_slot.add_child(current_location)
	for item in get_tree().get_nodes_in_group("interactables"):
		if item is DayOneInteractable:
			item.interaction_requested.connect(_activate_interactable)
	player.configure_location(current_location)
	var spawn_position = GameState.player_position if restore_position else current_location.spawn_position(spawn)
	# Keep existing saves usable when a room's art changes its walkable layout.
	player.global_position = player.constrain_position(spawn_position)
	player.facing = GameState.facing if restore_position else current_location.spawn_facing(spawn, 1 if id == "courtyard" else -1)
	if id == "dorm" and spawn == "Start" and not restore_position:
		player.facing = 1
	player._update_art(false)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.position.x = 0.0
	# A migrated save may enter from the far end; frame both speakers without moving the player.
	if id == "cloister" and not GameState.has_flag("cloister_intro_seen"):
		camera.position.x = current_location.get_node("IntroCamera").global_position.x - player.global_position.x
	camera.limit_right = current_location.camera_right
	camera.reset_smoothing()
	camera.force_update_scroll()
	GameState.location_id = id
	_sync_position()
	_play_audio($Audio/Music, current_location.music)
	_play_audio($Audio/Ambience, current_location.ambience)
	# Settle the foot position, camera and imported textures while still covered.
	await get_tree().physics_frame
	await get_tree().physics_frame
	camera.reset_smoothing()
	camera.force_update_scroll()
	await RenderingServer.frame_post_draw
	await hud.fade_to(0.0)
	transitioning = false
	if persist:
		_auto_save()
	_run_entry_dialogue()

func _run_entry_dialogue() -> void:
	if GameState.location_id == "dorm" and not GameState.has_flag("dorm_wakeup_done"):
		hud.start_dialogue("dorm_wakeup")
	elif GameState.location_id == "courtyard" and not GameState.has_flag("courtyard_intro_seen"):
		hud.start_dialogue("courtyard_intro")
	elif GameState.location_id == "cloister" and not GameState.has_flag("cloister_intro_seen"):
		hud.start_dialogue("cloister_south_intro")

func _play_audio(channel: AudioStreamPlayer, stream: AudioStream) -> void:
	# Assign the same stream to both places to preserve music across the doorway.
	if channel.stream == stream:
		return
	channel.stop()
	channel.stream = stream
	if stream != null:
		channel.play()

func _sync_position() -> void:
	GameState.player_position = player.global_position
	GameState.facing = player.facing

func _auto_save() -> void:
	if not auto_save_enabled or hud.is_dialogue_open():
		return
	_sync_position()
	if GameState.save_game() != OK:
		hud.toast("自动保存失败，请从菜单重试手动保存。")

func _after_dialogue(id: String) -> void:
	if id == "cloister_south_intro":
		player.get_node("Camera2D").position.x = 0.0
	_auto_save()

func _manual_save() -> void:
	if transitioning or hud.is_dialogue_open():
		return
	_sync_position()
	var result = GameState.save_game()
	hud.toast("进度已保存" if result == OK else "保存失败：" + error_string(result))

func _manual_load() -> void:
	if transitioning or hud.is_dialogue_open():
		return
	var result = GameState.load_game()
	if result != OK:
		hud.toast("尚无存档" if result == ERR_FILE_NOT_FOUND else "存档无法读取，当前进度未改变")
		return
	hud.close_panels()
	await change_location(GameState.location_id, "Start", true, false)
	if not hud.is_dialogue_open():
		hud.toast("已读取存档")

func _restart() -> void:
	if transitioning:
		return
	hud.close_panels()
	GameState.reset()
	auto_save_enabled = true
	await change_location("dorm", "Start", false, true)
	# The wake-up conversation now owns focus; avoid overlaying it with a toast.
