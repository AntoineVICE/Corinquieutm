@tool
extends Polygon2D
## Original-painting silhouette. Depth Y is a ground contact in this node's local
## coordinates, shared by every part of one prop (including parts above the floor).
@export var depth_y: float = 0.0

func _ready() -> void:
	_update_depth()

func _process(_delta: float) -> void:
	_update_depth()

func _update_depth() -> void:
	WorldDepth.at_feet(self, to_global(Vector2(0, depth_y)).y, true)
