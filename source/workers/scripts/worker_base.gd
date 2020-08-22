extends Node2D
class_name WorkerBase

export(float, 1.0, 30.0, 1.0) var movementspeed: float = 10.0

var workplace#: BuildingBase = null

# func findJob(_workplace: BuildingBase) -> void:
# 	workplace = _workplace

# func leaveJob() -> void:
# 	workplace = null


func hasJob() -> bool:
	return workplace != null
