extends Camera3D

@export var follow_height: float = 40.0

var current_zoom: float = 25.0
var min_zoom: float = 12.0
var max_zoom: float = 55.0
var zoom_speed: float = 5.0

func _ready():
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = current_zoom

func _process(_delta: float):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		global_position = Vector3(
			player.global_position.x,
			follow_height,
			player.global_position.z
		)
