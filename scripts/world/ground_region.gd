@tool
class_name GroundRegion
extends Polygon2D
## Editable ground-plane geometry. Visible only in the editor, never in the game.
enum Kind { WALKABLE, OBSTACLE }
@export var kind: Kind = Kind.WALKABLE:
	set(value):
		kind = value
		_refresh_preview()

func _ready() -> void:
	_refresh_preview()

func _refresh_preview() -> void:
	visible = Engine.is_editor_hint()
	color = Color(0.2, 0.85, 0.45, 0.18) if kind == Kind.WALKABLE else Color(0.95, 0.25, 0.15, 0.3)
	z_as_relative = false
	z_index = 4050
