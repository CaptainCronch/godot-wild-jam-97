extends Node2D
class_name SumoLevel

var player: Creature
var enemy: Creature
var end_tween: Tween

@export var left_spawn: Marker2D
@export var right_spawn: Marker2D
@export var camera: MultitargetCamera2D
@export var color_rect: ColorRect


func _enter_tree() -> void:
	Global.sumo_level = self


func _ready() -> void:
	player = Global.CREATURE.instantiate()
	player.is_player = true
	add_child(player)
	
	var input_comp := Global.INPUT_COMPONENT.instantiate()
	player.add_child(input_comp)
	player.global_position = left_spawn.global_position
	player.died.connect(_on_creature_died)
	
	#for limb_file in Global.player_pieces:
		#player_body.add_limb(load(limb_file))
	
	enemy = Global.CREATURE.instantiate()
	enemy.flip = true
	add_child(enemy)
	
	var ai_comp := Global.AI_COMPONENT.instantiate()
	enemy.ai_comp = ai_comp
	enemy.add_child(ai_comp)
	enemy.global_position = right_spawn.global_position
	enemy.died.connect(_on_creature_died)
	
	#var enemy_body: Body = ???
	#enemy.body = enemy_body
	#enemy.add_child(enemy_body)
	#
	#for limb_file in ???:
		#enemy_body.add_limb(load(limb_file))


func _on_creature_died(creature: Creature) -> void:
	camera.remove_target(creature.body.body)
	
	if is_instance_valid(end_tween): return
	
	end_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	end_tween.tween_interval(2.5)
	end_tween.tween_callback(func(): get_tree().paused = true)
	#end_tween.tween_interval(0.5)
	end_tween.tween_property(color_rect, "color", Color.BLACK, 0.5)
	end_tween.tween_callback(func(): get_tree().paused = false)
	if not creature.is_player:
		end_tween.tween_callback(func(): get_tree().change_scene_to_file("uid://bjviy5ac43lwa"))
	else:
		end_tween.tween_callback(func(): get_tree().change_scene_to_file("uid://b8l7b6elncmkp"))
		#end_tween.tween_property($CanvasLayer/Label, "visible", true, 0.1) # lol
		pass # change to end screen scene
