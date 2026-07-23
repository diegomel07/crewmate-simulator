extends CanvasLayer

@onready var task_label: Label = $TaskLabel
@onready var final_warning: Label = $FinalWarning
@onready var final_video: VideoStreamPlayer = $VideoStreamPlayer
@onready var killer: Node3D = $"amongus-final"
@onready var task_complete_sound: AudioStreamPlayer = $Scream

func _ready() -> void:
	_update_label()
	MinigameManager.minigame_finished.connect(_on_minigame_finished)

func _on_minigame_finished(_task_id: String, success: bool) -> void:
	if success:
		_update_label()
		if MinigameManager.cant_minigames_completed == 10:
			$"amongus-final/Area3D".monitoring = true
			final_warning.visible = true
			killer.visible = true
			$"../DirectionalLight3D".light_color = Color.RED
			$"../backgroundNoise".volume_db = 0
			task_complete_sound.play()

func _update_label() -> void:
	task_label.text = "Tareas completadas: %d" % MinigameManager.cant_minigames_completed
	
	
func _on_area_3d_body_entered(body):
	if body.name == "player":
		final_video.visible = true
		final_video.play()
