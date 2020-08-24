extends Node2D
class_name BuildingBase

enum WorkerType { UNEMPOLYED, CARGO, LUMBER, BUILDER }

const FLOOR_DIRECTIONS := [0, 1, 0, 1, 2, 3, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 , 1, 0, 1, 0, 1, 0, 1, 2, 3, 0, 0, 1, 3, 2, 2, 3, 0, 1, 2, 3, 0, 1, 0, 0, 1, 1, 0, 1]
const WALL_DIRECTIONS := [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, -1, -1, -1, -1, -1, -1, -1, -1]
const ROOF_DIRECTIONS := [-1, -1, -1, -1, 0, 1, 3, 2,0, 1, 3, 2, 0, 1, 3, 2, 0 , 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1,3, 2, 0, -1, -1, -1, -1, -1, -1, -1]


onready var roof := $components/Roof as Sprite
onready var cargoView: Label = $CargoView

var direction: int

export(int, 0, 20) var maxEmployers: int = 0
export(int, 0, 20) var maxCargo: int = 0

export(int, 0, 100) var maxCapacity: int = 10
export(int, 0, 100) var capacity: int = 0

export(WorkerType) var employerType: int = WorkerType.UNEMPOLYED
var employers: Array = []
var cargo: Array = []

var in_construction = false

func _ready() -> void:
#	if not Globals.has_meta("silent"):
#		$AudioStreamPlayer.play()
	
	updateWorkplace()
	updateCargo()
	pass

func increase():
	in_construction = false
	if $components.get_child_count() < 2:
		return
	
	var sprite := $components.get_child($components.get_child_count() - 2).duplicate() as Sprite
	if not sprite or not roof:
		return
	
	sprite.position.y -= 33
	$components.add_child(sprite)
	
	if $components.get_child_count() == 3:
		sprite.texture = preload("res://tileset/tileset_buildings_walls.png")
		sprite.hframes = 8
		sprite.vframes = 3
		
		var wall := randi() % WALL_DIRECTIONS.size()
		while WALL_DIRECTIONS[wall] != -1 and WALL_DIRECTIONS[wall] != direction and WALL_DIRECTIONS[wall] != opposite(direction):
			wall = randi() % WALL_DIRECTIONS.size()
		sprite.frame = wall
		sprite.position.y -= 44
	
	roof.position.y = sprite.position.y
	$CargoView.rect_position.y = sprite.position.y - 44
	roof.raise()

func opposite(i: int) -> int:
	return [2, 3, 0, 1][i]

func randView() -> void:
	var frool := randi() % FLOOR_DIRECTIONS.size()
	while FLOOR_DIRECTIONS[frool] != direction:
		frool = randi() % FLOOR_DIRECTIONS.size()
	$components/Wall.frame = frool
	
	roof = $components/Roof as Sprite
	roof.frame = randi() % ROOF_DIRECTIONS.size()
	while ROOF_DIRECTIONS[roof.frame] != -1 and ROOF_DIRECTIONS[roof.frame] != direction:
		roof.frame = randi() % ROOF_DIRECTIONS.size()

func destroy():
	if get_child_count() == 0:
		return
	
	if roof:
		get_child(get_child_count() - 1).free()
		
	get_child(get_child_count() - 1).free()
	if get_child_count() == 0:
		queue_free()

func updateWorkplace() -> void:
	if canGetJob():
		Globals.addWorkplace(self)
	else:
		Globals.removeWorkplace(self)


func canGetJob():
	return (maxCargo + maxEmployers) > (cargo.size() + employers.size())

func generateWorker():
	var type: int = getJob()

	var worker = spawnWorker(type)

	if worker:
		if type == WorkerType.CARGO:
			hireCargo(worker)
		else:
			hireEmploye(worker)


func hasCargo() -> bool:
	return capacity > 0

func hasSpace() -> bool:
	return capacity < maxCapacity

func updateCargo() -> void:
	if cargoView:
		cargoView.visible = capacity > 0
		cargoView.text = str(capacity)

func addCargo(amount: int = 1) -> void:
	capacity += amount
	updateCargo()

func subCargo(amount: int = 1) -> bool:
	if amount <= capacity:
		capacity -= min(amount, capacity)
		updateCargo()
		return true

	return false




func getJob() -> int:
	if employers.size() <= cargo.size():
		return employerType
	else:
		return WorkerType.CARGO



func hireCargo(entity: Node2D) -> bool:
	if cargo.size() < maxCargo:
		cargo.append(entity)
		entity.workplace = self
		entity.source = self
		entity.target = Globals.mainStorage
		updateWorkplace()
		return true

	return false

func fireCargo(entity: Node2D) -> void:
	if cargo.size() > 0:
		cargo.erase(entity)
		entity.workplace = null
		updateWorkplace()


func hireEmploye(entity: Node2D) -> bool:
	if employers.size() < maxEmployers:
		employers.append(entity)
		entity.workplace = self
		entity.target = self
		updateWorkplace()
		return true

	return false

func fireEmploye(entity: Node2D) -> void:
	if employers.size() > 0:
		employers.erase(entity)
		entity.workplace = null
		updateWorkplace()


func spawnWorker(workerType: int) -> Node2D:
	var worker: Node2D = null
	
	match workerType:
		WorkerType.UNEMPOLYED:
			worker = preload("res://workers/worker_unemployed.tscn").instance() as Node2D
			Globals.workers += 1
		WorkerType.CARGO:
			worker = preload("res://workers/worker_cargo.tscn").instance() as Node2D
		WorkerType.LUMBER:
			worker = preload("res://workers/worker_lumber.tscn").instance() as Node2D
		WorkerType.BUILDER:
			worker = preload("res://workers/worker_builder.tscn").instance() as Node2D

	if worker:
		self.get_parent().add_child(worker)
		worker.position = self.position
		worker.get_node("car").set_car_type( workerType )

	return worker
