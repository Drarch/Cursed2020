extends Node

var cityView: Node2D

var navigation: Navigation2D

var mainStorage: BuildingBase

var workplaces: Array = []


func addWorkplace(_building: BuildingBase) -> void:
	if !workplaces.has(_building):
		workplaces.append(_building)

func removeWorkplace(_building: BuildingBase) -> void:
	workplaces.erase(_building)