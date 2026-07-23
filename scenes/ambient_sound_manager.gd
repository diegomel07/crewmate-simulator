extends Node
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

#gei

@export var ambient_sounds: Array[AudioStream] = []
@export var min_interval: float = 15.0   # segundos mínimos entre sonidos
@export var max_interval: float = 60.0   # segundos máximos entre sonidos
@export var play_chance: float = 0.7     # probabilidad de que SÍ suene algo (0.0 - 1.0), para más imprevisibilidad

func _ready() -> void:
	_schedule_next_sound()

func _schedule_next_sound() -> void:
	var wait_time := randf_range(min_interval, max_interval)
	await get_tree().create_timer(wait_time).timeout
	_maybe_play_sound()
	_schedule_next_sound()  # se reprograma a sí mismo indefinidamente

func _maybe_play_sound() -> void:
	if ambient_sounds.is_empty():
		return
	
	if randf() <= play_chance:
		var player = get_tree().get_first_node_in_group("player")
		if player and audio_player is AudioStreamPlayer3D:
			var offset = Vector3(randf_range(-8, 8), randf_range(-2, 2), randf_range(-8, 8))
			audio_player.global_position = player.global_position + offset
		
		var random_index := randi() % ambient_sounds.size()
		audio_player.stream = ambient_sounds[random_index]
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		audio_player.play()
