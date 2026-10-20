class_name DayOnePlayer
extends CharacterBody2D

@export var speed: float = 270.0
@export var idle_texture: Texture2D
@export var idle_texture_left: Texture2D
@export var walk_frames: SpriteFrames
@export var art_scale: float = 1.0
## Ground footprint, independent of the character's visible height.
@export var foot_radius: Vector2 = Vector2(34, 8)
## Shared anchors per direction, not recalculated from individual animation frames.
@export var right_foot_anchor: Vector2 = Vector2(652, 1991)
@export var left_foot_anchor: Vector2 = Vector2(788, 1991)

var control_enabled: bool = true
var facing: int = 1
var left_bound: float = 60.0
var right_bound: float = 1540.0
var stride: float = 0.0
var walk_y: float = 570.0
var walk_polygon: PackedVector2Array = PackedVector2Array()
var walk_obstacles: Array[PackedVector2Array] = []
var walk_surface: WalkSurface

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
	if walk_surface != null:
		_move_on_path(velocity * delta)
	var walking = not position.is_equal_approx(previous_position)
	if walking:
		stride += delta * 12.0
	else:
		velocity = Vector2.ZERO
	_update_art(walking)
	WorldDepth.at_feet(self, global_position.y)
	queue_redraw()

func configure_location(location: DayOneLocation) -> void:
	walk_y = location.walk_y
	left_bound = location.walk_left
	right_bound = location.walk_right
	walk_surface = location.create_walk_surface(foot_radius)
	walk_polygon = location.walk_polygon
	walk_obstacles = location.walk_obstacles
	# One fixed composition scale per location; moving in depth never changes it.
	$Art.scale = Vector2.ONE * art_scale * location.player_scale
	$Body.shape = RectangleShape2D.new()
	$Body.shape.size = foot_radius * 2.0 * location.player_scale
	$Body.position = Vector2.ZERO

func constrain_position(point: Vector2) -> Vector2:
	return walk_surface.closest_walkable(point) if walk_surface != null else point

func is_walkable(point: Vector2) -> bool:
	return walk_surface != null and walk_surface.is_walkable(point)

func can_reach(item: DayOneInteractable) -> bool:
	return global_position.distance_to(item.global_position) <= item.interaction_distance \
		and walk_surface != null and walk_surface.clear_interaction_path(global_position, item.global_position)

func _move_on_path(motion: Vector2) -> void:
	# Short steps prevent crossing narrow beds at low frame rates. Slide along edges.
	var steps = maxi(1, ceili(motion.length() / 3.0))
	var step = motion / steps
	for i in range(steps):
		if is_walkable(global_position + step):
			global_position += step
		else:
			for axis_step in [Vector2(step.x, 0), Vector2(0, step.y)]:
				if is_walkable(global_position + axis_step):
					global_position += axis_step

func _update_art(walking: bool) -> void:
	var anchor = left_foot_anchor if facing < 0 else right_foot_anchor
	sprite.position = -anchor
	animated.position = -anchor
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
