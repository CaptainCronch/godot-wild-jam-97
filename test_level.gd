extends Node2D

func win() -> void:
	get_tree().call_deferred("change_level_to_scene")


func creature_died() -> void:
	pass
