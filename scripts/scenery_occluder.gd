extends Polygon2D
## A silhouette sampled from the unchanged painting, ordered by the player's feet.
@export var depth_y: float = 0.0
var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("protagonist")
	_update_depth()

func _process(_delta: float) -> void:
	_update_depth()

func _update_depth() -> void:
	if is_instance_valid(player):
		z_index = 3 if player.global_position.y <= depth_y else -19
