extends Node2D
class_name Body

@export var body_self_righting_torque := 5000000.0
@export var body_self_righting_range := deg_to_rad(90.0)

var limbs: Array[Limb] = [null, null, null, null, null] ## [head, arm, leg, tail, back], from LimbStats.Slot enum.

@export var body: RigidBody2D
@export var positions: Array[Marker2D] = [null, null, null, null, null]
@export var joints: Array[RapierPinJoint2D] = [null, null, null, null, null]


func _ready() -> void:
	for i in joints.size():
		joints[i].position = positions[i].position
		joints[i].node_a = joints[i].get_path_to(body)
	
	#body.apply_torque_impulse(randi_range(-100000, 100000)) # testing


func _physics_process(delta: float) -> void:
	var force := clampf(remap(
			body.rotation,
			-body_self_righting_range,
			body_self_righting_range,
			body_self_righting_torque,
			-body_self_righting_torque),
			-body_self_righting_torque,
			body_self_righting_torque)
	body.apply_torque(force * delta)


func add_limb(limb_scene: PackedScene, limb_stats: LimbStats = null, bonus_stats: LimbStats = null) -> void:
	var limb: Limb = limb_scene.instantiate()
	if is_instance_valid(limb_stats): limb.limb_stats = limb_stats
	if is_instance_valid(bonus_stats): limb.bonus_stats = bonus_stats
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
	if is_instance_valid(limb.bonus_joint):
		Limb.setup_joint(limb.bonus_joint, limb.bonus_stats)


func remove_limb(slot: LimbStats.Slot) -> void:
	limbs[slot].queue_free()
	limbs[slot] = null
	joints[slot].node_b = ""
