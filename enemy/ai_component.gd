extends Node2D
class_name AIComponent

const BEHAVIOR_SUMO_TEST := preload("uid://debbdm3js3xhj")
const BEHAVIOR_SUMO_TEST_BEHIND := preload("uid://bwecvphfv2it4")
const BEHAVIOR_SUMO_TEST_VICTORY := preload("uid://boxoonh0qnoxs")

var timers := [0.0, 0.0, 0.0, 0.0, 0.0]
var is_relaxing := [false, false, false, false, false]
var current_delay := [0.0, 0.0, 0.0, 0.0, 0.0]
var dead := false

@export var behavior: Behavior = null: set = set_behavior

@onready var creature: Creature = get_parent()


func _ready() -> void:
	if not is_instance_valid(behavior): set_behavior(BEHAVIOR_SUMO_TEST)


func _physics_process(delta: float) -> void:
	if dead: return
	tick_timers(delta)
	
	if not is_instance_valid(Global.player): return
	if not is_instance_valid(Global.player.body): return
	if behavior.id == BEHAVIOR_SUMO_TEST_VICTORY.id: return
	if Global.player.body.body.global_position.x > creature.body.body.global_position.x:
		set_behavior(BEHAVIOR_SUMO_TEST_BEHIND)
	elif Global.player.body.body.global_position.x < creature.body.body.global_position.x:
		set_behavior(BEHAVIOR_SUMO_TEST)


func tick_timers(delta: float) -> void:
	if not is_instance_valid(behavior): return
	
	for i in timers.size():
		var current_limb := creature.body.limbs[i]
		if not is_instance_valid(current_limb): continue
		
		timers[i] += delta
		if timers[i] >= current_delay[i]:
			current_limb.flex(is_relaxing[i])
			is_relaxing[i] = !is_relaxing[i]
			timers[i] = 0.0
			
			var current_duration := behavior.limb_relax_duration[i] if is_relaxing[i] else behavior.limb_contract_duration[i]
			current_delay[i] = randfn(current_duration, behavior.randomness[i])


func set_behavior(new_behavior: Behavior) -> void:
	if is_instance_valid(behavior):
		if behavior.id == new_behavior.id: return
	
	behavior = new_behavior
	#print(behavior.id)
	for i in timers.size():
		is_relaxing[i] = false
		timers[i] = 0.0
		var current_duration := behavior.limb_relax_duration[i] if is_relaxing[i] else behavior.limb_contract_duration[i]
		current_delay[i] = randfn(current_duration + behavior.limb_start_delay[i], behavior.randomness[i])


func _on_loss() -> void:
	set_behavior(BEHAVIOR_SUMO_TEST_VICTORY)
