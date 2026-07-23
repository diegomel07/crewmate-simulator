extends Node3D
class_name AutomaticSlidingDoor

@onready var left_door: AnimatableBody3D = $LeftDoor
@onready var right_door: AnimatableBody3D = $RightDoor
@onready var trigger_area: Area3D = $DoorTrigger
@onready var door_sound: AudioStreamPlayer3D = $DoorSound

var closed_pos_left: Vector3
var closed_pos_right: Vector3
var open_pos_left: Vector3
var open_pos_right: Vector3
var current_tween: Tween = null

@export var slide_distance: float = 2.2          
@export var open_duration: float = 0.35          
@export var close_duration: float = 0.45         
@export var transition_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type_open: Tween.EaseType = Tween.EASE_OUT
@export var ease_type_close: Tween.EaseType = Tween.EASE_IN

@export var open_sound: AudioStream
@export var close_sound: AudioStream

func _ready() -> void:
	closed_pos_left = left_door.position
	closed_pos_right = right_door.position
	
	open_pos_left = closed_pos_left + Vector3(-slide_distance, 0, 0)
	open_pos_right = closed_pos_right + Vector3(slide_distance, 0, 0)
	
	trigger_area.body_entered.connect(_on_body_entered)
	trigger_area.body_exited.connect(_on_body_exited)
	
	print("Puerta automática lista: ", name)

func _on_body_entered(body: Node3D) -> void:
	if _is_player(body):
		open_doors()

func _on_body_exited(body: Node3D) -> void:
	if _is_player(body):
		close_doors()

func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player") or body is CharacterBody3D

func open_doors() -> void:
	if current_tween:
		current_tween.kill()  
	
	_play_sound(open_sound)
	
	current_tween = create_tween().set_parallel(true)
	
	current_tween.tween_property(left_door, "position", open_pos_left, open_duration) \
		.set_trans(transition_type).set_ease(ease_type_open)
	
	current_tween.tween_property(right_door, "position", open_pos_right, open_duration) \
		.set_trans(transition_type).set_ease(ease_type_open)

func close_doors() -> void:
	if current_tween:
		current_tween.kill()  
	
	_play_sound(close_sound)
	
	current_tween = create_tween().set_parallel(true)
	
	current_tween.tween_property(left_door, "position", closed_pos_left, close_duration) \
		.set_trans(transition_type).set_ease(ease_type_close)
	
	current_tween.tween_property(right_door, "position", closed_pos_right, close_duration) \
		.set_trans(transition_type).set_ease(ease_type_close)

func _play_sound(stream: AudioStream) -> void:
	if stream and door_sound:
		door_sound.stream = stream
		door_sound.play()
