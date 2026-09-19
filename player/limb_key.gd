extends Node2D
class_name LimbKey

@export var speed := 5.0
@export var turn_speed := 5.0
@export var distance := Vector2(100.0, 0.0):
	set(value):
		distance = value
		holder.position = value

var target_body: Body
var key := ""
var rotation_offset := 0.0
var rotation_delta := 0.0

@onready var follower: Node2D = $Follower
@onready var spinner: Node2D = $Follower/Spinner
@onready var holder: Node2D = $Follower/Spinner/Holder
@onready var backdrop: Sprite2D = $Backdrop
@onready var label: Label = $Backdrop/Label


func _ready() -> void:
	holder.position = distance
	backdrop.global_position = target_body.body.global_position


func _process(delta: float) -> void:
	follower.global_position = target_body.body.global_position
	
	rotation_delta = spinner.global_rotation
	spinner.global_rotation = target_body.body.global_rotation + rotation_offset
	rotation_delta = spinner.global_rotation - rotation_delta
	
	backdrop.global_position = Global.decay_towards_vec2(backdrop.global_position, holder.global_position, speed, delta)
	backdrop.global_rotation += rotation_delta
	backdrop.global_rotation = Global.decay_angle_towards(backdrop.global_rotation, 0.0, turn_speed, delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.as_text() == key:
		if event.is_pressed():
			backdrop.modulate = Color.BLACK
		elif event.is_released():
			backdrop.modulate = Color.WHITE


func set_key(new_key: String) -> void:
	backdrop.show()
	label.text = new_key
	key = new_key
