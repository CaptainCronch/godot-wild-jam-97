extends Node2D
class_name Shop

const START_LIMBS := 4
const INPUT_COMPONENT := preload("uid://c1q66rs8180kh")

@export var spawn_range := 100.0

var player: Creature
var shop_limbs: Array[Limb] = []
var selection: Array = []
var current_selection_index := 0

@export var camera: MultitargetCamera2D

@onready var shop_limb_spawner: Marker2D = $ShopLimbSpawner
@onready var loser_limb_spawner: Marker2D = $LoserLimbSpawner
@onready var creature_spawn_pos: Marker2D = $CreatureSpawnPos
@onready var next: Label = $Next
@onready var reroll: Label = $Reroll


func _ready() -> void:
	player = Global.CREATURE.instantiate()
	player.is_player = true
	#var body: Body = load(Global.player_body_file).instantiate() # creature script spawns its own body so don't worry
	#player.add_child(body)
	#player.body = body
	add_child(player)
	var input_comp := INPUT_COMPONENT.instantiate()
	player.add_child(input_comp)
	player.global_position = creature_spawn_pos.global_position
	
	if Global.loser_pieces.is_empty():
		var start_leg: String = Global.LEGS.pick_random()
		spawn_limb(load(start_leg), shop_limb_spawner.global_position) # always spawn one leg to start with
		
		var bag: Array[String] = Global.HEADS.duplicate()
		bag.append_array(Global.ARMS)
		bag.append_array(Global.LEGS)
		bag.append_array(Global.TAILS)
		bag.append_array(Global.BACKS)
		bag.erase(start_leg)
		
		for i in START_LIMBS - 1: # minus one because you already get a guaranteed leg
			var pick: String = bag.pick_random()
			bag.erase(pick)
			spawn_limb(load(pick), shop_limb_spawner.global_position)
	else:
		for limb_file in Global.loser_pieces:
			spawn_limb(load(limb_file), loser_limb_spawner.global_position)
	
	update_selected(1)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("select_next"):
		update_selected(1)
	elif event.is_action_released("select_previous"):
		update_selected(-1)
	elif event.is_action_released("select_confirm"):
		select_limb()


func spawn_limb(limb_scene: PackedScene, spawn_position: Vector2) -> void:
	var limb: Limb = limb_scene.instantiate()
	limb.global_position = spawn_position + Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
	limb.in_shop = true
	limb.limb_stats.pick_random_key()
	if is_instance_valid(limb.bonus_stats): limb.bonus_stats.key = limb.limb_stats.key
	add_child(limb)
	shop_limbs.append(limb)


func update_selected(increment: int) -> void:
	selection = [reroll]
	selection.append_array(shop_limbs)
	selection.append(next)
	
	#if shop_limbs.is_empty(): current_selection_index = 0; return
	if current_selection_index <= selection.size() - 1:
		selection[current_selection_index].select(false)
	
	current_selection_index += increment
	if current_selection_index > selection.size() - 1: current_selection_index = 0
	elif current_selection_index < 0: current_selection_index = selection.size() - 1
	#print(current_selection_index)
	selection[current_selection_index].select(true)


func select_limb() -> void:
	if current_selection_index == 0: # reroll
		
		return
	elif current_selection_index == selection.size() - 1: # next
		Global.player_pieces = []
		Global.player_piece_keys = []
		Global.picked_keys = ""
		for limb in player.body.limbs:
			if is_instance_valid(limb):
				Global.player_pieces.append(limb.scene_file_path)
				Global.player_piece_keys.append(limb.limb_stats.key)
				Global.picked_keys += limb.limb_stats.key
		get_tree().change_scene_to_file("res://environment/arena/test_level.tscn")
		return
	
	if shop_limbs.is_empty(): return
	var limb_key: String = selection[current_selection_index].limb_stats.key
	var new_limb: PackedScene = load(selection[current_selection_index].scene_file_path)
	player.body.add_limb(new_limb, limb_key)
	
	selection[current_selection_index].select(false)
	selection[current_selection_index].queue_free()
	shop_limbs.remove_at(current_selection_index - 1)
	update_selected(-1)


#func refresh_shop() -> void:
	#pass


func leave_shop() -> void:
	Global.loser = null
