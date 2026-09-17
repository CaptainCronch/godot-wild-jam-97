extends Node

var sumo_level: SumoLevel
var player: Creature
var camera: MultitargetCamera2D


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and event.as_text() == "Escape": get_tree().quit()


func decay_towards(value : float, target : float,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> float :

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if absf(new_value - target) < round_threshold:
		return target
	else:
		return new_value


func decay_towards_vec2(value : Vector2, target : Vector2,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> Vector2 :

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if (new_value - target).length() < round_threshold:
		return target
	else:
		return new_value


func decay_angle_towards(value : float, target : float,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> float :

	var new_value := angle_difference(target, value) * pow(2, -delta * decay_power) + target

	if absf(angle_difference(target, new_value)) < round_threshold:
		return target
	else:
		return new_value
