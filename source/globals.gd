extends Node

var cityView: Node2D

var navigation: Navigation2D

func _ready() -> void:
	if not OS.has_feature("editor"):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
var navigation: Navigation2D

var mainStorage: BuildingBase

var workplaces: Array = []


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