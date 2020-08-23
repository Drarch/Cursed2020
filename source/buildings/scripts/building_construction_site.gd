extends Node2D

var constructionType: int
var building: BuildingBase
var cell = Vector2()

func _ready():
	Globals.addConstructionSite(self)
	
func build():
	Globals.cityView.constructSpecific( cell, constructionType )
	Globals.removeConstructionSite(self)
	queue_free()
