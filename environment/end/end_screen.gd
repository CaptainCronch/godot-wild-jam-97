extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var player_limb_spawner: Marker2D = $PlayerLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $MultitargetCamera2D
@onready var result_label: Label = $ResultLabel
@onready var tube_noise: AudioStreamPlayer2D = $TubeNoise
@onready var shopkeep_head: Sprite2D = $ShopkeepLean/ShopkeepHead
@onready var shopkeep_tail: Sprite2D = $ShopkeepLean/ShopkeepTail
@onready var shopkeep_eye: Sprite2D = $ShopkeepLean/ShopkeepHead/Eye


func _ready() -> void:
	var string = "Rounds lasted: %s\n Limbs Bought: %s\n Shops Rerolled: %s"
	result_label.text = string % [Global.rounds_lasted, Global.limbs_bought, Global.shops_rerolled]
	#Global.player_pieces = []
	spawn_timer.start()
	_on_spawn_timer_timeout()
	if OS.get_name() == "Web":
		$QuitInstructions.hide()
	
	var tail_tween := create_tween().set_loops().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_BOUNCE)
	tail_tween.tween_property(shopkeep_tail, "rotation", deg_to_rad(5.0), 16.0)
	tail_tween.tween_property(shopkeep_tail, "rotation", deg_to_rad(-25.0), 16.0)
	
	var eyes_tween := create_tween().set_loops()
	eyes_tween.tween_interval(11.0)
	eyes_tween.tween_property(shopkeep_eye, "scale:y", 0.0, 0.01)
	eyes_tween.tween_interval(0.2)
	eyes_tween.tween_property(shopkeep_eye, "scale:y", 1.0, 0.01)
	
	var head_tween := create_tween().set_loops().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	head_tween.tween_property(shopkeep_head, "rotation", deg_to_rad(1.0), 8.0)
	head_tween.tween_property(shopkeep_head, "rotation", deg_to_rad(-1.0), 8.0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("select_confirm"):
		_on_restart_button_pressed()


func _on_spawn_timer_timeout() -> void:
	if Global.player_pieces_lifetime.is_empty(): return
	tube_noise.play()
	spawn_limb(load(Global.player_pieces_lifetime.back()), player_limb_spawner.global_position)
	Global.player_pieces_lifetime.erase(Global.player_pieces_lifetime.back())
	#print(Global.player_pieces_lifetime)


func spawn_limb(limb_scene: PackedScene, spawn_position: Vector2) -> void:
	var limb: Limb = limb_scene.instantiate()
	limb.global_position = spawn_position + Vector2(randf_range(-50.0, 50.0), 0.0)
	limb.in_shop = true
	limb.limb_stats.pick_random_key()
	if is_instance_valid(limb.bonus_stats): limb.bonus_stats.key = limb.limb_stats.key
	add_child(limb)
	#limb.limb.scale = Vector2(2.0, 2.0)
	#if is_instance_valid(limb.bonus_limb):
		#limb.bonus_limb.scale = Vector2(2.0, 2.0)
	multitarget_camera_2d.targets.clear()
	multitarget_camera_2d.targets.append(limb.limb)


func _on_restart_button_pressed() -> void:
	Global.shops_rerolled = 0
	Global.limbs_bought = 0
	Global.rounds_lasted = 0
	Global.player_pieces_lifetime = []
	get_tree().change_scene_to_file("uid://bjviy5ac43lwa")
