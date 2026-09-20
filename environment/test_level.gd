extends Node2D
class_name SumoLevel

signal loss

const COUNT_3 := preload("uid://c7yxmnq38xrje")
const COUNT_2 := preload("uid://crub6x6mx82fc")
const COUNT_1 := preload("uid://bjtbvyfse2kdu")
const COUNT_GO := preload("uid://bxr8w4auahbq")
const COUNT_DELAY := 0.5

var player: Creature
var enemy: Creature
var end_tween: Tween

@export var left_spawn: Marker2D
@export var right_spawn: Marker2D
@export var camera: MultitargetCamera2D
@export var color_rect: ColorRect
@export var counter: TextureRect


func _enter_tree() -> void:
	Global.sumo_level = self


func _ready() -> void:
	player = Global.CREATURE.instantiate()
	player.is_player = true
	add_child(player)
	
	var input_comp := Global.INPUT_COMPONENT.instantiate()
	player.global_position = left_spawn.global_position
	player.add_child(input_comp)
	player.died.connect(_on_creature_died)
	
	#for limb_file in Global.player_pieces:
		#player_body.add_limb(load(limb_file))
	
	enemy = Global.CREATURE.instantiate()
	enemy.flip = true
	add_child(enemy)
	
	var ai_comp := Global.AI_COMPONENT.instantiate()
	enemy.ai_comp = ai_comp
	loss.connect(enemy.ai_comp._on_loss)
	enemy.global_position = right_spawn.global_position
	enemy.add_child(ai_comp)
	enemy.died.connect(_on_creature_died)
	
	#var enemy_body: Body = ???
	#enemy.body = enemy_body
	#enemy.add_child(enemy_body)
	#
	#for limb_file in ???:
		#enemy_body.add_limb(load(limb_file))
	
	animate_counter()


func animate_counter() -> void:
	await get_tree().process_frame
	get_tree().paused = true
	$Countdown.play()
	var start_tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	start_tween.tween_callback(reset_counter.bind(COUNT_3))
	start_tween.tween_property(counter, "modulate", Color.WHITE, COUNT_DELAY)
	start_tween.parallel().tween_property(counter, "offset_transform_scale", Vector2.ONE, COUNT_DELAY)
	start_tween.tween_callback(reset_counter.bind(COUNT_2))
	start_tween.tween_property(counter, "modulate", Color.WHITE, COUNT_DELAY)
	start_tween.parallel().tween_property(counter, "offset_transform_scale", Vector2.ONE, COUNT_DELAY)
	start_tween.tween_callback(reset_counter.bind(COUNT_1))
	start_tween.tween_property(counter, "modulate", Color.WHITE, COUNT_DELAY)
	start_tween.parallel().tween_property(counter, "offset_transform_scale", Vector2.ONE, COUNT_DELAY)
	start_tween.tween_callback(reset_counter.bind(COUNT_GO))
	start_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	start_tween.tween_property(counter, "modulate", Color.WHITE, COUNT_DELAY / 2.0)
	start_tween.parallel().tween_property(counter, "offset_transform_scale", Vector2.ONE, COUNT_DELAY / 2.0)
	start_tween.tween_callback(func(): get_tree().paused = false)
	start_tween.tween_property(counter, "modulate", Color.TRANSPARENT, COUNT_DELAY / 2.0)
	start_tween.parallel().tween_property(counter, "offset_transform_scale", Vector2(1.5, 1.5), COUNT_DELAY / 2.0)
	start_tween.tween_callback(func(): counter.hide())


func reset_counter(count: CompressedTexture2D) -> void:
	counter.texture = count
	counter.modulate = Color(1, 1, 1, 0.5)
	counter.offset_transform_scale = Vector2(0.5, 0.5)


func _on_creature_died(creature: Creature) -> void:
	camera.remove_target(creature.body.body)
	
	if is_instance_valid(end_tween): return
	loss.emit()
	end_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	end_tween.tween_interval(2.5)
	end_tween.tween_callback(func(): get_tree().paused = true)
	#end_tween.tween_interval(0.5)
	end_tween.tween_property(color_rect, "color", Color.BLACK, 0.5)
	end_tween.tween_callback(func(): get_tree().paused = false)
	if not creature.is_player:
		Global.sumo_level = null
		Global.rounds_lasted += 1
		end_tween.tween_callback(func(): get_tree().change_scene_to_file("uid://bjviy5ac43lwa")) # shop
	else:
		Global.sumo_level = null
		Global.just_started = true
		Global.loser_pieces = []
		Global.picked_keys = ""
		#end_tween.tween_callback(func(): get_tree().change_scene_to_file("uid://b8l7b6elncmkp"))
		end_tween.tween_callback(func(): get_tree().change_scene_to_file("uid://dt215nwmvlo71")) # end screen
		#end_tween.tween_property($CanvasLayer/Label, "visible", true, 0.1) # lol
