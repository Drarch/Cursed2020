extends Node2D
class_name ConstructionSite

var constructionType: int
var building: BuildingBase
var cell = Vector2()

func _ready():
	Globals.addConstructionSite(self)
	
func build():
	if building:
		building.increase()
	else:
		Globals.cityView.constructSpecific( cell, constructionType )
	Globals.removeConstructionSite(self)
	queue_free()

func increase():
	build()

