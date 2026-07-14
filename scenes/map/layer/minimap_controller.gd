extends CanvasLayer

@onready var dim_background: ColorRect = $DimBackground
@onready var blur_background: ColorRect = $Blur
@onready var minimap_display: TextureRect = $MinimapContainer/MinimapDisplay
@onready var minimap_viewport: SubViewport = $"../MinimapViewport"   
var is_open: bool = false

func _ready():
	visible = false
	dim_background.visible = false
	blur_background.visible = false

func _input(event):
	if event.is_action_pressed("toggle_map"):
		toggle_minimap()

	if is_open and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func toggle_minimap():
	is_open = !is_open
	visible = is_open
	dim_background.visible = is_open
	blur_background.visible = is_open

func zoom_in():
	if minimap_viewport:
		var camera = minimap_viewport.get_node("TopDownCamera")
		if camera:
			camera.current_zoom = clamp(camera.current_zoom - camera.zoom_speed, camera.min_zoom, camera.max_zoom)
			camera.size = camera.current_zoom

func zoom_out():
	if minimap_viewport:
		var camera = minimap_viewport.get_node("TopDownCamera")
		if camera:
			camera.current_zoom = clamp(camera.current_zoom + camera.zoom_speed, camera.min_zoom, camera.max_zoom)
			camera.size = camera.current_zoom
