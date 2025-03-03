extends Node3D

@onready var cam = get_viewport().get_camera_3d()

var dragging_card

func _ready():
	pass

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			clicked()
		elif dragging_card:
			dragging_card.dragging = false
			dragging_card = null

func _process(_delta: float):
	pass

func clicked():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = cam.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + cam.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query).get('collider')
	if result and result.is_in_group("cards"):
		dragging_card = result
		dragging_card.start_drag()
