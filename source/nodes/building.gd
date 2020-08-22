extends Node2D

onready var roof := $Roof as Sprite

func _ready() -> void:
	roof.frame = randi() % 48

func increase():
	var sprite := get_child(get_child_count() - 2).duplicate() as Node2D
	sprite.position.y -= 33
	add_child(sprite)
	roof.position.y = sprite.position.y - 45
	roof.raise()
