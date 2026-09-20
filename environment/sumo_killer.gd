extends Area2D

@onready var saw_kill: AudioStreamPlayer = $SawKill


func _on_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is Body:
		(parent.get_parent() as Creature).die()
		saw_kill.play()
		#parent.body.linear_velocity = Vector2(0.0, -1500.0)
