extends Node2D
class_name ResourceBase

var maxCapacity: int = 3
var capacity: int = 1

func _ready():
	Globals.addResource(self)


func increase() -> void:
	if capacity < maxCapacity:
		capacity += 1
		updateView()

func gather() -> void:
	capacity -= 1

	if capacity <= 0:
		destroy()
	else:
		updateView()

func updateView() -> void:
	scale = Vector2.ONE * 0.5 * capacity

func destroy():
	Globals.removeResources(self)
	queue_free()
