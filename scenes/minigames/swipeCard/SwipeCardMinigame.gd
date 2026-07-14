# res://scenes/minigames/swipe_card/SwipeCardMinigame.gd
class_name SwipeCardMinigame
extends MinigameBase

@export var min_speed: float = 300.0   # px/seg
@export var max_speed: float = 900.0   # px/seg
@export var track_start_x: float = 60.0
@export var track_end_x: float = 500.0
@export var max_fails: int = 3

@onready var card: Control = $Card
@onready var feedback_label: Label = $FeedbackLabel

var is_dragging: bool = false
var drag_start_pos: Vector2
var drag_start_time: float
var fail_count: int = 0


func _on_minigame_ready() -> void:
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE   # <- esto es lo que faltaba
	card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	#card.size = Vector2(60, 90)              # el tamaño que quieras para la tarjeta
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Card/CardArt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reset_card()
	feedback_label.text = ""



func _reset_card() -> void:
	card.position.x = track_start_x
	is_dragging = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed and _mouse_over_card(mb.position):
			is_dragging = true
			drag_start_pos = card.position
			drag_start_time = Time.get_ticks_msec() / 1000.0
		elif not mb.pressed and is_dragging:
			_evaluate_swipe()
			is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		var mm := event as InputEventMouseMotion
		var new_x: float = clamp(card.position.x + mm.relative.x, track_start_x, track_end_x)
		card.position.x = new_x


func _mouse_over_card(pos: Vector2) -> bool:
	return Rect2(card.position, card.size).has_point(pos)


func _evaluate_swipe() -> void:
	if card.position.x < track_end_x - 10.0:
		# no llegó al final, no cuenta como intento válido
		_reset_card()
		return

	var elapsed: float = max(Time.get_ticks_msec() / 1000.0 - drag_start_time, 0.001)
	var distance: float = track_end_x - track_start_x
	var speed: float = distance / elapsed

	if speed < min_speed:
		feedback_label.text = "¡Muy lento!"
		_register_fail()
	elif speed > max_speed:
		feedback_label.text = "¡Muy rápido!"
		_register_fail()
	else:
		feedback_label.text = "¡Perfecto!"
		complete()


func _register_fail() -> void:
	fail_count += 1
	_reset_card()
	if fail_count >= max_fails:
		fail()
