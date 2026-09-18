extends Label

@export var is_reroll := false

@export var halo: Sprite2D


func _ready() -> void:
	halo.hide()


func select(is_selected: bool) -> void:
	halo.visible = is_selected
