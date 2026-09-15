extends Node2D
class_name Limb

@export var limb_stats: LimbStats ## Main limb stats.
@export var bonus_stats: LimbStats = limb_stats ## Stats of the limb that connects to the main limb. Leave empty to copy main limb stats.
#@export var flip_bonus := false ## If enabled, bonus limbs will rotate towards the opposite angular limit.

var body: Body = null

@export var limb_joint: RapierPinJoint2D ## This should be connected to the body (Node A).
@export var bonus_joint: RapierPinJoint2D ## This should be connected to the main limb (Node A).
@export var limb: RigidBody2D ## The limb which connects to the body.
@export var bonus_limb: RigidBody2D ## The limb which connects to the main limb.


#func _ready() -> void:
	#if not is_instance_valid(limb_joint): return
	#limb_joint.node_b = limb_joint.get_path_to(limb) # Bonus limb should already be set up in the limb scene.


func flex(is_flexed: bool) -> void:
	if not limb_stats.flip_orientation:
		limb_joint.motor_position_target_angle = limb_stats.angular_limit_upper if is_flexed else limb_stats.angular_limit_lower
	else:
		limb_joint.motor_position_target_angle = limb_stats.angular_limit_lower if is_flexed else limb_stats.angular_limit_upper
	
	if not is_instance_valid(bonus_limb): return
	if not bonus_stats.flip_orientation:
		bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_upper if is_flexed else bonus_stats.angular_limit_lower
	else:
		bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_lower if is_flexed else bonus_stats.angular_limit_upper


static func setup_joint(pin_joint: RapierPinJoint2D, ## So you don't have to mess with the individual joints when creating limbs.
		stats: LimbStats) -> void:
		#start_angle: float = stats.angular_limit_lower) -> void:
	pin_joint.motor_position_enabled = true
	pin_joint.motor_position_stiffness = stats.stiffness
	pin_joint.motor_position_damping = stats.damping
	pin_joint.softness = stats.softness
	pin_joint.angular_limit_enabled = true
	pin_joint.angular_limit_lower = stats.angular_limit_lower
	pin_joint.angular_limit_upper = stats.angular_limit_upper
	
	pin_joint.motor_position_target_angle = (stats.angular_limit_lower + stats.angular_limit_upper) / 2.0
