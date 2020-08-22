extends Node2D

onready var navigation := $Navigation2D as Navigation2D
onready var camera := $Camera2D as Camera2D
onready var screen_center := $UI/ScreenCenter as Node2D
onready var tilemap := $Navigation2D/TileMap as TileMap
onready var buildings := $Buildings

var drag: Vector2
var drag_camera: Vector2
var buildings_data: Dictionary

func _ready() -> void:
	Globals.cityView = self
	Globals.navigation = navigation

func _process(delta: float) -> void:
	var screen_size := get_viewport().size
	screen_center.position = screen_size * 0.5
	
#	if screen_center.get_local_mouse_position().x > screen_size.x * 0.4:
#		camera.position.x += 800 * delta
#	elif screen_center.get_local_mouse_position().x < -screen_size.x * 0.4:
#		camera.position.x -= 800 * delta
#	if screen_center.get_local_mouse_position().y > screen_size.y * 0.4:
#		camera.position.y += 800 * delta
#	elif screen_center.get_local_mouse_position().y < -screen_size.y * 0.4:
#		camera.position.y -= 800 * delta
	
	if drag:
		camera.position = drag_camera + (drag - screen_center.get_local_mouse_position()) * camera.zoom
	
	construct()

func construct():	
	var cell = randomTile()

	if not cell in buildings_data:
		var direction := randi() % 4
		if tilemap.get_cellv(cell + Vector2.DOWN) == 0:
			direction = 0
		elif tilemap.get_cellv(cell + Vector2.RIGHT) == 0:
			direction = 1
		elif tilemap.get_cellv(cell + Vector2.UP) == 0:
			direction = 2
		elif tilemap.get_cellv(cell + Vector2.LEFT) == 0:
			direction = 3
		
		var building := preload("res://buildings/building_base.tscn").instance() as Node2D
		building.direction = direction
		building.position = tilemap.map_to_world(cell) + Vector2(-1, 34)
		buildings.add_child(building)
		buildings_data[cell] = building
	else:
		buildings_data[cell].increase()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			camera.zoom *= 0.9
		elif event.button_index == BUTTON_WHEEL_DOWN:
			camera.zoom *= 1.1
		
		if event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				drag = screen_center.get_local_mouse_position()
				drag_camera = camera.position
			else:
				drag = Vector2()


func randomTile() -> Vector2:
	var cells := tilemap.get_used_cells()
	var cell := cells[randi() % cells.size()] as Vector2
	while tilemap.get_cellv(cell) != 2:
		cell = cells[randi() % cells.size()]

	return cell

func randomTileGlobal() -> Vector2:
	var cell = randomTile()

	return tilemap.map_to_world(cell)