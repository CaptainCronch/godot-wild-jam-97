extends PinJoint2D
class_name AngularSpringJoint2D
## Adds torque to Node B based on difference to desired angle.

@export_range(0, 360, 0.1, "radians_as_degrees") var target_rotation := 0.0
@export var exponent_bonus := 3.0
@export var debug_label: Label

@onready var target_node: PhysicsBody2D = get_node(node_b)


func _init() -> void:
	motor_enabled = true
	motor_target_velocity = 0.0
	#angular_limit_enabled = true
	angular_limit_lower = -PI
	angular_limit_upper = PI


func _process(_delta: float) -> void:
	if is_instance_valid(debug_label):
		debug_label.text = str(rad_to_deg(angle_difference(target_node.rotation, target_rotation)))
		#debug_label.text = str(roundf(motor_target_velocity))
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var power := 2 ** (angle_difference(target_node.rotation, target_rotation) + exponent_bonus)
	#power *= 1.0 if target_node.rotation > target_rotation else -1.0
	
	motor_target_velocity = power


func _draw() -> void:
	draw_line(target_node.position, target_node.position + (Vector2.RIGHT * 20.0).rotated(target_rotation + target_node.rotation), Color.WHITE)	
