# res://scenes/tasks/TaskStation.gd
extends Area3D

@export var task_id: String = "wires"   # debe coincidir con minigame_registry
@export var interact_action: String = "interact"  # nombre de la acción en Input Map

@onready var prompt_label: Label3D = $PromptLabel3D

var player_in_range: bool = false
var is_completed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	MinigameManager.minigame_finished.connect(_on_minigame_finished)
	prompt_label.visible = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_completed:
		player_in_range = true
		prompt_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_completed and event.is_action_pressed(interact_action):
		prompt_label.visible = false
		MinigameManager.open_minigame(task_id)


func _on_minigame_finished(finished_task_id: String, success: bool) -> void:
	if finished_task_id != task_id:
		return

	if success:
		is_completed = true
		prompt_label.visible = false
		# TODO: tu arte acá — por ejemplo cambiar el material del
		# MeshInstance3D a uno "completado" (verde, con un check, etc.)
		print("Tarea completada: ", task_id)
	else:
		# el jugador falló o canceló, puede reintentar si sigue en rango
		if player_in_range:
			prompt_label.visible = true
		print("Tarea fallada/cancelada: ", task_id)
