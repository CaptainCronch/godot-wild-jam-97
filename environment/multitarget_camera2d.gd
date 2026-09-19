extends Camera2D
class_name MultitargetCamera2D

@export var move_speed := 2.0 # camera position lerp speed
@export var zoom_speed := 2.0  # camera zoom lerp speed
@export var max_zoom := 1.5  # camera won't zoom farther than this
@export var min_zoom := 0.5  # camera won't zoom closer than this
@export var margin := Vector2(500, 300)  # include some buffer area around targets

var targets: Array[Node2D] = []

@onready var screen_size := get_viewport_rect().size


func _enter_tree() -> void:
	Global.camera = self


func _process(delta: float) -> void:
	if !targets:
		return

	# Keep the camera centered among all targets
	var p := Vector2.ZERO
	for target in targets:
		p += target.global_position
	p /= targets.size()
	#global_position = lerp(global_position, p, move_speed * delta)
	global_position = Global.decay_towards_vec2(global_position, p, move_speed, delta)

	# Find the zoom that will contain all targets
	var r := Rect2(global_position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.global_position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var z: float
	if r.size.x > r.size.y * screen_size.aspect():
		z = 1.0 / clampf(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = 1.0 / clampf(r.size.y / screen_size.y, min_zoom, max_zoom)
	#zoom = lerp(zoom, Vector2.ONE * z, zoom_speed * delta)
	zoom = Global.decay_towards_vec2(zoom, Vector2.ONE * z, zoom_speed, delta)

	# For debug
	#get_parent().draw_cam_rect(r)

func add_target(t: Node2D) -> void:
	if not t in targets:
		targets.append(t)

func remove_target(t: Node2D) -> void:
	#if t in targets:
	targets.erase(t)
