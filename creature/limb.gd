extends Node2D
class_name Limb

const SHOP_BITS: Array[int] = [8, 9]
const IMPACT_THRESHOLD := 50.0

@export var limb_stats: LimbStats ## Main limb stats.
@export var bonus_stats: LimbStats = limb_stats ## Stats of the limb that connects to the main limb.
#@export var flip_bonus := false ## If enabled, bonus limbs will rotate towards the opposite angular limit.
@export var bark_delay := 0.0

@export var bite_area: Area2D
@export var halo: Sprite2D
@export var sound_on: AudioStreamPlayer2D
@export var sound_off: AudioStreamPlayer2D
@export var impact_sound: AudioStreamPlayer2D

var body: Body = null
var direction := false
var backwards := false
var in_shop := false
var started_bark := false
var bark_timer := 0.0

@export var limb_joint: RapierPinJoint2D ## This should be connected to the body (Node A). Starts empty.
@export var limb: RigidBody2D ## The limb which connects to the body.
#@export var limb_polygon: Polygon2D
@export var limb_collider: CollisionPolygon2D
@export var limb_sprite: Sprite2D

@export var bonus_joint: RapierPinJoint2D ## This should be connected to the main limb (Node A).
@export var bonus_limb: RigidBody2D ## The limb which connects to the main limb.
#@export var bonus_polygon: Polygon2D
@export var bonus_collider: CollisionPolygon2D
@export var bonus_sprite: Sprite2D


func _ready() -> void:
	halo.hide()
	if is_instance_valid(sound_on): sound_on.volume_db = 18.0
	var gravity := 1.0
	if not limb_stats.slot == LimbStats.Slot.ARM and \
			not limb_stats.slot == LimbStats.Slot.LEG and \
			is_instance_valid(body):
		gravity = 0.0
	limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	limb.gravity_scale = gravity
	limb.contact_monitor = true
	limb.max_contacts_reported = 1
	limb.body_entered.connect(_on_impact)
	
	if in_shop:
		limb.collision_layer = SHOP_BITS[0]
		limb.collision_mask = SHOP_BITS[1]
	
	#if not limb_stats.slot == LimbStats.Slot.LEG and not limb_stats.slot == LimbStats.Slot.ARM:
		#limb.collision_mask = 1
	if not is_instance_valid(bonus_limb): return
	bonus_limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	bonus_limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	bonus_limb.gravity_scale = gravity
	bonus_limb.contact_monitor = true
	bonus_limb.max_contacts_reported = 1
	bonus_limb.body_entered.connect(_on_impact)
	
	if in_shop:
		bonus_limb.collision_layer = SHOP_BITS[0]
		bonus_limb.collision_mask = SHOP_BITS[1]
	
	Limb.setup_joint(bonus_joint, bonus_stats)
	
	if is_instance_valid(bite_area):
		if not in_shop:
			bite_area.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
			bite_area.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]


func _process(delta: float) -> void:
	halo.global_rotation = 0.0
	if bark_timer <= bark_delay: bark_timer += delta


func _physics_process(_delta: float) -> void:
	if is_instance_valid(body) and not is_zero_approx(limb_stats.body_torque):
		body.body.constant_torque = limb_stats.body_torque * (-1.0 if direction else 1.0)


func flex(is_flexed: bool) -> void:
	direction = is_flexed != backwards # XOR
	
	if is_instance_valid(limb_joint):
		if direction != limb_stats.flip_orientation:
			limb_joint.motor_position_target_angle = limb_stats.angular_limit_upper
		else:
			limb_joint.motor_position_target_angle = limb_stats.angular_limit_lower
	
	if is_instance_valid(bonus_limb):
		if direction != bonus_stats.flip_orientation:
			bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_upper
		else:
			bonus_joint.motor_position_target_angle = bonus_stats.angular_limit_lower
	
	if bark_delay > 0.0:
		if is_flexed and not started_bark:
			started_bark = true
			bark_timer = 0.0
		elif not is_flexed and started_bark:
			started_bark = false
			if bark_timer < bark_delay:
				bark_timer = bark_delay
				if is_instance_valid(sound_on): sound_on.play()
			else:
				bite()
	else:
		if is_flexed and not started_bark:
			if is_instance_valid(sound_on): sound_on.play()
			started_bark = true
		elif not is_flexed and started_bark:
			if is_instance_valid(sound_off): sound_off.play()
			started_bark = false


