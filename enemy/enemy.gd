extends Node2D

const TEST_LIMBS := [
	preload("uid://xj4exedc2frc"),
	preload("uid://dnsl5n65j0isy"),
	preload("uid://cj35yvh70kyg6"),
	preload("uid://21goo8mxrnyp"),
]

@export var body: Body


func _ready() -> void:
	for limb in TEST_LIMBS: # for testinggggg
		await get_tree().create_timer(0.5).timeout
		body.add_limb(limb)
	body.body.set_collision_mask_value(1, false)
	body.body.set_collision_mask_value(2, true)
	body.body.set_collision_layer_value(2, false)
	body.body.set_collision_layer_value(1, true)
	for limb in body.limbs:
		if not is_instance_valid(limb): continue
		limb.limb.set_collision_mask_value(1, false)
		limb.limb.set_collision_mask_value(2, true)
		limb.limb.set_collision_layer_value(2, false)
		limb.limb.set_collision_layer_value(1, true)
		if limb.bonus_limb:
			limb.bonus_limb.set_collision_mask_value(1, false)
			limb.bonus_limb.set_collision_mask_value(2, true)
			limb.bonus_limb.set_collision_layer_value(2, false)
			limb.bonus_limb.set_collision_layer_value(1, true)

func _physics_process(delta: float) -> void:
	await get_tree().create_timer(5).timeout
	var limb = body.limbs.pick_random()
	if not is_instance_valid(limb): return
	var rng = RandomNumberGenerator.new()
	limb.flex(true)
	get_tree().create_timer(rng.randi_range(3, 5)).timeout.connect(func(): limb.flex(false))
