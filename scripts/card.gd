extends RigidBody3D

@export_group("Movement", "movement")
@export_range(0, 200, 10) var movement_stiffness: float = 100.0
@export_range(0, 20, 1) var movement_damping: float = 10.0

@export_group("Rotation", "rotation")
@export_range(0, 100, 1) var rotation_stiffness: float = 5.0
@export_range(0, 2, 0.1) var rotation_damping: float = 1.0
@export_range(0, 10, 0.1) var rotation_ratio: float = 0.1
@export_range(0, 1, 0.1) var rotation_max: float = 0.25

@export_range(0, 1, 0.05) var popup_amount: float = 0.15

@onready var cam = get_viewport().get_camera_3d()
@onready var original_quat = global_transform.basis.get_rotation_quaternion()
@onready var original_position = global_transform.origin

var dragging = false
var target: CardTarget = null

func _ready():
	gravity_scale = 0
	collision_mask = 0

func _physics_process(_delta):
	if dragging:
		var target = get_drag_target()
		move_card(target)
	elif target:
		move_card(target.global_position)
	else:
		move_card(original_position)
	
	rotate_card()

func start_drag():
	dragging = true
	target = null
	original_position = global_position

func set_target(new_target):
	if dragging:
		target = new_target

func remove_target(left_target):
	if target == left_target:
		target = null

func get_drag_target():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = cam.project_ray_origin(mouse_pos)
	var ray_dir = cam.project_ray_normal(mouse_pos)
	var plane = Plane(-cam.global_transform.basis.z, original_position + Vector3.BACK * popup_amount)
	return plane.intersects_ray(ray_origin, ray_dir)

func move_card(target):
	var displacement = target - global_transform.origin
	var force = displacement * movement_stiffness - linear_velocity * movement_damping
	apply_central_force(force)

func rotate_card():
	var current_quat = global_transform.basis.get_rotation_quaternion()
	var move_dir = linear_velocity.normalized()
	var desired_transform = Transform3D().looking_at(global_transform.origin - move_dir, Vector3.UP)
	var target_quat = desired_transform.basis.get_rotation_quaternion()
	var blend_factor = clamp(linear_velocity.length() * rotation_ratio, 0, rotation_max)
	var desired_quat = original_quat.slerp(target_quat, blend_factor)
	var error_quat = current_quat.inverse() * desired_quat
	var angular_error = error_quat.get_euler()
	var torque = angular_error * rotation_stiffness - angular_velocity * rotation_damping
	apply_torque(torque)
