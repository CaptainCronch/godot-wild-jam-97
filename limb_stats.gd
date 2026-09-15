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
@export var softness := 0.0001
@export_range(-180, 180, 1, "radians_as_degrees") var angular_limit_lower := deg_to_rad(-90.0)
@export_range(-180, 180, 1, "radians_as_degrees") var angular_limit_upper := deg_to_rad(0.0)
@export var flip_orientation := false ## Sets limb to flex towards lower limit instead of upper limit.
@export var key := "": ## Should contain one uppercase alphabet letter.
	set(value):
		assert(value in KEYS)
		key = value


func _init() -> void:
	resource_local_to_scene = true
