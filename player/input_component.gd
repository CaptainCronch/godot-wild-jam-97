extends Node
class_name InputComponent

@onready var creature: Creature = get_parent()


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_instance_valid(creature.body): return
	
	for limb in creature.body.limbs:
		if not is_instance_valid(limb): continue
		if limb.limb_stats.key == event.as_text():
			limb.flex(event.is_pressed())
