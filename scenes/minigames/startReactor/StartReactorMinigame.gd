# res://scenes/minigames/start_reactor/StartReactorMinigame.gd
class_name StartReactorMinigame
extends MinigameBase

@export var hold_duration: float = 3.0   # segundos que hay que sostener ambos
@export var drain_rate: float = 2.0      # qué tan rápido baja el progreso si soltás

@onready var left_panel: Control = $LeftPanel
@onready var right_indicator: Control = $RightPanelIndicator
@onready var progress_bar: ProgressBar = $HoldProgressBar
@onready var feedback_label: Label = $FeedbackLabel

var left_held: bool = false
var key_held: bool = false
var progress: float = 0.0


func _on_minigame_ready() -> void:
	left_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	left_panel.size = Vector2(140, 140)      # el tamaño del panel
	$LeftPanel/LeftPanelArt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#left_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	progress_bar.min_value = 0.0
	progress_bar.max_value = hold_duration
	progress_bar.value = 0.0
	left_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	left_panel.gui_input.connect(_on_left_panel_input)


func _on_left_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			left_held = mb.pressed


func _process(delta: float) -> void:
	key_held = Input.is_action_pressed("reactor_hold")
	_update_visual_state()

	if left_held and key_held:
		progress = min(progress + delta, hold_duration)
		feedback_label.text = "¡Mantené así!"
	else:
		progress = max(progress - delta * drain_rate, 0.0)
		feedback_label.text = ""

	progress_bar.value = progress

	if progress >= hold_duration:
		complete()

	# también dejamos correr el time_limit heredado de MinigameBase
	super._process(delta)


func _update_visual_state() -> void:
	# TODO: tu arte acá — por ejemplo cambiar modulate/animación
	# según left_held y key_held para dar feedback visual de "sostenido"
	left_panel.modulate = Color.WHITE if left_held else Color(0.6, 0.6, 0.6)
	right_indicator.modulate = Color.WHITE if key_held else Color(0.6, 0.6, 0.6)
