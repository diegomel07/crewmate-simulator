extends RigidBody2D

func _ready() -> void:
	# Garantizamos la etiqueta y la inmunidad a la pausa apenas nace
	add_to_group("trash")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	# "Ametralladora de despertar": Si el motor de físicas intenta 
	# dormirlos por estar chocando entre sí, esto los obliga a recalcular 
	# su gravedad todo el tiempo.
	sleeping = false
