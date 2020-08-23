extends Node2D

onready var navigation := $Navigation2D as Navigation2D
onready var camera := $Camera2D as Camera2D
onready var screen_center := $UI/ScreenCenter as Node2D
onready var tilemap := $Navigation2D/TileMap as TileMap
onready var buildings := $Buildings

var drag: Vector2
var drag_camera: Vector2
var buildings_data: Dictionary

export(int ,0 ,1000) var startEmployers: int = 10

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	Globals.cityView = self
	Globals.navigation = navigation

	constructExistingBuildings()
	
	for i in range(startEmployers):
		constructRandom()

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


func constructSpecific( cell:Vector2, building_id:int ):
		var direction := randi() % 4
		if tilemap.get_cellv(cell + Vector2.DOWN) == 0:
			direction = 0
		elif tilemap.get_cellv(cell + Vector2.RIGHT) == 0:
			direction = 1
		elif tilemap.get_cellv(cell + Vector2.UP) == 0:
			direction = 2
		elif tilemap.get_cellv(cell + Vector2.LEFT) == 0:
			direction = 3
			
		var building:Node2D
		if building_id == 2:
			building = preload("res://buildings/building_base.tscn").instance() as Node2D
			building.randView()

		else:
			building = preload("res://buildings/building_storage.tscn").instance() as Node2D
			building.setView()
			
		building.direction = direction
		building.get_node('AudioStreamPlayer').playing = true
		buildings.add_child(building)
		
		constructOnCell(building, cell)
		if building_id == 2:
			if Globals.maxWorkers > Globals.workers:
				buildings_data[cell].spawnWorker(0)

func constructRandom( tile_coordinates = Vector2(0,0) ):
	var cell = randomTile()
	if tile_coordinates:
		cell = tile_coordinates

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

func grow_tree():
	var cells := tilemap.get_used_cells()
	var cell := cells[randi() % cells.size()] as Vector2
	
	while tilemap.get_cellv(cell) != 1:
		cell = cells[randi() % cells.size()]
	
	
	if not cell in buildings_data:
		var tree := preload("res://buildings/tree.tscn").instance() as Node2D
		tree.position = tilemap.map_to_world(cell) + Vector2(0, 34) + Vector2(rand_range(-26,26),rand_range(-26,26)) 
		buildings_data[cell] = tree
		buildings.add_child(tree)
	elif buildings_data[cell] is ResourceBase:
		buildings_data[cell].increase()

func constructOnCell(building: BuildingBase, cell: Vector2) -> void:
	building.position = tilemap.map_to_world(cell) + Vector2(0, 34)
	buildings_data[cell] = building

func construct(building: BuildingBase) -> void:
	var cell = tilemap.world_to_map(building.position)
	constructOnCell(building, cell)

func createConstructionSite(cell: Vector2) -> void:
	var tile_id = tilemap.get_cellv(cell)
	if tile_id in [1, 2]:
		if !buildings_data.has(cell):
			var site := preload("res://buildings/building_construction_site.tscn").instance() as Node2D
			site.position = tilemap.map_to_world(cell) + Vector2(0, 34)
			site.constructionType = tile_id
			site.cell = cell
			buildings.add_child(site)

			if cell in buildings_data && buildings_data[cell] is ResourceBase:
				buildings_data[cell].destroy()

			buildings_data[cell] = site




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
				
		if event.button_index == BUTTON_LEFT:
			inputConstruct()
			
		if event.button_index == BUTTON_RIGHT:
			pass
	
	if event is InputEventKey and event.pressed and event.scancode == KEY_F1:
		start_arkanoid()

func inputConstruct() -> void:
	var clicked_tile = tilemap.world_to_map(tilemap.get_local_mouse_position())
	createConstructionSite(clicked_tile)


func randomTile() -> Vector2:
	var cells := tilemap.get_used_cells()
	var cell := cells[randi() % cells.size()] as Vector2
	
	while not tilemap.get_cellv(cell) == 2:
		cell = cells[randi() % cells.size()]

	return cell

func randomRoadTile() -> Vector2:
	var cells := tilemap.get_used_cells()
	var cell := cells[randi() % cells.size()] as Vector2
	
	while not tilemap.get_cellv(cell) == 0:
		cell = cells[randi() % cells.size()]

	return cell
	
func randomRoadTileGlobal() -> Vector2:
	var cell = randomRoadTile()

	return tilemap.map_to_world(cell)
	
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
		Globals.set_meta("silent", true)
		if buildings_data.size() < 100:
			for i in 500:
				constructRandom()
		Globals.remove_meta("silent")
		
		quit = true
		call_deferred("start_arkanoid")
