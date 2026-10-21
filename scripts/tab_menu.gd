class_name DayOneTabMenu
extends Control
## Full-screen book menu: task log and map tabs tucked into the left edge.

signal closed

const TAB_TEX := preload("res://assets/ui/book_tab.png")
const TAB_TEX_SELECTED := preload("res://assets/ui/book_tab_selected.png")
const MONASTERY_MAP := preload("res://assets/ui/maps/monastery_map.png")
const VILLAGE_MAP := preload("res://assets/ui/maps/village_map.png")
const BOUNCE_PIXELS := 7.0
const BOUNCE_TIME := 0.18
@onready var tab_tasks: TextureRect = $Tabs/Tasks
@onready var tab_map: TextureRect = $Tabs/Map
@onready var tasks_page: Control = $Pages/Tasks
@onready var map_page: Control = $Pages/Map
@onready var log_text: RichTextLabel = $Pages/Tasks/Clip/Bounce/Text
@onready var bounce: Control = $Pages/Tasks/Clip/Bounce
@onready var fade_top: TextureRect = $Pages/Tasks/FadeTop
@onready var fade_bottom: TextureRect = $Pages/Tasks/FadeBottom
@onready var arrow: TextureRect = $Pages/Tasks/Arrow
@onready var detail: RichTextLabel = $Pages/Tasks/Detail
@onready var map_info: RichTextLabel = $Pages/Map/Info
@onready var map_image: TextureRect = $Pages/Map/Frame/MapImage
@onready var monastery_button: Button = $Pages/Map/MonasteryButton
@onready var village_button: Button = $Pages/Map/VillageButton

var active_tab: int = 0
var hovered_tab: int = -1
var bounce_tween: Tween
var _atlas_normal: AtlasTexture
var _atlas_selected: AtlasTexture


func _ready() -> void:
	visible = false
	_atlas_normal = _make_tab_atlas(TAB_TEX)
	_atlas_selected = _make_tab_atlas(TAB_TEX_SELECTED)
	tab_tasks.mouse_entered.connect(_on_tab_hover.bind(0, true))
	tab_tasks.mouse_exited.connect(_on_tab_hover.bind(0, false))
	tab_map.mouse_entered.connect(_on_tab_hover.bind(1, true))
	tab_map.mouse_exited.connect(_on_tab_hover.bind(1, false))
	tab_tasks.gui_input.connect(_on_tab_input.bind(0))
	tab_map.gui_input.connect(_on_tab_input.bind(1))
	monastery_button.pressed.connect(_select_map.bind(0))
	village_button.pressed.connect(_select_map.bind(1))
	log_text.get_v_scroll_bar().changed.connect(_refresh_scroll_hints)
	var scrollbar := log_text.get_v_scroll_bar()
	scrollbar.modulate.a = 0.0
	scrollbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameState.changed.connect(_on_state_changed)
	_apply_tab_art()
	_select_map(0)
	_select_tab(0)


func _make_tab_atlas(source: Texture2D) -> AtlasTexture:
	# The ribbon art is designed as one long strip; each tab uses its decorated left half.
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = Rect2(0, 0, source.get_width() / 2.0, source.get_height())
	return atlas


func is_open() -> bool:
	return visible


func open() -> void:
	if visible:
		return
	visible = true
	_refresh_content()
	_select_map(1 if GameState.location_id == "town" else 0)
	_refresh_scroll_hints()
	_apply_tab_art()


func close() -> void:
	if not visible:
		return
	visible = false
	_reset_bounce()
	closed.emit()


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _on_state_changed() -> void:
	if visible:
		_refresh_content()


func _refresh_content() -> void:
	if not is_instance_valid(log_text):
		return
	log_text.text = GameState.journal_text()
	detail.text = _detail_text()
	map_info.text = _map_text()
	_refresh_scroll_hints.call_deferred()


func _detail_text() -> String:
	var lines: Array[String] = []
	lines.append("[font_size=20][color=#655b4d]当前目标[/color][/font_size]")
	lines.append(GameState.objective())
	var observed := ""
	if not GameState.observations.is_empty():
		var names: Array[String] = []
		for id in GameState.observations:
			names.append(GameState.OBSERVATION_NAMES.get(id, str(id)))
		observed = "、".join(names)
	if not observed.is_empty():
		lines.append("")
		lines.append("[font_size=20][color=#655b4d]已查看[/color][/font_size]")
		lines.append(observed)
	return "\n".join(lines)


func _map_text() -> String:
	return "[font_size=20][color=#655b4d]当前所在[/color][/font_size]\n" + GameState.location_name() + "\n\n[font_size=18][color=#655b4d]地图册[/color][/font_size]\n在右页选择修道院或马尔欣村地图。"


func _select_map(index: int) -> void:
	var show_village := index == 1
	map_image.texture = VILLAGE_MAP if show_village else MONASTERY_MAP
	monastery_button.disabled = not show_village
	village_button.disabled = show_village


func _select_tab(index: int) -> void:
	active_tab = clampi(index, 0, 1)
	tasks_page.visible = active_tab == 0
	map_page.visible = active_tab == 1
	_apply_tab_art()


func _apply_tab_art() -> void:
	if _atlas_normal == null:
		return
	tab_tasks.texture = _atlas_selected if (active_tab == 0 or hovered_tab == 0) else _atlas_normal
	tab_map.texture = _atlas_selected if (active_tab == 1 or hovered_tab == 1) else _atlas_normal


func _on_tab_hover(index: int, entered: bool) -> void:
	hovered_tab = index if entered else -1
	_apply_tab_art()


func _on_tab_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_tab(index)
		accept_event()


func _refresh_scroll_hints() -> void:
	if not is_instance_valid(log_text):
		return
	var bar := log_text.get_v_scroll_bar()
	var max_value: float = maxf(0.0, bar.max_value - bar.page)
	var at_top := bar.value <= 0.5
	var at_bottom := bar.value >= max_value - 0.5
	var scrollable := max_value > 0.5
	fade_top.visible = scrollable and not at_top
	fade_bottom.visible = scrollable and not at_bottom
	arrow.visible = scrollable and not at_bottom


func _input(event: InputEvent) -> void:
	# Wheel at either end nudges the page and springs back; normal scrolling is
	# left to the RichTextLabel itself.
	if not visible or active_tab != 0:
		return
	if not event is InputEventMouseButton or not event.pressed:
		return
	if event.button_index != MOUSE_BUTTON_WHEEL_UP and event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
		return
	var bar := log_text.get_v_scroll_bar()
	var max_value: float = maxf(0.0, bar.max_value - bar.page)
	if max_value <= 0.5:
		return
	var at_top := bar.value <= 0.5
	var at_bottom := bar.value >= max_value - 0.5
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and at_top:
		_bounce(1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and at_bottom:
		_bounce(-1.0)


func _bounce(direction: float) -> void:
	if is_instance_valid(bounce_tween) and bounce_tween.is_valid():
		bounce_tween.kill()
	bounce.position.y = direction * BOUNCE_PIXELS
	bounce_tween = create_tween()
	bounce_tween.tween_property(bounce, "position:y", 0.0, BOUNCE_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _reset_bounce() -> void:
	if is_instance_valid(bounce_tween) and bounce_tween.is_valid():
		bounce_tween.kill()
	bounce.position.y = 0.0
