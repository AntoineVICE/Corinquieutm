class_name DayOnePlayer
extends CharacterBody2D

@export var speed: float = 270.0
@export var idle_texture: Texture2D
@export var idle_texture_left: Texture2D
@export var walk_frames: SpriteFrames
@export var art_scale: float = 1.0

var control_enabled: bool = true
var facing: int = 1
var left_bound: float = 60.0
var right_bound: float = 1540.0
var stride: float = 0.0
var walk_y: float = 570.0
var walk_polygon: PackedVector2Array = PackedVector2Array()
var walk_obstacles: Array[PackedVector2Array] = []

@onready var sprite: Sprite2D = $Art/Idle
@onready var animated: AnimatedSprite2D = $Art/Animated

func _ready() -> void:
	add_to_group("protagonist")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite.texture = idle_texture
	if walk_frames != null:
		animated.sprite_frames = walk_frames
	animated.frame_changed.connect(_update_walk_clarity)
	_update_walk_clarity()
	$Art.scale = Vector2.ONE * art_scale
	_update_art(false)

func _update_walk_clarity() -> void:
	if animated.material is ShaderMaterial:
		# A0 is already the crisp standing drawing; compensate only moving poses.
		animated.material.set_shader_parameter("amount", 0.0 if animated.frame == 0 else 0.55)

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	if control_enabled:
		direction.x = Input.get_axis("move_left", "move_right")
		if not walk_polygon.is_empty():
			direction.y = Input.get_axis("move_up", "move_down")
		direction = direction.limit_length()
	# Shallow depth changes the walk path, never the character's scale.
	velocity = Vector2(direction.x * speed, direction.y * speed * 0.6)
	if direction.x != 0:
		facing = 1 if direction.x > 0 else -1
	var previous_position = position
	if walk_polygon.is_empty() and walk_obstacles.is_empty():
		move_and_slide()
		position = constrain_position(position)
	else:
		_move_on_path(velocity * delta)
	var walking = not position.is_equal_approx(previous_position)
	if walking:
		stride += delta * 12.0
	else:
		velocity = Vector2.ZERO
	_update_art(walking)
	queue_redraw()

func configure_location(location: DayOneLocation) -> void:
	walk_y = location.walk_y
	left_bound = location.walk_left
	right_bound = location.walk_right
	walk_polygon = location.walk_polygon
	walk_obstacles = location.walk_obstacles
	# One fixed composition scale per location; moving in depth never changes it.
	$Art.scale = Vector2.ONE * art_scale * location.player_scale
	$Body.scale = Vector2.ONE * location.player_scale
	$Body.position.y = -162.5 * location.player_scale

func constrain_position(point: Vector2) -> Vector2:
	if walk_polygon.is_empty():
		point = Vector2(clampf(point.x, left_bound, right_bound), walk_y)
	if is_walkable(point):
		return point
	var closest = Vector2(clampf(point.x, left_bound, right_bound), walk_y)
	var distance = INF
	var boundaries: Array[PackedVector2Array] = walk_obstacles.duplicate()
	if not walk_polygon.is_empty():
		boundaries.append(walk_polygon)
	for boundary in boundaries:
		for i in range(boundary.size()):
			var a = boundary[i]
			var b = boundary[(i + 1) % boundary.size()]
			var edge_point = Geometry2D.get_closest_point_to_segment(point, a, b)
			var normal = (b - a).orthogonal().normalized()
			for offset in [0.0, 1.0, -1.0]:
				var candidate = edge_point + normal * offset
				var candidate_distance = point.distance_squared_to(candidate)
				if is_walkable(candidate) and candidate_distance < distance:
					distance = candidate_distance
					closest = candidate
	return closest

func is_walkable(point: Vector2) -> bool:
	if walk_polygon.is_empty():
		if point.x < left_bound or point.x > right_bound or absf(point.y - walk_y) > 0.01:
			return false
	elif not Geometry2D.is_point_in_polygon(point, walk_polygon):
		return false
	for obstacle in walk_obstacles:
		if Geometry2D.is_point_in_polygon(point, obstacle):
			return false
	return true

func _move_on_path(motion: Vector2) -> void:
	# Short steps prevent crossing narrow beds at low frame rates. Slide along edges.
	var steps = maxi(1, ceili(motion.length() / 3.0))
	var step = motion / steps
	for i in range(steps):
		if is_walkable(position + step):
			position += step
		else:
			for axis_step in [Vector2(step.x, 0), Vector2(0, step.y)]:
				if is_walkable(position + axis_step):
					position += axis_step

func _update_art(walking: bool) -> void:
	var animation_name: StringName = &"walk_left" if facing < 0 else &"walk_right"
	var directional_walk = walk_frames != null and walk_frames.has_animation(animation_name)
	if not directional_walk:
		animation_name = &"walk"
	var has_walk = walk_frames != null and walk_frames.has_animation(animation_name)
	animated.visible = walking and has_walk
	sprite.visible = not animated.visible and idle_texture != null
	# The supplied directions have their own artwork; do not mirror their book/hand details.
	animated.flip_h = facing < 0 and not directional_walk
	sprite.texture = idle_texture_left if facing < 0 and idle_texture_left != null else idle_texture
	sprite.flip_h = facing < 0 and idle_texture_left == null
	if animated.visible:
		animated.play(animation_name)
	else:
		animated.stop()

func _draw() -> void:
	if idle_texture != null or (is_instance_valid(animated) and animated.visible):
		return
	# Temporary vector silhouette; replace via exported texture / animation slots.
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_circle(Vector2(0, -118), 17, Color("d9bfa0"))
	draw_arc(Vector2(0, -122), 18, PI, TAU, 12, Color("403d35"), 8)
	draw_colored_polygon(PackedVector2Array([Vector2(-18,-96),Vector2(16,-96),Vector2(24,-20),Vector2(-25,-20)]),Color("52716d"))
	var swing = sin(stride) * 8.0 if absf(velocity.x) > 1 else 0.0
	draw_line(Vector2(-10,-22),Vector2(-10+swing,0),Color("34332e"),9)
	draw_line(Vector2(10,-22),Vector2(10-swing,0),Color("34332e"),9)
	draw_line(Vector2(12,-88),Vector2(22,-52),Color("d9bfa0"),7)
