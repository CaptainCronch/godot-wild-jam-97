extends Node2D

const TEST_HEAD := preload("uid://xj4exedc2frc")

@onready var shop_limb_spawner: Marker2D = $ShopLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $"Multitarget Camera2D"


func _ready() -> void:
	multitarget_camera_2d.add_target(shop_limb_spawner)


func _on_spawn_timer_timeout() -> void:
	var head: Limb = TEST_HEAD.instantiate()
	head.global_position = shop_limb_spawner.global_position
	add_child(head)
	head.die()
