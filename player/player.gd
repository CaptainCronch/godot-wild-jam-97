extends Node2D

@export var body: RigidBody2D

#@export var leg: Limb
#@export var thigh_joint: RapierPinJoint2D
#@export var thigh_stiffness := 100000.0
#@export var thigh_damping := 10000.0
#@export var thigh_softness := 0.0001
#@export var thigh_angular_limit := [deg_to_rad(-30.0), deg_to_rad(60.0)]

#@export var arm: Limb
#@export var shoulder_joint: RapierPinJoint2D
#@export var shoulder_angular_limit := [deg_to_rad(-75.0), deg_to_rad(15.0)]

@export var limbs: Array[Limb] = []

@export var body_self_righting_torque := 10000000.0
@export var body_self_righting_range := deg_to_rad(90.0)


#func _ready() -> void:
	#Limb.setup_joint(thigh_joint, thigh_stiffness, thigh_damping, thigh_softness, thigh_angular_limit[0], thigh_angular_limit[1])
	#Limb.setup_joint(shoulder_joint, thigh_stiffness, thigh_damping, thigh_softness, shoulder_angular_limit[0], shoulder_angular_limit[1], shoulder_angular_limit[1])
	#thigh_joint.motor_position_enabled = true
	#thigh_joint.motor_position_stiffness = thigh_stiffness
	#thigh_joint.motor_position_damping = thigh_damping
	#thigh_joint.softness = thigh_softness
	#thigh_joint.angular_limit_enabled = true
	#thigh_joint.angular_limit_lower = thigh_angular_limit[0]
	#thigh_joint.angular_limit_upper = thigh_angular_limit[1]
	#thigh_joint.node_b = thigh_joint.get_path_to(leg.upper)
	#shoulder_joint.node_b = shoulder_joint.get_path_to(arm.upper)
	
	#leg.flex(false)
	#thigh_joint.motor_position_target_angle = thigh_angular_limit[0]


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
	for limb in limbs:
		if limb.limb_stats.key == event.as_text():
			limb.flex(event.is_pressed())
	#if event.as_text() == "D":
		#if event.is_pressed():
			#thigh_joint.motor_position_target_angle = thigh_angular_limit[1]
			#leg.flex(true)
		#elif event.is_released():
			#thigh_joint.motor_position_target_angle = thigh_angular_limit[0]
			#leg.flex(false)
	#elif event.as_text() == "F":
		#if event.is_pressed():
			#shoulder_joint.motor_position_target_angle = shoulder_angular_limit[0]
			#arm.flex(false)
		#elif event.is_released():
			#shoulder_joint.motor_position_target_angle = shoulder_angular_limit[1]
			#arm.flex(true)
