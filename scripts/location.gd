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
## Collected from editable Ground/ polygons, in location-local design coordinates.
## No Walkable region keeps the original horizontal walk line.
var walk_polygon: PackedVector2Array = PackedVector2Array()
var walk_obstacles: Array[PackedVector2Array] = []
@export_range(0.1, 2.0) var player_scale: float = 1.0

func _ready() -> void:
	$Background.texture = background_texture
	$Foreground.texture = foreground_texture
	$Foreground.z_as_relative = false
	$Foreground.z_index = WorldDepth.FOREGROUND_Z
	$Placeholder.visible = background_texture == null
	collect_ground_geometry()

func create_walk_surface(foot_radius: Vector2) -> WalkSurface:
	collect_ground_geometry()
	return WalkSurface.new(self, foot_radius)

func collect_ground_geometry() -> void:
	walk_polygon = PackedVector2Array()
	walk_obstacles.clear()
	var ground = get_node_or_null("Ground")
	if ground == null:
		return
	for region in ground.find_children("*", "Polygon2D"):
		if not region is GroundRegion:
			continue
		var points = PackedVector2Array()
		for point in region.polygon:
			points.append(to_local(region.to_global(point)))
		if points.size() < 3:
			push_error("%s: ground polygon needs at least three vertices" % region.get_path())
			continue
		if region.kind == GroundRegion.Kind.WALKABLE:
			if not walk_polygon.is_empty():
				push_error("%s: use one continuous walkable polygon" % name)
			walk_polygon = points
		else:
			walk_obstacles.append(points)

func spawn_position(id: String) -> Vector2:
	var point = get_node_or_null("Spawns/" + id)
	if point is Marker2D:
		return point.global_position
	push_warning("Missing spawn: " + id + "; using Start")
	return $Spawns/Start.global_position

func spawn_facing(id: String, fallback: int = 1) -> int:
	var point = get_node_or_null("Spawns/" + id)
	return int(point.get_meta("facing", fallback)) if point != null else fallback
