extends Node2D

@export var body: RigidBody2D
@export var leg_joint: RapierPinJoint2D
@export var leg_joint_2: RapierPinJoint2D
@export var body_self_righting_torque := 10000000.0
@export var body_self_righting_range := deg_to_rad(90.0)


func _ready() -> void:
	leg_joint.motor_position_target_angle = deg_to_rad(-90)
	leg_joint_2.motor_position_target_angle = deg_to_rad(-90)


func _physics_process(delta: float) -> void:
	var force := clampf(remap(
			body.rotation,
			-body_self_righting_range,
			body_self_righting_range,
			body_self_righting_torque,
			-body_self_righting_torque),
			-body_self_righting_torque,
			body_self_righting_torque)
	#var force := angle_difference(0.0, absf(body.rotation))
	body.apply_torque(force * delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.as_text() == "D":
		if event.is_pressed():
			leg_joint.motor_position_target_angle = deg_to_rad(90)
		elif event.is_released():
			leg_joint.motor_position_target_angle = deg_to_rad(-90)
	elif event.as_text() == "F":
		if event.is_pressed():
			leg_joint_2.motor_position_target_angle = deg_to_rad(90)
		elif event.is_released():
			leg_joint_2.motor_position_target_angle = deg_to_rad(-90)
