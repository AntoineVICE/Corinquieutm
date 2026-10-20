@tool
class_name DayOneLocation
extends Node2D

@export var display_name: String = "地点"
@export var background_texture: Texture2D
@export var foreground_texture: Texture2D
@export var music: AudioStream
@export var ambience: AudioStream
@export var camera_right: int = 1600
@export var walk_y: float = 570.0
@export var walk_left: float = 60.0
@export var walk_right: float = 1540.0
## Empty polygon keeps the original horizontal walk line.
@export var walk_polygon: PackedVector2Array = PackedVector2Array()
@export var walk_obstacles: Array[PackedVector2Array] = []
@export_range(0.1, 2.0) var player_scale: float = 1.0

func _ready() -> void:
	$Background.texture = background_texture
	$Foreground.texture = foreground_texture
	$Placeholder.visible = background_texture == null

func spawn_position(id: String) -> Vector2:
	var point = get_node_or_null("Spawns/" + id)
	if point is Marker2D:
		return point.global_position
	push_warning("Missing spawn: " + id + "; using Start")
	return $Spawns/Start.global_position

func spawn_facing(id: String, fallback: int = 1) -> int:
	var point = get_node_or_null("Spawns/" + id)
	return int(point.get_meta("facing", fallback)) if point != null else fallback