func flip() -> void:
	backwards = not backwards
	limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	
	limb.position.x *= -1.0
	if limb_sprite: 
		limb_sprite.flip_h = true
		limb_sprite.position.x *= -1.0
	#limb_polygon.polygon = reverse_points(limb_polygon.polygon)
	#limb_polygon.texture_offset.x *= -1.0
	#limb_polygon.texture_rotation *= -1.0
	#limb_polygon.texture_scale.x *= -1.0
	#limb_polygon.position.x *= -1.0
	limb_collider.polygon = reverse_points(limb_collider.polygon)
	limb_collider.position.x *= -1.0
	
	var angle_holder := limb_stats.angular_limit_lower * -1.0
	limb_stats.angular_limit_lower = limb_stats.angular_limit_upper * -1.0
	limb_stats.angular_limit_upper = angle_holder
	
	if not is_instance_valid(bonus_limb): return
	bonus_limb.collision_layer = body.LEFT_BITS[0] if backwards else body.RIGHT_BITS[0]
	bonus_limb.collision_mask = body.LEFT_BITS[1] if backwards else body.RIGHT_BITS[1]
	
	bonus_limb.position.x *= -1.0
	#bonus_polygon.polygon = reverse_points(bonus_polygon.polygon)
	#bonus_polygon.position.x *= -1.0
	bonus_collider.polygon = reverse_points(bonus_collider.polygon)
	bonus_collider.position.x *= -1.0
	bonus_joint.node_b = ""
	bonus_joint.position.x *= -1.0
	bonus_joint.node_b = bonus_joint.get_path_to(bonus_limb)
	if bonus_sprite: 
		bonus_sprite.flip_h = true
		bonus_sprite.position.x *= -1.0
	
	var bonus_holder := bonus_stats.angular_limit_lower * -1.0
	bonus_stats.angular_limit_lower = bonus_stats.angular_limit_upper * -1.0
	bonus_stats.angular_limit_upper = bonus_holder


func bite() -> void:
	if not is_instance_valid(bite_area): return
	for bited in bite_area.get_overlapping_bodies():
		var parent := bited.get_parent()
		if parent is Body:
			parent.body.apply_central_impulse(Vector2(limb_stats.bite_knockback * (-1.0 if backwards else 1.0), 0.0))
			if is_instance_valid(body):
				body.body.apply_central_impulse(Vector2(limb_stats.self_knockback * (-1.0 if backwards else 1.0), 0.0))
			impact_sound.play()


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


func select(is_selected: bool) -> void:
	if is_selected:
		z_index = 1
		halo.show()
		Global.camera.add_target(limb)
	else:
		z_index = 0
		halo.hide()
		Global.camera.remove_target(limb)
	flex(is_selected)


func _on_impact(_body: Node) -> void:
	if not in_shop: return
	if limb.linear_velocity.length() < IMPACT_THRESHOLD: return
	if not is_instance_valid(impact_sound): return
	if impact_sound.playing: return
	impact_sound.play()


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
	
	#pin_joint.motor_position_target_angle = stats.angular_limit_lower
	pin_joint.motor_position_target_angle = stats.angular_limit_upper if stats.flip_orientation else stats.angular_limit_lower
	#pin_joint.motor_position_target_angle = (stats.angular_limit_lower + stats.angular_limit_upper) / 2.0


#func on_input_event(_viewport: Node, event: InputEvent, _idx: int) -> void:
		#print("touch!")
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#queue_free()
