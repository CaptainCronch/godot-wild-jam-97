extends Node2D
class_name Creature

signal died(creature: Creature)

const LIMB_KEY := preload("uid://gpt5rd33ocw5")
const GIBS := preload("uid://yyobgug6ans2")

var limb_key_displays: Array[LimbKey] = [null, null, null, null, null]

@export var is_player := false
@export var flip := false

@export var body: Body
@export var ai_comp: AIComponent


func _enter_tree() -> void:
	if is_player:
		Global.player = self
		#if not is_instance_valid(Global.player_body_file):
			#Global.player_body_file = "res://creature/bodies/test_body.tscn" # FALLBACK BODY
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
		body.add_limb(load(Global.LEGS.pick_random()))
		body.add_limb(load(Global.ARMS.pick_random()))
		body.add_limb(load(Global.HEADS.pick_random()))
		body.add_limb(load(Global.TAILS.pick_random()))


func add_key_display(limb_stats: LimbStats) -> void:
	if not is_player: return
	if is_instance_valid(limb_key_displays[limb_stats.slot]): 
		limb_key_displays[limb_stats.slot].queue_free()
	var display: LimbKey = LIMB_KEY.instantiate()
	display.target_body = body
	#display.global_position = body.global_position
	display.backdrop.position = position
	add_child(display)
	#display.global_position = body.body.global_position
	display.set_key(limb_stats.key)
	limb_key_displays[limb_stats.slot] = display
	
	for i in limb_key_displays.size():
		if is_instance_valid(limb_key_displays[i]):
			limb_key_displays[i].rotation_offset = ((TAU / float(limb_key_displays.size())) * i) + body.key_display_offset


func die() -> void:
	died.emit(self)
	if is_instance_valid(ai_comp): ai_comp.dead = true
	for limb in body.limbs:
		if not is_instance_valid(limb): continue
		if not is_player: Global.loser_pieces.append(limb.scene_file_path)
		limb.die()
	
	var gib_particles: CPUParticles2D = GIBS.instantiate()
	gib_particles.global_position = body.body.global_position
	gib_particles.emitting = true
	get_tree().current_scene.add_child(gib_particles)
	
	for display in limb_key_displays:
		if is_instance_valid(display): display.queue_free()
	body.queue_free()


func _on_prepause() -> void:
	for display in limb_key_displays:
		if is_instance_valid(display):
			display.spinner.global_rotation = display.rotation_offset
			display.backdrop.global_position = display.holder.global_position
