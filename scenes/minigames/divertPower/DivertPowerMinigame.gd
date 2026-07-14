# res://scenes/minigames/divert_power/DivertPowerMinigame.gd
class_name DivertPowerMinigame
extends MinigameBase

@export var marker_speed: float = 220.0       # px/seg
@export var hold_duration: float = 2.0        # segundos dentro de la zona para ganar
@export var target_zone_height: float = 60.0

@onready var meter_track: Control = $MeterTrack
@onready var target_zone: ColorRect = $MeterTrack/TargetZone
@onready var marker: Control = $MeterTrack/Marker
@onready var progress_bar: ProgressBar = $HoldProgressBar
@onready var feedback_label: Label = $FeedbackLabel

var track_top: float
var track_bottom: float
var marker_y: float
var hold_time: float = 0.0


func _on_minigame_ready() -> void:
	track_top = 0.0
	track_bottom = meter_track.size.y

	# Ubicamos la zona objetivo en una posición aleatoria dentro del carril
	var zone_y: float = randf_range(track_top, track_bottom - target_zone_height)
	target_zone.position.y = zone_y
	target_zone.size.y = target_zone_height

	marker_y = track_bottom  # arranca abajo del todo
	marker.position.y = marker_y

	progress_bar.min_value = 0.0
	progress_bar.max_value = hold_duration
	progress_bar.value = 0.0


func _process(delta: float) -> void:
	var input_dir: float = 0.0
	if Input.is_action_pressed("ui_up"):
		input_dir -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_dir += 1.0

	marker_y = clamp(marker_y + input_dir * marker_speed * delta, track_top, track_bottom)
	marker.position.y = marker_y

	var zone_top: float = target_zone.position.y
	var zone_bottom: float = target_zone.position.y + target_zone.size.y
	var inside_zone: bool = marker_y >= zone_top and marker_y <= zone_bottom

	if inside_zone:
		hold_time += delta
		feedback_label.text = "¡Mantenelo ahí!"
	else:
		hold_time = max(hold_time - delta * 1.5, 0.0)
		feedback_label.text = ""

	progress_bar.value = hold_time

	if hold_time >= hold_duration:
		complete()

	super._process(delta)
