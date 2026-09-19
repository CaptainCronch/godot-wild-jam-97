extends TextureProgressBar

const SPEED := 7.0
const LOSS_SPEED := 200.0

var progress := 0.0


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if Input.is_action_pressed("quit"):
		progress = Global.decay_towards(progress, max_value, SPEED, delta, 0.5)
		if progress >= max_value:
			get_tree().quit()
	else:
		progress = maxf(progress - LOSS_SPEED * delta, 0.0)
	value = progress
