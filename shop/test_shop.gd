extends Node2D

const TEST_HEAD2 := preload("uid://xj4exedc2frc")

@onready var shop_limb_spawner: Marker2D = $ShopLimbSpawner
@onready var loser_limb_spawner: Marker2D = $LoserLimbSpawner
@onready var multitarget_camera_2d: MultitargetCamera2D = $"Multitarget Camera2D"
const TEST_ARM = preload("uid://dnsl5n65j0isy")
const TEST_BODY = preload("uid://brbv6c4bk75mp")
const TEST_HEAD = preload("uid://xj4exedc2frc")
const TEST_LEG = preload("uid://cj35yvh70kyg6")
const TEST_TAIL = preload("uid://21goo8mxrnyp")


func _ready() -> void:
	var limbs = [TEST_ARM, TEST_BODY, TEST_HEAD, TEST_LEG, TEST_TAIL]
	for LIMB in limbs:
		var limb = LIMB.instantiate()
		limb.global_position = loser_limb_spawner.global_position
		add_child(limb)
		limb.die()
		limb.limb.linear_velocity = Vector2.ZERO

func _on_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("Shop Items").size() > 5: return
	var head: Limb = TEST_HEAD2.instantiate()
	head.global_position = shop_limb_spawner.global_position
	add_child(head)
	head.die()
	head.add_to_group("Shop Items")
	head.limb.linear_velocity = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pass

func refresh_shop() -> void:
	pass
func leave_shop() -> void:
	Global.loser = null
