class_name DayOneTimeDial
extends Control
## Rotating time wheel: the wheel turns so the current period's sector centre
## sits on the pointer axis (9 o'clock), where the pointer tip presses the rim.

const SECTOR_CENTERS := [75.0, 135.0, 195.0, 255.0, 315.0]
const POINTER_DIRECTION := 270.0
const TURN_TIME := 0.55

@onready var dial: TextureRect = $Dial
@onready var period_label: Label = $PeriodName
@onready var location_label: Label = $LocationName
@onready var quest_title: Label = $QuestTitle
@onready var quest_description: Label = $QuestDescription
@onready var quest_status: Label = $QuestStatus

var turn_tween: Tween


func _ready() -> void:
	GameState.changed.connect(refresh)
	refresh()


func refresh() -> void:
	apply_period()
	period_label.text = GameState.period_name()
	location_label.text = GameState.location_name()
	var quest := GameState.current_main_quest()
	quest_title.text = quest["title"]
	quest_description.text = quest["description"]
	quest_status.text = quest["status"]


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
