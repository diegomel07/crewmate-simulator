extends RigidBody2D

# Creamos una lista donde pondremos todas las texturas desde el Inspector
@export var trash_textures: Array[Texture2D]

# Buscamos el nodo Sprite2D que tiene la imagen (asegúrate de que se llame así en tu escena)
@onready var sprite = $Sprite2D 

func _ready() -> void:
	add_to_group("trash")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Magia: Si hay imágenes en la lista, elegimos una al azar y se la ponemos al Sprite
	if trash_textures.size() > 0:
		sprite.texture = trash_textures.pick_random()

func _process(_delta: float) -> void:
	sleeping = false
