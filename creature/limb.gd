extends Node2D
class_name Limb

@export var limb_stats: LimbStats ## Main limb stats.
@export var bonus_stats: LimbStats = limb_stats ## Stats of the limb that connects to the main limb. Leave empty to copy main limb stats.
#@export var flip_bonus := false ## If enabled, bonus limbs will rotate towards the opposite angular limit.

var body: Body = null

@export var limb_joint: RapierPinJoint2D ## This should be connected to the body (Node A). Starts empty.
@export var limb: RigidBody2D ## The limb which connects to the body.
@export var limb_polygon: Polygon2D
@export var limb_collider: CollisionPolygon2D

var backwards := false

@export var bonus_joint: RapierPinJoint2D ## This should be connected to the main limb (Node A).
@export var bonus_limb: RigidBody2D ## The limb which connects to the main limb.
@export var bonus_polygon: Polygon2D
@export var bonus_collider: CollisionPolygon2D


func _ready() -> void:
	limb.connect("input_event", on_input_event)
	var gravity := 1.0
	if not limb_stats.slot == LimbStats.Slot.ARM and \
			not limb_stats.slot == LimbStats.Slot.LEG and \
			is_instance_valid(body):
		gravity = 0.0
	limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	limb.gravity_scale = gravity
	#if not limb_stats.slot == LimbStats.Slot.LEG and not limb_stats.slot == LimbStats.Slot.ARM:
		#limb.collision_mask = 1
	if not is_instance_valid(bonus_limb): return
	bonus_limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	bonus_limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	bonus_limb.gravity_scale = gravity
	Limb.setup_joint(bonus_joint, bonus_stats)
	#if not bonus_stats.slot == LimbStats.Slot.LEG and not bonus_stats.slot == LimbStats.Slot.ARM:
		#bonus_limb.collision_mask = 1
	#if not is_instance_valid(limb_joint): return
	#limb_joint.node_b = limb_joint.get_path_to(limb) # Bonus limb should already be set up in the limb scene.


func flex(is_flexed: bool) -> void:
	var direction := is_flexed != backwards # XOR
	
	if direction != limb_stats.flip_orientation:
		limb_joint.motor_position_target_angle = limb_stats.angular_limit_upper
	else:
		limb_joint.motor_position_target_angle = limb_stats.angular_limit_lower
	
	if not is_instance_valid(bonus_limb): return
	if direction != bonus_stats.flip_orientation:
		bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_upper
	else:
		bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_lower


func flip() -> void:
	backwards = not backwards
	limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	
	limb.position.x *= -1.0
	limb_polygon.polygon = reverse_points(limb_polygon.polygon)
	limb_polygon.texture_offset.x *= -1.0
	#limb_polygon.texture_rotation *= -1.0
	limb_polygon.texture_scale.x *= -1.0
	limb_polygon.position.x *= -1.0
	limb_collider.polygon = reverse_points(limb_collider.polygon)
	limb_collider.position.x *= -1.0
	
	var angle_holder := limb_stats.angular_limit_lower * -1.0
	limb_stats.angular_limit_lower = limb_stats.angular_limit_upper * -1.0
	limb_stats.angular_limit_upper = angle_holder
	
	if not is_instance_valid(bonus_limb): return
	bonus_limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	bonus_limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	
	bonus_limb.position.x *= -1.0
	bonus_polygon.polygon = reverse_points(bonus_polygon.polygon)
	bonus_polygon.position.x *= -1.0
	bonus_collider.polygon = reverse_points(bonus_collider.polygon)
	bonus_collider.position.x *= -1.0
	bonus_joint.node_b = ""
	bonus_joint.position.x *= -1.0
	bonus_joint.node_b = bonus_joint.get_path_to(bonus_limb)
	
	var bonus_holder := bonus_stats.angular_limit_lower * -1.0
	bonus_stats.angular_limit_lower = bonus_stats.angular_limit_upper * -1.0
	bonus_stats.angular_limit_upper = bonus_holder


func die() -> void:
	if is_instance_valid(limb_joint):
		limb_joint.node_b = ""
	limb_joint = null
	reparent(get_tree().current_scene)
	var launch := Vector2(randf_range(-200, 200), randf_range(-500, -700))
	var spin := randf_range(-20, 20)
	limb.linear_velocity = launch
	limb.angular_velocity = spin
	limb.gravity_scale = 1.0
	if is_instance_valid(bonus_limb):
		bonus_joint.node_a = bonus_joint.get_path_to(limb)
		bonus_joint.node_b = bonus_joint.get_path_to(bonus_limb)
		bonus_limb.linear_velocity = launch
		bonus_limb.angular_velocity = spin
		bonus_limb.gravity_scale = 1.0
	
	if limb_stats.slot == LimbStats.Slot.HEAD:
		Global.camera.add_target(limb)
		await get_tree().create_timer(1.0).timeout
		Global.camera.remove_target(limb)


func reverse_points(points: PackedVector2Array) -> PackedVector2Array:
	var copy := points.duplicate()
	for i in copy.size():
		copy[i].x *= -1.0
	return copy


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
	
	pin_joint.motor_position_target_angle = stats.angular_limit_lower
	#pin_joint.motor_position_target_angle = (stats.angular_limit_lower + stats.angular_limit_upper) / 2.0

func on_input_event(_viewport : Node, event : InputEvent, _idx : int) -> void:
		print("touch!")
		if event.button_index == MOUSE_BUTTON_LEFT:
			queue_free()
