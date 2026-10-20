class_name WalkSurface
extends RefCounted
## The location owns ground geometry. Player movement, spawn recovery and interaction
## reach all query this surface instead of maintaining competing collision systems.

var room: Node2D
var radius: Vector2
var boundary: PackedVector2Array
var obstacles: Array[PackedVector2Array] = []
var actors: Array[Node2D] = []
var horizontal_only: bool

func _init(location: Node2D, foot_radius: Vector2) -> void:
	room = location
	radius = foot_radius * location.player_scale
	boundary = location.walk_polygon
	obstacles.assign(location.walk_obstacles)
	horizontal_only = boundary.is_empty()
	for item in location.get_node("Interactions").get_children():
		if item is DayOneInteractable and item.placeholder_person:
			actors.append(item)

func is_walkable(world_point: Vector2, include_actors: bool = true) -> bool:
	var point = room.to_local(world_point)
	if horizontal_only:
		if point.x < room.walk_left + radius.x or point.x > room.walk_right - radius.x or absf(point.y - room.walk_y) > 0.01:
			return false
	elif not Geometry2D.is_point_in_polygon(point, boundary) or _touches_edge(point, boundary):
		return false
	for polygon in obstacles:
		if Geometry2D.is_point_in_polygon(point, polygon) or _touches_edge(point, polygon):
			return false
	if include_actors:
		for actor in actors:
			if is_instance_valid(actor) and actor.is_visible_in_tree() and actor.blocks_walking:
				var combined = radius + actor.foot_radius * room.player_scale
				var delta = (world_point - actor.global_position) / combined
				if delta.length_squared() < 1.0:
					return false
	return true

func _touches_edge(point: Vector2, polygon: PackedVector2Array) -> bool:
	# Scale the ground plane so an elliptical footprint becomes a unit circle.
	# Checking edges (not just sampled foot points) catches thin and diagonal props.
	for i in range(polygon.size()):
		var a = (polygon[i] - point) / radius
		var b = (polygon[(i + 1) % polygon.size()] - point) / radius
		if Geometry2D.get_closest_point_to_segment(Vector2.ZERO, a, b).length_squared() < 1.0:
			return true
	return false

func clear_interaction_path(from: Vector2, to: Vector2) -> bool:
	# Interaction targets are ground approach points, not the icon on a wall.
	# NPC footprints are excluded here: a conversation must be able to reach its speaker.
	var a = room.to_local(from)
	var b = room.to_local(to)
	var steps = maxi(1, ceili(a.distance_to(b) / 4.0))
	for i in range(steps + 1):
		var point = a.lerp(b, float(i) / steps)
		if not boundary.is_empty() and not Geometry2D.is_point_in_polygon(point, boundary):
			return false
		for polygon in obstacles:
			if Geometry2D.is_point_in_polygon(point, polygon):
				return false
	return true

func closest_walkable(world_point: Vector2) -> Vector2:
	var point = room.to_local(world_point)
	if horizontal_only:
		point = Vector2(clampf(point.x, room.walk_left + radius.x, room.walk_right - radius.x), room.walk_y)
	if is_walkable(room.to_global(point)):
		return room.to_global(point)
	var candidates: Array[Vector2] = []
	var polygons: Array[PackedVector2Array] = obstacles.duplicate()
	if not boundary.is_empty():
		polygons.append(boundary)
	for polygon in polygons:
		for i in range(polygon.size()):
			var a = polygon[i]
			var b = polygon[(i + 1) % polygon.size()]
			var edge = Geometry2D.get_closest_point_to_segment(point, a, b)
			var normal = (b - a).orthogonal().normalized()
			var margin = (normal * radius).length() + 0.5
			candidates.append(edge + normal * margin)
			candidates.append(edge - normal * margin)
			for angle in range(16):
				candidates.append(a + Vector2.from_angle(TAU * angle / 16.0) * (radius + Vector2.ONE))
	for actor in actors:
		if is_instance_valid(actor) and actor.is_visible_in_tree() and actor.blocks_walking:
			var combined = radius + actor.foot_radius * room.player_scale + Vector2.ONE
			for angle in range(24):
				candidates.append(room.to_local(actor.global_position) + Vector2.from_angle(TAU * angle / 24.0) * combined)
	var closest = Vector2.INF
	var best_distance = INF
	for candidate in candidates:
		if horizontal_only:
			candidate.y = room.walk_y
		var distance = point.distance_squared_to(candidate)
		if distance < best_distance and is_walkable(room.to_global(candidate)):
			closest = candidate
			best_distance = distance
	if closest == Vector2.INF:
		# Malformed/very tight geometry must never silently return a blocked point.
		for y in range(0, 720, 4):
			if horizontal_only and absf(y - room.walk_y) > 4:
				continue
			for x in range(int(room.walk_left), int(room.walk_right), 8):
				var candidate = Vector2(x, room.walk_y if horizontal_only else y)
				var distance = point.distance_squared_to(candidate)
				if distance < best_distance and is_walkable(room.to_global(candidate)):
					closest = candidate
					best_distance = distance
	return room.to_global(closest) if closest != Vector2.INF else Vector2.INF
