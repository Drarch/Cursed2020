extends Node

onready var player := get_parent() as Node2D
export var nav_path: NodePath
onready var navigation := get_node(nav_path) as Navigation2D

var points := []

func go_to(where: Vector2):
	if points.empty():
		points = navigation.get_simple_path(player.position, where)

func _process(delta: float) -> void:
	if not points.empty():
		player.position += player.position.direction_to(points.front()) * 400 * delta
		if player.position.distance_squared_to(points.front()) < 100:
			points.pop_front()
