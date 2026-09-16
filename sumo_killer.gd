extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is Body:
		(parent.get_parent() as Creature).die()
		#parent.body.linear_velocity = Vector2(0.0, -1500.0)
