extends CharacterBody3D

@onready var head = $head
@onready var animation_player: AnimationPlayer = $head/Camera3D/view_model/AnimationPlayer
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_sens = 0.3

@export var footstep_sounds: Array[AudioStream] = []
@export var footstep_interval: float = 0.45  # tiempo entre pasos (ajusta según animación/velocidad)
var footstep_timer: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	#var ui = preload("res://ui/TaskCounterUI.tscn").instantiate()
	#get_tree().root.add_child(ui)

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		return
	# -------------------------
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
				
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	# -------------------------------------------

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("left_mouse"):
		animation_player.play("swing_01")
		
	if Input.is_action_just_pressed("right_mouse"):
		animation_player.play("swing_02")
		
	if !animation_player.is_playing():
		animation_player.play("idle")
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	_handle_footsteps(direction, delta)

	move_and_slide()

func _handle_footsteps(direction: Vector3, delta: float) -> void:
	var is_moving := direction.length() > 0.1 and is_on_floor()
	
	if is_moving:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0.0  # para que el próximo paso suene apenas empiece a moverse
		
func _play_footstep() -> void:
	if footstep_sounds.is_empty() or not footstep_player:
		return
	
	var random_index := randi() % footstep_sounds.size()
	footstep_player.stream = footstep_sounds[random_index]
	footstep_player.play()
