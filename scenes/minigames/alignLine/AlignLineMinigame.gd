# res://scenes/minigames/align_line/AlignLineMinigame.gd
class_name AlignLineMinigame
extends MinigameBase

@export var tolerance: float = 1
@export var hold_duration: float = 5
@export var line_thickness: float = 4.0
@export var target_thickness: float = 3

@onready var screen_panel: Control = $ScreenPanel
@onready var target_guide: Control = $ScreenPanel/TargetGuide
@onready var output_line: Control = $ScreenPanel/OutputLine

@onready var curve_track: Control = $CurveTrack
@onready var drag_handle: Control = $CurveTrack/DragHandle

@onready var feedback_label: Label = $FeedbackLabel

var track_top: float
var track_bottom: float
var handle_y: float

var target_y: float          # posición objetivo dentro de ScreenPanel
var is_dragging: bool = false
var align_time: float = 0.0


func _on_minigame_ready() -> void:
	drag_handle.set_anchors_preset(Control.PRESET_TOP_LEFT)
	drag_handle.size = Vector2(40, 30)
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_on_handle_input)
	for child in drag_handle.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	track_top = 0.0
	track_bottom = curve_track.size.y
	handle_y = track_top
	_update_handle_position()

	# --- FIX ACÁ: forzar anchors ANTES de tocar size o position ---
	target_guide.set_anchors_preset(Control.PRESET_TOP_LEFT)
	target_guide.size = Vector2(screen_panel.size.x, target_thickness)
	target_guide.position.y = randf_range(
		screen_panel.size.y * 0.3,
		screen_panel.size.y * 0.85
	) - target_guide.size.y / 2.0

	# también forzamos que el arte hijo (el ColorRect rojo) siga el tamaño real,
	# no el que traía puesto a mano desde el editor
	for child in target_guide.get_children():
		if child is Control:
			child.set_anchors_preset(Control.PRESET_FULL_RECT)
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	target_y = target_guide.position.y + target_guide.size.y / 2.0

	output_line.set_anchors_preset(Control.PRESET_TOP_LEFT)
	output_line.size = Vector2(screen_panel.size.x, line_thickness)
	_update_output_line_position()


func _on_handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = mb.pressed

	elif event is InputEventMouseMotion and is_dragging:
		var mm := event as InputEventMouseMotion
		handle_y = clamp(handle_y + mm.relative.y, track_top, track_bottom)
		_update_handle_position()
		_update_output_line_position()


func _update_handle_position() -> void:
	drag_handle.position.y = handle_y - drag_handle.size.y / 2.0


func _update_output_line_position() -> void:
	# mapeamos la posición de la flecha (0..track_bottom) a la altura de ScreenPanel
	var ratio: float = (handle_y - track_top) / (track_bottom - track_top)
	var line_y: float = ratio * screen_panel.size.y
	output_line.position.y = line_y - output_line.size.y / 2.0


func _process(delta: float) -> void:
	var line_center_y: float = output_line.position.y + output_line.size.y / 2.0
	var is_aligned: bool = abs(line_center_y - target_y) <= tolerance

	if is_aligned:
		align_time += delta
		feedback_label.text = "¡Alineado! Mantenelo..."
	else:
		align_time = max(align_time - delta * 1.5, 0.0)
		feedback_label.text = ""

	if align_time >= hold_duration:
		print("completado")
		complete()

	super._process(delta)


func _draw_output_line() -> void:
	# opcional: si preferís dibujar la línea por código en vez de un ColorRect,
	# reemplazá el nodo OutputLine por un Control con este _draw():
	pass
