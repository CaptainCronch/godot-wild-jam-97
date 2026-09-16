extends Resource
class_name Behavior

@export var id := ""
@export var limb_relax_duration: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0] ## [head, arm, leg, tail, back]
@export var limb_contract_duration: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0] ## [head, arm, leg, tail, back]
@export var randomness: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0] ## Values should be about between 0.0 and 1.0.
@export var limb_start_delay: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0] ## [head, arm, leg, tail, back]


func _init() -> void:
	for i in limb_contract_duration.size():
		assert(limb_contract_duration[i] == 0.0 and limb_relax_duration[i] == 0.0)
