extends Limb
class_name FloppyLimb

func _ready() -> void:
	super()
	flex(false)

func flex(is_flexed: bool) -> void:
	var direction := is_flexed != backwards # XOR
	if is_instance_valid(limb_joint):
		if direction != limb_stats.flip_orientation:
			limb_joint.angular_limit_enabled = false
			limb_joint.motor_position_enabled = false
			limb_joint.motor_position_target_angle = limb_stats.angular_limit_upper
		else:
			limb_joint.motor_position_enabled = true
			limb_joint.motor_position_target_angle = limb_stats.angular_limit_lower
	
	if is_instance_valid(bonus_limb):
		if direction != bonus_stats.flip_orientation:
			bonus_joint.angular_limit_enabled = false
			bonus_joint.motor_position_enabled = false
			bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_upper
		else:
			bonus_joint.motor_position_enabled = true
			bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_lower

static func setup_joint(pin_joint: RapierPinJoint2D, ## So you don't have to mess with the individual joints when creating limbs.
		stats: LimbStats) -> void:
		#start_angle: float = stats.angular_limit_lower) -> void:
	pin_joint.motor_position_enabled = true
	pin_joint.motor_position_stiffness = stats.stiffness
	pin_joint.motor_position_damping = stats.damping
	pin_joint.softness = stats.softness
	pin_joint.angular_limit_enabled = false
	
	#pin_joint.motor_position_target_angle = stats.angular_limit_lower
	pin_joint.motor_position_target_angle = stats.angular_limit_upper if stats.flip_orientation else stats.angular_limit_lower
	#pin_joint.motor_position_target_angle = (stats.angular_limit_lower + stats.angular_limit_upper) / 2.0
