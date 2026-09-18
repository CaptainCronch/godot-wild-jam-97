extends Node2D
class_name Creature

signal died(creature: Creature)

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
	if is_player:
		Global.player = self
		if not is_instance_valid(Global.player_body_file):
			Global.player_body_file = "res://creature/bodies/test_body.tscn" # FALLBACK BODY
		
		body = load(Global.player_body_file).instantiate()
		add_child(body)
	else:
		body = load(Global.BODIES.pick_random()).instantiate()
		add_child(body)


func _ready() -> void:
	if is_instance_valid(body):
		Global.camera.add_target(body.body)
		if flip: body.flip()
	
	if is_player:
		for i in Global.player_pieces.size():
			body.add_limb(load(Global.player_pieces[i]), Global.player_piece_keys[i])
	else:
		pass # pick random enemy limbs


func die() -> void:
	died.emit(self)
	if is_instance_valid(ai_comp): ai_comp.dead = true
	for limb in body.limbs:
		if not is_instance_valid(limb): continue
		if not is_player: Global.loser_pieces.append(limb.scene_file_path)
		limb.die()
	body.queue_free()
