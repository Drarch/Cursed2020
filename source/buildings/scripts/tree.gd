extends Node2D

func increase():
	scale += Vector2.ONE * 0.1

func destroy():
	queue_free()
