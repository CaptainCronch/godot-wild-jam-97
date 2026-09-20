extends Resource
class_name LimbStats

enum Slot {
	NONE = -1,
	HEAD,
	ARM,
	LEG,
	TAIL,
	BACK,
}

const KEYS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@export var name := ""
@export_multiline var description := ""
@export var slot: Slot = Slot.NONE
#@export var attack: Attack
@export var stiffness := 200000.0
@export var damping := 10000.0
@export var softness := 0.00001
@export_range(-180, 180, 1, "radians_as_degrees") var angular_limit_lower := deg_to_rad(-90.0)
@export_range(-180, 180, 1, "radians_as_degrees") var angular_limit_upper := deg_to_rad(0.0)
@export var body_torque := 0.0
@export var bite_knockback := 1000.0
@export var self_knockback := -500.0
@export var flip_orientation := false ## Sets limb to flex towards lower limit instead of upper limit.
@export var key := "": ## Should contain one uppercase alphabet letter.
	set(value):
		assert(value in KEYS or value.is_empty())
		key = value


func _init() -> void:
	resource_local_to_scene = true


func pick_random_key() -> void:
	var reduced_keys := KEYS.remove_chars(Global.picked_keys)
	key = reduced_keys.substr(randi_range(0, reduced_keys.length() - 1), 1)
	Global.picked_keys += key
