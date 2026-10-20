class_name DayOneTimeDial
extends Control
## Rotating time wheel: the wheel turns so the current period's sector centre
## sits on the pointer axis (9 o'clock), where the pointer tip presses the rim.

const SECTOR_CENTERS := [75.0, 135.0, 195.0, 255.0, 315.0]
const POINTER_DIRECTION := 270.0
const TURN_TIME := 0.55

@onready var dial: TextureRect = $Dial

var turn_tween: Tween


func _ready() -> void:
	GameState.changed.connect(apply_period)
	apply_period()


func apply_period() -> void:
	if not is_instance_valid(dial):
		return
	var index := clampi(GameState.period_index, 0, SECTOR_CENTERS.size() - 1)
	var target := deg_to_rad(POINTER_DIRECTION - SECTOR_CENTERS[index])
	# Take the shortest way round so advancing a period never spins a full turn.
	var delta := wrapf(target - dial.rotation, -PI, PI)
	if is_instance_valid(turn_tween) and turn_tween.is_valid():
		turn_tween.kill()
	if is_zero_approx(delta):
		dial.rotation = target
		return
	turn_tween = create_tween()
	turn_tween.tween_property(dial, "rotation", dial.rotation + delta, TURN_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
