# res://scenes/minigames/clear_asteroids/Background.gd
# Colgar este script del nodo "Background" (debe ser un ColorRect
# que ocupe todo el rect del minijuego, anchors full rect).
extends ColorRect

@export var shader_path: String = "res://scenes/minigames/clearAsteroid/greenVision.gdshader"


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # no debe bloquear clicks a los asteroides

	var shader: Shader = load(shader_path)
	var mat := ShaderMaterial.new()
	mat.shader = shader
	material = mat

	# Color base del ColorRect (poco importa, el shader lee la pantalla detrás,
	# pero Godot necesita que el rect tenga algo de alpha para dibujarse)
	color = Color(0, 0, 0, 1)
