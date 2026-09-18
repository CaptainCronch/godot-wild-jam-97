extends Node

const CREATURE = preload("uid://cehmoa2dw3qj0")
const INPUT_COMPONENT := preload("uid://c1q66rs8180kh")
const AI_COMPONENT := preload("uid://bwl211rl7kw44")

const BODIES: Array[String] = [
	"res://creature/bodies/test_body.tscn",
]
const HEADS: Array[String] = [
	"res://creature/limbs/test_head.tscn",
	"res://creature/limbs/evil_head.tscn",
	"res://creature/limbs/cookie_head.tscn",
	"res://creature/limbs/dopey_head.tscn",
	]
const ARMS: Array[String] = [
	"res://creature/limbs/test_arm.tscn",
	"res://creature/limbs/tentacle_arm.tscn",
]
const LEGS: Array[String] = [
	"res://creature/limbs/test_leg.tscn",
	"res://creature/limbs/bison_leg.tscn",
	]
const TAILS: Array[String] = [
	"res://creature/limbs/test_tail.tscn",
]
const BACKS: Array[String] = [
]

var sumo_level: SumoLevel
var player: Creature
var camera: MultitargetCamera2D
var player_body_file: String = "uid://brbv6c4bk75mp" ## File path of the player's body.
var player_pieces: Array[String] ## Array of file paths of the player's limbs.
var player_piece_keys: Array[String] ## Corresponding array of the player's limbs' associated key inputs.
var loser_pieces: Array[String] ## Array of file paths of the body parts of the last loser.
var limb_files: Array[String] ## Has everything in HEADS, ARMS, LEGS, TAILS, and BACKS.
var picked_keys := ""


func _init() -> void:
	limb_files.append_array(HEADS)
	limb_files.append_array(ARMS)
	limb_files.append_array(LEGS)
	limb_files.append_array(TAILS)
	limb_files.append_array(BACKS)
	
	#var combined := [HEADS, ARMS, LEGS, TAILS, BACKS]
	#for array in combined:
		#for item in array:
			#limb_files.append(item)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("quit"): get_tree().quit()


func decay_towards(value: float, target: float,
			decay_power: float, delta: float = get_process_delta_time(),
			round_threshold: float = 0.0) -> float:

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if absf(new_value - target) < round_threshold:
		return target
	else:
		return new_value


func decay_towards_vec2(value: Vector2, target: Vector2,
			decay_power: float, delta: float = get_process_delta_time(),
			round_threshold: float = 0.0) -> Vector2:

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if (new_value - target).length() < round_threshold:
		return target
	else:
		return new_value


func decay_angle_towards(value: float, target: float,
			decay_power: float, delta: float = get_process_delta_time(),
			round_threshold: float = 0.0) -> float:

	var new_value := angle_difference(target, value) * pow(2, -delta * decay_power) + target

	if absf(angle_difference(target, new_value)) < round_threshold:
		return target
	else:
		return new_value
