extends Area2D

@export var excited: CompressedTexture2D

@onready var cheer: AudioStreamPlayer = $Cheer


func _on_body_entered(body: Node2D) -> void:
	var parent := body.get_parent()
	if parent is Body:
		if not cheer.playing: cheer.play()
		$"../Parallax/Crowd/Faces".texture = excited
		#parent.body.linear_velocity = Vector2(0.0, -1500.0)
