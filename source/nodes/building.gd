extends Node2D

func increase():
	var sprite := get_child(get_child_count() - 1).duplicate() as Node2D
	sprite.position.y -= 33
	add_child(sprite)
