extends Node2D
class_name WorkerBase

onready var cargoView: Sprite = $Cargo

export(float, 1.0, 30.0, 1.0) var movementspeed: float = 10.0
export(float, 0.90, 0.98, 0.01)var friction: float = 0.95

var workplace#: BuildingBase = null

var source: Node2D
var target: Node2D

var cargo: int = 0

# func findJob(_workplace: BuildingBase) -> void:
# 	workplace = _workplace

# func leaveJob() -> void:
# 	workplace = null


func hasJob() -> bool:
	return false
	return workplace != null

func hasCargo() -> bool:
	return cargo > 0

func updateCargo() -> void:
	cargoView.visible = cargo > 0
	cargoView.frame = randi() % 10

func takeCargo(amount: int = 1) -> void:
	cargo += amount
	updateCargo()

func dropCargo(amount: int = 1) -> void:
	cargo -= min(amount, cargo)
	updateCargo()

#func _draw():
#	var path = $GOAP_Agent/Actions/a_move_navigation_2D.path
#	for i in path.size()-1:
#		draw_line(path[i]-position, path[i+1]-position, Color.black, 3 )
#	draw_line(Vector2.ZERO, $GOAP_Agent/Actions/a_move_navigation_2D.final_destination - position, Color.red, 3 )
