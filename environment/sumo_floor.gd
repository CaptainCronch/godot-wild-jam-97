extends StaticBody2D

@export var shrink_speed := 0.01

var percentage := 1.0

@export var sprite: Sprite2D
@export var collider: CollisionShape2D

@onready var sprite_shader: ShaderMaterial = sprite.material


func _physics_process(delta: float) -> void:
	#(collider.shape as RectangleShape2D).size.x = maxf(0.0, (collider.shape as RectangleShape2D).size.x * shrink_speed * delta)
	collider.scale.x = maxf(0.0, collider.scale.x - shrink_speed * delta)
	percentage = maxf(0.0, percentage - shrink_speed * delta)
	sprite_shader.set_shader_parameter("percentage", percentage) #maxf(0.0, collider.scale.x - shrink_speed * delta)
	#polygon2d.scale.x = maxf(0.0, polygon2d.scale.x - shrink_speed * delta)
	#polygon2d.texture_scale.x = maxf(0.0, polygon2d.texture_scale.x - shrink_speed * delta)
