extends Parallax2D

@export var spin_speed := 15.0

var saws: Array[Node2D] = [] #get_children() as Array[Node2D]
var random: PackedFloat32Array = []


func _ready() -> void:
	for child in get_children():
		if child is Node2D:
			saws.append(child)
	
	for i in saws.size():
		random.append(((randf() / 2.0) + 0.5))# * -1.0 if randi_range(0, 1) else 1.0)
		#saws[i].scale *= randf_range(0.75, 1.25)


func _process(delta: float) -> void:
	for i in saws.size():
		saws[i].rotate(spin_speed * delta * random[i])
