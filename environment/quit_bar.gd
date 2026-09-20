extends TextureProgressBar

const SPEED := 5.0
const LOSS_SPEED := 200.0

var progress := 0.0

@onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if OS.get_name() == "Web": return
	if Input.is_action_just_pressed("quit"): sound.play()
	if Input.is_action_pressed("quit"):
		progress = Global.decay_towards(progress, max_value, SPEED, delta, 0.5)
		if progress >= max_value:
			get_tree().quit()
	else:
		progress = maxf(progress - LOSS_SPEED * delta, min_value)
	value = progress


func _on_sound_finished() -> void:
	if progress > min_value:
		sound.pitch_scale = remap(progress, min_value, max_value, 2.0, 4.0)
		sound.volume_db = remap(progress, min_value, max_value, -6.0, 6.0)
		sound.play()
