extends Node2D
class_name Body

const RIGHT_BITS := [2, 5] # [(2), (1, 3)]
const LEFT_BITS := [4, 3] # [(3), (1, 2)]

@export var self_righting_torque := 10000000.0
@export var self_righting_range := deg_to_rad(120.0)
#@export var max_angular_velocity := 4.5
@export var flipped := false
#@export_flags_2d_physics var right_layers := 0
#@export_flags_2d_physics var right_masks := 0
#@export_flags_2d_physics var left_layers := 0
#@export_flags_2d_physics var left_masks := 0

var limbs: Array[Limb] = [null, null, null, null, null] ## [head, arm, leg, tail, back], from LimbStats.Slot enum.

@export var body: RigidBody2D
@export var polygon2d: Polygon2D
@export var collider: CollisionPolygon2D
@export var positions: Array[Marker2D] = [null, null, null, null, null]
@export var joints: Array[RapierPinJoint2D] = [null, null, null, null, null]
@export var body_sprite: Sprite2D
@onready var creature: Creature = $".."


func _ready() -> void:
	body.collision_layer = LEFT_BITS[0] if flipped else RIGHT_BITS[0]
	body.collision_mask = LEFT_BITS[1] if flipped else RIGHT_BITS[1]
	#print("right layers: {rl}, right masks: {rm}, left layers: {ll}, left masks: {lm}, ".format({"rl": right_layers, "rm": right_masks, "ll": left_layers, "lm": left_masks}))
	#flip = bool(randi_range(0, 1))
	
	for i in joints.size():
		joints[i].position = positions[i].position
		joints[i].node_a = joints[i].get_path_to(body)
	
	#body.apply_torque_impulse(randi_range(-100000, 100000)) # testing


func _physics_process(delta: float) -> void:
	var force := clampf(remap(
			body.rotation,
			-self_righting_range,
			self_righting_range,
			self_righting_torque,
			-self_righting_torque),
			-self_righting_torque,
			self_righting_torque)
	body.apply_torque(force * delta)
	
	#$Label.text = str("yes" if absf(body.angular_velocity) >= max_angular_velocity else "no")
	#body.angular_velocity = clampf(body.angular_velocity, -max_angular_velocity, max_angular_velocity)


func add_limb(limb_scene: PackedScene, key: String = "") -> void:#, limb_stats: LimbStats = null, bonus_stats: LimbStats = null) -> void:
	var limb: Limb = limb_scene.instantiate()
	if flipped: limb.flip()
	#if is_instance_valid(limb_stats): limb.limb_stats = limb_stats
	#if is_instance_valid(bonus_stats): limb.bonus_stats = bonus_stats
	if not key.is_empty():
		limb.limb_stats.key = key
		if is_instance_valid(limb.bonus_stats): limb.bonus_stats.key = key
	
	var anchor_pos := positions[limb.limb_stats.slot].global_position
	limb.limb_joint = joints[limb.limb_stats.slot]
	
	if is_instance_valid(limbs[limb.limb_stats.slot]): limbs[limb.limb_stats.slot].queue_free()
	limbs[limb.limb_stats.slot] = limb
	limb.body = self
	add_child(limb)
	joints[limb.limb_stats.slot].global_position = anchor_pos
	limb.rotation = body.rotation
	limb.global_position = anchor_pos
	
	joints[limb.limb_stats.slot].node_b = joints[limb.limb_stats.slot].get_path_to(limb.limb)
	
	Limb.setup_joint(joints[limb.limb_stats.slot], limb.limb_stats)
	#if is_instance_valid(limb.bonus_joint):
		#Limb.setup_joint(limb.bonus_joint, limb.bonus_stats)
	
	creature.add_key_display(limb.limb_stats)


func remove_limb(slot: LimbStats.Slot) -> void:
	limbs[slot].queue_free()
	limbs[slot] = null
	joints[slot].node_b = ""


func flip() -> void:
	flipped = not flipped
	body.collision_layer = LEFT_BITS[0] if flipped else RIGHT_BITS[0]
	body.collision_mask = LEFT_BITS[1] if flipped else RIGHT_BITS[1]
	
	var polygon2d_polygon := polygon2d.polygon
	for i in polygon2d.polygon.size():
		polygon2d_polygon[i].x *= -1.0
	polygon2d.polygon = polygon2d_polygon
	polygon2d.position.x *= -1.0
	
	var collider_polygon := collider.polygon
	for i in collider.polygon.size():
		collider_polygon[i].x *= -1.0
	collider.polygon = collider_polygon
	collider.position.x *= -1.0
	
	if  body_sprite:
		body_sprite.flip_h = true
	
	for marker in positions:
		marker.position.x *= -1.0
