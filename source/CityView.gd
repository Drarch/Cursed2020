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
	get_tree().set_auto_accept_quit(false)
	
	Globals.cityView = self
	Globals.navigation = navigation

	constructExistingBuildings()

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

func constructRandom():
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
		building.randView()
		buildings.add_child(building)
		
		constructOnCell(building, cell)
	else:
		buildings_data[cell].increase()
	
	if Globals.maxWorkers > Globals.workers:
		buildings_data[cell].spawnWorker(0)

func constructOnCell(building: BuildingBase, cell: Vector2) -> void:
	building.position = tilemap.map_to_world(cell) + Vector2(0, 34)
	buildings_data[cell] = building

func construct(building: BuildingBase) -> void:
	var cell = tilemap.world_to_map(building.position)
	constructOnCell(building, cell)

func constructExistingBuildings() -> void:
	for b in buildings.get_children():
		if b is BuildingBase:
			construct(b)


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
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F1:
		start_arkanoid()


func randomTile() -> Vector2:
	var cells := tilemap.get_used_cells()
	var cell := cells[randi() % cells.size()] as Vector2
	while tilemap.get_cellv(cell) != 2:
		cell = cells[randi() % cells.size()]

	return cell

func randomTileGlobal() -> Vector2:
	var cell = randomTile()

	return tilemap.map_to_world(cell)

func start_arkanoid():
	var root := get_parent()
	var arkanoid := preload("res://arkanoid/arkanoid_scene.tscn").instance()
	root.remove_child(self)
	arkanoid.add_child(self)
	root.add_child(arkanoid)

var quit = false
func _notification(what: int) -> void:
	if not quit and what == NOTIFICATION_WM_QUIT_REQUEST:
		quit = true
		call_deferred("start_arkanoid")
