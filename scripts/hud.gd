class_name DayOneHUD
extends CanvasLayer

signal save_requested
signal load_requested
signal restart_requested
signal fullscreen_requested
signal exit_requested
signal dialogue_finished(dialogue_id: String)

@onready var dialogue: Control = $Screen/Dialogue
@onready var tab_menu: DayOneTabMenu = $Screen/TabMenu
@onready var pause_panel: PanelContainer = $Screen/Pause
@onready var choices: VBoxContainer = $Screen/Dialogue/Content/Choices
@onready var transcript: RichTextLabel = $Screen/Dialogue/Content/Text
@onready var next_button: Button = $Screen/Dialogue/Content/Actions/Next
@onready var blocker: ColorRect = $Screen/Blocker

var active_dialogue_id: String = ""
var has_choices: bool = false
var active_options: Array = []
var last_speaker: String = ""
var dialogue_transitioning: bool = false
var slide_progress: float = 1.0
var dialogue_tween: Tween

const HOVER_TEXT := Color(0.96, 0.93, 0.86)

func _ready() -> void:
	# Fade the painted world while the illuminated border stays still above it.
	$Screen.move_child($Screen/Fade, 0)
	# Keep the label's wheel scrolling while making its scrollbar invisible and inert.
	var scrollbar = transcript.get_v_scroll_bar()
	scrollbar.modulate.a = 0.0
	scrollbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrollbar.focus_mode = Control.FOCUS_NONE
	next_button.pressed.connect(advance_dialogue)
	$Screen/Pause/Content/Resume.pressed.connect(toggle_pause)
	$Screen/Pause/Content/Fullscreen.pressed.connect(func(): fullscreen_requested.emit())
	$Screen/Pause/Content/Save.pressed.connect(func(): save_requested.emit())
	$Screen/Pause/Content/Load.pressed.connect(func(): load_requested.emit())
	$Screen/Pause/Content/Restart.pressed.connect(_confirm_restart)
	$Screen/Pause/Content/Exit.pressed.connect(func(): exit_requested.emit())
	$RestartConfirm.confirmed.connect(func(): restart_requested.emit())
	_wire_pause_button_labels()

func set_fullscreen_state(fullscreen: bool) -> void:
	$Screen/Pause/Content/Fullscreen.get_node("Label").text = "切换为窗口 / F11" if fullscreen else "切换为全屏 / F11"


func _wire_pause_button_labels() -> void:
	# Pause buttons are option-strip textures; switch the label to a light ink
	# while hovering so it stays readable on the darkened selected strip.
	for name in ["Resume", "Fullscreen", "Save", "Load", "Restart", "Exit"]:
		var button: TextureButton = $Screen/Pause/Content.get_node(name)
		var label: Label = button.get_node("Label")
		button.mouse_entered.connect(_pause_label_hover.bind(label, true))
		button.mouse_exited.connect(_pause_label_hover.bind(label, false))


func _pause_label_hover(label: Label, entered: bool) -> void:
	if entered:
		label.add_theme_color_override("font_color", HOVER_TEXT)
	else:
		label.remove_theme_color_override("font_color")

func is_dialogue_open() -> bool:
	return not active_dialogue_id.is_empty()

func is_modal_open() -> bool:
	return dialogue.visible or tab_menu.is_open() or pause_panel.visible or $RestartConfirm.visible

func start_dialogue(id: String) -> void:
	if is_modal_open():
		return
	if not GameState.story.main_content_container.named_content.has(id):
		toast("找不到 Ink 段落：" + id)
		return
	active_dialogue_id = id
	last_speaker = ""
	transcript.clear()
	dialogue_transitioning = true
	_set_slide_progress(1.0)
	dialogue.show()
	_update_blocker()
	GameState.story.choose_path_string(id)
	_step_story()
	_slide_dialogue(true)

func _set_slide_progress(value: float) -> void:
	slide_progress = value
	# Right anchors keep the paper attached to the screen during fullscreen changes.
	dialogue.offset_left = -506.0 + value * 520.0
	dialogue.offset_right = -26.0 + value * 520.0

func _slide_dialogue(opening: bool) -> void:
	if dialogue_tween != null and dialogue_tween.is_valid():
		dialogue_tween.kill()
	dialogue_transitioning = true
	dialogue_tween = create_tween()
	dialogue_tween.tween_method(_set_slide_progress, slide_progress, 0.0 if opening else 1.0, 0.34 if opening else 0.24).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if opening else Tween.EASE_IN)
	await dialogue_tween.finished
	dialogue_transitioning = false
	if opening:
		_set_dialogue_input_enabled(true)
		_focus_dialogue_action()
	else:
		dialogue.hide()
		_update_blocker()

func wait_for_dialogue_settled() -> void:
	while dialogue_transitioning:
		await get_tree().process_frame

func _set_dialogue_input_enabled(enabled: bool) -> void:
	next_button.disabled = not enabled
	for button in choices.get_children():
		button.disabled = not enabled

func _focus_dialogue_action() -> void:
	if has_choices:
		choices.get_child(0).grab_focus()
	else:
		next_button.grab_focus()

func _read_tags(tags: Array) -> Dictionary:
	var result: Dictionary = {}
	for raw in tags:
		var tag = str(raw)
		var split = tag.find(":")
		if split >= 0:
			result[tag.left(split).strip_edges()] = tag.substr(split + 1).strip_edges()
	return result

