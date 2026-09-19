extends Node2D
class_name Shop

const START_LIMBS := 4
const INPUT_COMPONENT := preload("uid://c1q66rs8180kh")

@export var spawn_range := 80.0

var player: Creature
var shop_limbs: Array[Limb] = []
var selection: Array = []
var current_selection_index := 0
var money := 8 # 1 extra because the game rerolls shop on scene start

@export var camera: MultitargetCamera2D

@onready var shop_limb_spawner: Marker2D = $ShopLimbSpawner
@onready var loser_limb_spawner: Marker2D = $LoserLimbSpawner
@onready var creature_spawn_pos: Marker2D = $CreatureSpawnPos
@onready var next: Sprite2D = $Environment/Next
@onready var reroll: Sprite2D = $Environment/Reroll
@onready var shopkeep_tail: Sprite2D = $Environment/ShopkeepBody/ShopkeepTail
@onready var shopkeep_left_eye: Sprite2D = $Environment/ShopkeepBody/ShopkeepHead/LeftEye
@onready var shopkeep_right_eye: Sprite2D = $Environment/ShopkeepBody/ShopkeepHead/RightEye
@onready var shopkeep_head: Sprite2D = $Environment/ShopkeepBody/ShopkeepHead
@onready var chalkboard_label: Label = $Environment/Chalkboard/ChalkboardLabel


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
	
	reroll_shop()
	
	update_selected(0)
	
	var tail_tween := create_tween().set_loops().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_BOUNCE)
	tail_tween.tween_property(shopkeep_tail, "rotation", deg_to_rad(25.0), 15.0)
	tail_tween.tween_property(shopkeep_tail, "rotation", deg_to_rad(-25.0), 15.0)
	
	var eyes_tween := create_tween().set_loops().set_parallel()
	eyes_tween.tween_interval(12.0)
	eyes_tween.chain().tween_property(shopkeep_left_eye, "scale:y", 0.0, 0.01)
	eyes_tween.tween_property(shopkeep_right_eye, "scale:y", 0.0, 0.01)
	eyes_tween.chain().tween_interval(0.2)
	eyes_tween.chain().tween_property(shopkeep_left_eye, "scale:y", 1.0, 0.01)
	eyes_tween.tween_property(shopkeep_right_eye, "scale:y", 1.0, 0.01)
	
	var head_tween := create_tween().set_loops().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	head_tween.tween_property(shopkeep_head, "rotation", deg_to_rad(3.0), 10.0)
	head_tween.tween_property(shopkeep_head, "rotation", deg_to_rad(-3.0), 10.0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("select_next"):
		update_selected(1)
	elif event.is_action_released("select_previous"):
		update_selected(-1)
	elif event.is_action_released("select_confirm"):
		select_limb()


func spawn_limb(limb_scene: PackedScene, spawn_position: Vector2) -> void:
	var limb: Limb = limb_scene.instantiate()
	limb.global_position = spawn_position + Vector2(randf_range(-spawn_range, spawn_range), 0.0)# randf_range(-spawn_range, spawn_range))
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
	
	if selection[current_selection_index] is Limb:
		var stats: LimbStats = selection[current_selection_index].limb_stats
		var chalkboard_text := "{0}\n{1}\nKey: {2}\nPower: {3}\nCredits left: {4}"
		chalkboard_text = chalkboard_text.format([stats.name, stats.description, stats.key, int(stats.stiffness / 10000.0), money])
		chalkboard_label.text = chalkboard_text
	elif selection[current_selection_index] == next:
		chalkboard_label.text = "Next round"
	elif selection[current_selection_index] == reroll:
		chalkboard_label.text = "Reroll shop\n\n\n\nCredits left: " + str(money)


func select_limb() -> void:
	if current_selection_index == 0: # reroll
		reroll_shop()
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
		Global.loser_pieces.clear()
		get_tree().change_scene_to_file("res://environment/arena/test_level.tscn")
		return
	
	if shop_limbs.is_empty(): return
	if money < 3: return
	money -= 3
	var limb_key: String = selection[current_selection_index].limb_stats.key
	var new_limb: PackedScene = load(selection[current_selection_index].scene_file_path)
	player.body.add_limb(new_limb, limb_key)
	
	selection[current_selection_index].select(false)
	selection[current_selection_index].queue_free()
	shop_limbs.remove_at(current_selection_index - 1)
	update_selected(0)


func reroll_shop() -> void:
	if money < 1: return
	money -= 1
	
	for limb in shop_limbs:
		limb.queue_free()
	shop_limbs = []
	
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
		var bag := Global.limb_files.duplicate()
		
		for i in START_LIMBS:
			var pick: String = bag.pick_random()
			bag.erase(pick)
			spawn_limb(load(pick), shop_limb_spawner.global_position)
	
	for limb_file in Global.loser_pieces:
		spawn_limb(load(limb_file), loser_limb_spawner.global_position)
	
	update_selected(0)


#func refresh_shop() -> void:
	#pass


func leave_shop() -> void:
	Global.loser = null
