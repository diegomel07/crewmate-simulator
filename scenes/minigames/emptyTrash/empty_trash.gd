extends Control

signal minigame_completed
signal minigame_failed

@export var trash_scene: PackedScene

@onready var spawn_area = $PhysicsContainer/TrashSpawnArea
@onready var trap_door_collision = $PhysicsContainer/TrapDoor/CollisionShape2D
@onready var exit_zone = $ExitZone
@onready var physics_container = $PhysicsContainer

var total_trash: int = 0
var trash_removed: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	physics_container.process_mode = Node.PROCESS_MODE_ALWAYS
	$PhysicsContainer/LeftWall.process_mode = Node.PROCESS_MODE_ALWAYS
	$PhysicsContainer/RightWall.process_mode = Node.PROCESS_MODE_ALWAYS
	$PhysicsContainer/TrapDoor.process_mode = Node.PROCESS_MODE_ALWAYS

	randomize()
	total_trash = randi_range(15, 30)
	spawn_trash_items()
	
	exit_zone.body_entered.connect(_on_trash_exited)
	$LeverUI/LeverHandle.lever_state_changed.connect(_on_lever_state_changed)

func spawn_trash_items() -> void:
	var rect = spawn_area.get_rect()
	
	for i in range(total_trash):
		var trash = trash_scene.instantiate()
		trash.add_to_group("trash")

		trash.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		trash.rotation_degrees = randf_range(0, 360)
		
		physics_container.add_child(trash)

func _on_lever_state_changed(is_down: bool) -> void:
	trap_door_collision.set_deferred("disabled", is_down)
	$PhysicsContainer/TrapDoor.visible = not is_down
	
	if is_down:
		var toda_la_basura = get_tree().get_nodes_in_group("trash")
		
		for pedazo in toda_la_basura:
			if pedazo is RigidBody2D:
				pedazo.sleeping = false

func _on_trash_exited(body: Node2D) -> void:
	
	if body.is_in_group("trash"):
		body.queue_free()
		trash_removed += 1
		
		if trash_removed >= total_trash:
			await get_tree().create_timer(0.5).timeout
			print("¡Basura vaciada!")
			minigame_completed.emit()
	else:
		print(">> ERROR: El objeto ", body.name, " no tiene el grupo 'trash'")
