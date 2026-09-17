extends Node2D

@export var pupil_spinner: Node2D
@export var pupil_position: Node2D
@export var pupil: Sprite2D

#@onready var player := Global.player


func _process(_delta: float) -> void:
	if Global.camera.targets.is_empty(): return
	#if not is_instance_valid(Global.camera.targets[0]): return
	#if not is_instance_valid(Global.player.body): return
	pupil_spinner.rotation = pupil_spinner.global_position.direction_to(Global.camera.targets[0].global_position).angle()
	pupil.global_position = pupil_position.global_position
