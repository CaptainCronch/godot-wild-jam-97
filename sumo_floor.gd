extends StaticBody2D

@export var shrink_speed := 0.2

@export var polygon2d: Polygon2D
@export var collider: CollisionShape2D


func _physics_process(delta: float) -> void:
	#(collider.shape as RectangleShape2D).size.x = maxf(0.0, (collider.shape as RectangleShape2D).size.x * shrink_speed * delta)
	collider.scale.x = maxf(0.0, collider.scale.x - shrink_speed * delta)
	polygon2d.scale.x = maxf(0.0, polygon2d.scale.x - shrink_speed * delta)
	polygon2d.texture_scale.x = maxf(0.0, polygon2d.texture_scale.x - shrink_speed * delta)
