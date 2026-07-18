extends Control

signal minigame_completed
signal minigame_failed

# Esta variable nos pedirá el "molde" de la basura
@export var trash_scene: PackedScene 

@onready var vent_area = $VentArea
@onready var trash_container = $TrashContainer

var items_left: int = 0

func _ready() -> void:
	randomize() # Asegura que la semilla de generación sea diferente cada partida
	
	# Decidimos cuánta basura habrá (entre 3 y 5)
	var num_items = randi_range(3, 5)
	items_left = num_items
	
	for i in range(num_items):
		# 1. Instanciamos la basura (creamos el objeto)
		var trash_instance = trash_scene.instantiate()
		
		# 2. Le pasamos la referencia del área verde
		trash_instance.vent_rect = vent_area
		
		# 3. Calculamos una posición aleatoria. 
		# Le restamos el tamaño de la basura (size.x) para que no se dibuje por fuera del borde.
		var max_x = vent_area.size.x - trash_instance.size.x
		var max_y = vent_area.size.y - trash_instance.size.y
		
		trash_instance.position = Vector2(
			randf_range(0, max_x),
			randf_range(0, max_y)
		)
		
		# 4. Conectamos la señal
		trash_instance.item_cleaned.connect(_on_item_cleaned)
		
		# 5. La agregamos como hija del contenedor
		trash_container.add_child(trash_instance)

func _on_item_cleaned() -> void:
	items_left -= 1
	if items_left <= 0:
		finish_minigame()

func finish_minigame() -> void:
	print("¡Ventilación limpia!")
	minigame_completed.emit()