func _step_story() -> void:
	_clear_choices()
	has_choices = false
	var story = GameState.story
	# One Ink paragraph per press. Tag-only lines do not require an extra click.
	while story.can_continue:
		var line = story.continue_story().strip_edges()
		var tags = _read_tags(story.current_tags)
		if tags.has("speaker"):
			last_speaker = tags["speaker"]
		if not line.is_empty():
			_append_entry(last_speaker, line, tags.get("tone", "speech"))
			break
	GameState.sync_from_ink()
	if not story.can_continue:
		active_options = story.current_choices
	has_choices = not active_options.is_empty()
	next_button.visible = not has_choices
	$Screen/Dialogue/Content/Actions.visible = not has_choices
	next_button.text = "继续" if story.can_continue else "结束"
	for index in range(active_options.size()):
		var option = active_options[index]
		var tags = _read_tags(option.tags if option.tags != null else [])
		var button = Button.new()
		button.text = str(index + 1) + ".  " + option.text
		if tags.has("action"):
			button.text += "  [" + tags["action"] + "]"
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 44
		button.pressed.connect(select_choice.bind(index))
		choices.add_child(button)
	_set_dialogue_input_enabled(not dialogue_transitioning)
	if not dialogue_transitioning:
		_focus_dialogue_action()

func _escape(text: String) -> String:
	return text.replace("[", "[lb]")

func _append_entry(speaker: String, text: String, tone: String = "speech") -> void:
	var body = "[font_size=16][color=#853c2b][b]" + _escape(speaker) + "[/b][/color][/font_size]\n"
	if tone in ["action", "description", "narration"]:
		body += "[color=#655b4d]" + _escape(text) + "[/color]"
	else:
		# Chinese quotation marks preserve the author's paragraph; prose outside
		# the quotes is rendered as action/narration without extra markup in Ink.
		var quoted = text.contains("“")
		var in_speech = false
		var segment = ""
		for character in text:
			if character == "“":
				if not segment.is_empty():
					body += "[color=#655b4d]" + _escape(segment) + "[/color]"
				segment = character
				in_speech = true
			elif character == "”" and in_speech:
				segment += character
				body += "[color=#322c24]" + _escape(segment) + "[/color]"
				segment = ""
				in_speech = false
			else:
				segment += character
		if not segment.is_empty():
			var color = "#322c24" if in_speech or not quoted else "#655b4d"
			body += "[color=" + color + "]" + _escape(segment) + "[/color]"
	transcript.append_text(body + "\n\n")

func _clear_choices() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	active_options = []

func select_choice(index: int) -> void:
	if dialogue_transitioning or not is_dialogue_open() or not has_choices or index < 0 or index >= active_options.size():
		return
	var option = active_options[index]
	var tags = _read_tags(option.tags if option.tags != null else [])
	_append_entry(tags.get("speaker", "金德日赫"), option.text, tags.get("tone", "speech"))
	GameState.story.choose_choice_index(index)
	_step_story()

func advance_dialogue() -> void:
	if dialogue_transitioning or not is_dialogue_open() or has_choices:
		return
	if GameState.story.can_continue:
		_step_story()
	else:
		_finish_dialogue()

func _finish_dialogue() -> void:
	if dialogue_transitioning or not is_dialogue_open():
		return
	var finished_id = active_dialogue_id
	active_dialogue_id = ""
	active_options = []
	has_choices = false
	_set_dialogue_input_enabled(false)
	await _slide_dialogue(false)
	dialogue_finished.emit(finished_id)

func _unhandled_key_input(event: InputEvent) -> void:
	if dialogue_transitioning or not is_dialogue_open() or not has_choices or not event is InputEventKey or not event.pressed or event.echo:
		return
	var index = int(event.physical_keycode) - KEY_1
	if index >= 0 and index < active_options.size():
		select_choice(index)
		get_viewport().set_input_as_handled()

func toggle_tab_menu() -> void:
	if dialogue.visible or pause_panel.visible or $RestartConfirm.visible:
		return
	if tab_menu.is_open():
		tab_menu.close()
	else:
		tab_menu.open()
	_update_blocker()

func toggle_pause() -> void:
	if dialogue.visible or $RestartConfirm.visible:
		return
	if tab_menu.is_open():
		tab_menu.close()
		_update_blocker()
		return
	pause_panel.visible = not pause_panel.visible
	_update_blocker()
	if pause_panel.visible:
		$Screen/Pause/Content/Resume.grab_focus()

func _update_blocker() -> void:
	blocker.visible = is_modal_open()
	blocker.color.a = 0.08 if dialogue.visible else 0.3

func close_panels() -> void:
	tab_menu.close()
	pause_panel.hide()
	_update_blocker()

func _confirm_restart() -> void:
	$RestartConfirm.popup_centered()

func toast(message: String) -> void:
	# Routine status belongs in the manually opened menu, not over the artwork.
	if pause_panel.visible:
		$Screen/Pause/Content/Note.text = message
	print(message)

func fade_to(alpha: float) -> void:
	$Screen/Fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween()
	tween.tween_property($Screen/Fade, "color:a", alpha, 0.28 if alpha > 0.5 else 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if is_zero_approx(alpha):
		$Screen/Fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
