@tool
class_name DayOneInteractable
extends Area2D

signal interaction_requested(item: DayOneInteractable)

enum Kind { DIALOGUE, EXIT }

@export var interaction_id: String = ""
@export var display_name: String = "交互点"
@export var kind: Kind = Kind.DIALOGUE
@export var dialogue_id: String = ""
@export_enum("dorm", "courtyard", "garden", "cloister", "cloister_east", "cloister_north", "cloister_west", "kitchen", "refectory", "chapter_hall", "library", "infirmary") var target_location: String = "dorm"
@export var target_spawn: String = "Start"
@export var interaction_distance: float = 100.0
@export var portrait_texture: Texture2D
## Original-image coordinates: visible body bounds and optional display clipping.
@export var portrait_bounds: Rect2
@export var portrait_outline: PackedVector2Array = PackedVector2Array()
@export var portrait_height: float = 343.0
@export var placeholder_person: bool = false
## Only visible people block the ground; object icons and hidden people do not.
@export var blocks_walking: bool = true
@export var foot_radius: Vector2 = Vector2(26, 10)
## Optional original-image foot anchor for asymmetric poses or carried objects.
@export var portrait_foot_anchor: Vector2 = Vector2(-1, -1)
@export var required_flags: Array[String] = []
@export var hidden_after_flag: String = ""
@export var interaction_enabled: bool = true
@export var marker_offset: Vector2 = Vector2(0, -170)

var focused: bool = false
var prompt_enabled: bool = true
var reachable: bool = false
var hovered: bool = false
var portrait_visual: Node2D

func _ready() -> void:
	$Marker.position = marker_offset
	$Marker.z_as_relative = false
	$Marker.z_index = WorldDepth.MARKER_Z
	$Art.texture = portrait_texture
	_fit_portrait()
	if not Engine.is_editor_hint():
		$Marker/Hitbox.pressed.connect(_request_interaction)
		$Marker/Hitbox.mouse_entered.connect(func(): hovered = true; _update_marker())
		$Marker/Hitbox.mouse_exited.connect(func(): hovered = false; _update_marker())
		add_to_group("interactables")
		GameState.changed.connect(_refresh_visibility)
		_refresh_visibility()
	_update_marker()
	queue_redraw()

func _fit_portrait() -> void:
	if portrait_texture == null:
		return
	var bounds = portrait_bounds
	if not bounds.has_area():
		bounds = Rect2(portrait_texture.get_image().get_used_rect())
	var room = get_parent()
	while room != null and not room is DayOneLocation:
		room = room.get_parent()
	var location_scale: float = room.player_scale if room is DayOneLocation else 1.0
	var fit = portrait_height * location_scale / bounds.size.y
	var foot_anchor = Vector2(bounds.get_center().x, bounds.end.y)
	if portrait_foot_anchor.x >= 0 and portrait_foot_anchor.y >= 0:
		foot_anchor = portrait_foot_anchor
	if not portrait_outline.is_empty():
		$Art.hide()
		var cutout = Polygon2D.new()
		cutout.name = "PortraitCutout"
		cutout.texture = portrait_texture
		cutout.polygon = portrait_outline
		cutout.uv = portrait_outline
		cutout.antialiased = true
		add_child(cutout)
		portrait_visual = cutout
	else:
		$Art.centered = false
		portrait_visual = $Art
	portrait_visual.position = -foot_anchor * fit
	portrait_visual.scale = Vector2.ONE * fit
	WorldDepth.at_feet(portrait_visual, global_position.y)
	portrait_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# The small hand sits next to the shoulder, without covering the face.
	if placeholder_person:
		$Marker.position = Vector2(bounds.size.x * fit * 0.5 + 22, -portrait_height * location_scale * 0.62)

func _process(_delta: float) -> void:
	if placeholder_person:
		WorldDepth.at_feet(self, global_position.y)
	if is_instance_valid(portrait_visual):
		WorldDepth.at_feet(portrait_visual, global_position.y)

func is_available() -> bool:
	return interaction_enabled and visible and GameState.meets(required_flags)

func _refresh_visibility() -> void:
	visible = hidden_after_flag.is_empty() or not GameState.has_flag(hidden_after_flag)
	_update_marker()

func set_focused(value: bool) -> void:
	if focused == value:
		return
	focused = value
	_update_marker()

func set_prompt_enabled(value: bool) -> void:
	if prompt_enabled == value:
		return
	prompt_enabled = value
	_update_marker()

func set_reachable(value: bool) -> void:
	if reachable == value:
		return
	reachable = value
	_update_marker()

func _request_interaction() -> void:
	if prompt_enabled and reachable and is_available():
		interaction_requested.emit(self)

func _update_marker() -> void:
	if is_node_ready():
		$Marker.visible = interaction_enabled and prompt_enabled and (Engine.is_editor_hint() or is_available())
		$Marker.modulate = Color(1, 1, 1, 1.0 if reachable else 0.7)
		if hovered and reachable:
			$Marker.modulate = Color(1.15, 1.10, 1.0, 1)
		$Marker/Hitbox.disabled = not reachable or not prompt_enabled

func _draw() -> void:
	if placeholder_person and portrait_texture == null:
		draw_circle(Vector2(0,-111),16,Color("ceb591"))
		draw_colored_polygon(PackedVector2Array([Vector2(-20,-90),Vector2(18,-90),Vector2(29,-10),Vector2(-28,-10)]),Color("8a7863"))
		draw_line(Vector2(-12,-10),Vector2(-12,0),Color("3d3a32"),8)
		draw_line(Vector2(12,-10),Vector2(12,0),Color("3d3a32"),8)
