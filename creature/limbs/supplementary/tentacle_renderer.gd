extends Line2D

@export var point_nodes : Array[Node2D]

func _ready() -> void:
	for node : Node2D in point_nodes:
		add_point(node.global_position)

func _process(_delta: float) -> void:
	var i = 0
	for node : Node2D in point_nodes:
		set_point_position(i, node.global_position - global_position)
		i += 1
