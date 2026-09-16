extends Node2D
class_name Creature

const TEST_LIMBS := [
	preload("uid://xj4exedc2frc"),
	preload("uid://dnsl5n65j0isy"),
	preload("uid://cj35yvh70kyg6"),
	preload("uid://21goo8mxrnyp"),
]

@export var is_player := false
@export var flip := false

@export var body: Body
@export var ai_comp: AIComponent


func _enter_tree() -> void:
	if is_player: Global.player = self


func _ready() -> void:
	if is_instance_valid(body):
		Global.camera.add_target(body.body)
		if flip:
			body.flip()
	# spawn body
	#body.flip = true
	#add_child(body)
	
	for limb in TEST_LIMBS: # for testinggggg
		#await get_tree().create_timer(0.5).timeout
		body.add_limb(limb)


func die() -> void:
	if is_instance_valid(ai_comp): ai_comp.dead = true
	Global.camera.remove_target(body.body)
	var limbs := body.limbs
	for limb in limbs:
		if not is_instance_valid(limb): continue
		limb.die()
	body.queue_free()
