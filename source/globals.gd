extends Node

var car_civil = [preload("res://sprites/taxi.png"), preload("res://sprites/sedan1.png"), preload("res://sprites/sedan_silver.png"), preload("res://sprites/sedan_green.png"),preload("res://sprites/sedan_blue.png")]
var car_cargo = [preload("res://sprites/truck.png"),preload("res://sprites/truck_red.png")]
var car_lumber = [preload("res://sprites/thrash.png")]
var car_builder = [preload("res://sprites/pickup.png"),preload("res://sprites/ambulance.png"), preload("res://sprites/police.png")]

var maxWorkers: int = 2000
var workers: int = 0

var workerUnemployed: int = 0
var workerCargo:int = 0
var workerLumber:int = 0
var workerBuilder:int = 0



var cityView: Node2D

var navigation: Navigation2D

var mainStorage: BuildingBase

var workplaces: Array = []
var resources: Array = []
var constructionSites: Array = []

func _ready() -> void:
	if not OS.has_feature("editor"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)


func jobsAvailable() -> bool:
	return !workplaces.empty()

func getRandomWorkplace() -> BuildingBase:
	var result: BuildingBase = null
	
	if !workplaces.empty():
		result = workplaces[randi() % workplaces.size()]

	return result

func addWorkplace(_building: BuildingBase) -> void:
	if !workplaces.has(_building):
		workplaces.append(_building)

func removeWorkplace(_building: BuildingBase) -> void:
	workplaces.erase(_building)

func addResource(_resources: ResourceBase) -> void:
	if !resources.has(_resources):
		resources.append(_resources)
	
func removeResources(_resources: ResourceBase) -> void:
	resources.erase(_resources)
	
func addConstructionSite(_cosnstruction) -> void:
	if !constructionSites.has(_cosnstruction):
		constructionSites.append(_cosnstruction)
		
func removeConstructionSite(_cosnstruction) -> void:
	constructionSites.erase(_cosnstruction)

