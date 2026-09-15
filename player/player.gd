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


func _unhandled_key_input(event: InputEvent) -> void:
	for limb in body.limbs:
		if not is_instance_valid(limb): continue
		if limb.limb_stats.key == event.as_text():
			limb.flex(event.is_pressed())
