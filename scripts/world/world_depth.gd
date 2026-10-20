class_name WorldDepth
extends RefCounted
## All world art uses the same ground-plane depth, regardless of scene nesting.
## HUD lives on a CanvasLayer. World interaction markers use MARKER_Z.

const MARKER_Z = 4000
const FOREGROUND_Z = 3900

static func at_feet(item: CanvasItem, world_y: float, scenery: bool = false) -> void:
	item.z_as_relative = false
	item.z_index = clampi(roundi(world_y * 4.0), -3500, 3500) + (1 if scenery else 0)
