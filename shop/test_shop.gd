extends Node2D

@onready var shop_limb_spawner: Marker2D = $ShopLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $"Multitarget Camera2D"
const TEST_HEAD_2 = preload("uid://dvd08ycjilykt")

func _ready() -> void:
	multitarget_camera_2d.add_target(shop_limb_spawner)


func _on_spawn_timer_timeout() -> void:
	var head = TEST_HEAD_2.instantiate()
	head.global_position = shop_limb_spawner.global_position
	call_deferred("add_child", head)
