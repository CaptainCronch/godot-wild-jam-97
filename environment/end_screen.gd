extends Node2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var player_limb_spawner: Marker2D = $PlayerLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $MultitargetCamera2D
@onready var result_label: Label = $ResultLabel

func _ready() -> void:
	var string = "Rounds lasted: %s \n Limbs Bought: %s \n Shops Rerolled: %s"
	result_label.text = string % [Global.rounds_lasted, Global.limbs_bought, Global.shops_rerolled]
	print("test")
	#Global.player_pieces = []
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	print("test2")
	if Global.player_pieces.is_empty(): return
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
