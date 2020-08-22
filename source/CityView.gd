extends Node2D

onready var navigation := $Navigation2D as Navigation2D
onready var camera := $Camera2D as Camera2D
onready var screen_center := $UI/ScreenCenter as Node2D

func _ready() -> void:
	Globals.navigation = navigation

func _process(delta: float) -> void:
	var screen_size := get_viewport().size
	screen_center.position = screen_size * 0.5
	
	if screen_center.get_local_mouse_position().x > screen_size.x * 0.4:
		camera.position.x += 800 * delta
	elif screen_center.get_local_mouse_position().x < -screen_size.x * 0.4:
		camera.position.x -= 800 * delta
	if screen_center.get_local_mouse_position().y > screen_size.y * 0.4:
		camera.position.y += 800 * delta
	elif screen_center.get_local_mouse_position().y < -screen_size.y * 0.4:
		camera.position.y -= 800 * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			camera.zoom *= 0.9
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1
