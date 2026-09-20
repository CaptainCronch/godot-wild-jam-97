extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var player_limb_spawner: Marker2D = $PlayerLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $MultitargetCamera2D
@onready var result_label: Label = $ResultLabel
@onready var shopkeep_tail: Sprite2D = $ShopkeepBody/ShopkeepTail
@onready var shopkeep_left_eye: Sprite2D = $ShopkeepBody/ShopkeepHead/LeftEye
@onready var shopkeep_right_eye: Sprite2D = $ShopkeepBody/ShopkeepHead/RightEye
@onready var shopkeep_head: Sprite2D = $ShopkeepBody/ShopkeepHead
@onready var tube_noise: AudioStreamPlayer2D = $TubeNoise


func _ready() -> void:
	var string = "Rounds lasted: %s\n Limbs Bought: %s\n Shops Rerolled: %s"
	result_label.text = string % [Global.rounds_lasted, Global.limbs_bought, Global.shops_rerolled]
	#Global.player_pieces = []
	spawn_timer.start()
	_on_spawn_timer_timeout()
	if OS.get_name() == "Web":
		$QuitInstructions.hide()
	
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

func _on_spawn_timer_timeout() -> void:
	if Global.player_pieces.is_empty(): return
	tube_noise.play()
	spawn_limb(load(Global.player_pieces.back()), player_limb_spawner.global_position)
	Global.player_pieces.erase(Global.player_pieces.back())
	print(Global.player_pieces)
func spawn_limb(limb_scene: PackedScene, spawn_position: Vector2) -> void:
	var limb: Limb = limb_scene.instantiate()
	limb.global_position = spawn_position
	limb.in_shop = true
	limb.limb_stats.pick_random_key()
	if is_instance_valid(limb.bonus_stats): limb.bonus_stats.key = limb.limb_stats.key
	add_child(limb)
	multitarget_camera_2d.targets.clear()
	multitarget_camera_2d.targets.append(limb.limb)


func _on_restart_button_pressed() -> void:
	Global.shops_rerolled = 0
	Global.limbs_bought = 0
	Global.rounds_lasted = 0
	get_tree().change_scene_to_file("uid://bjviy5ac43lwa")
