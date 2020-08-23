extends Node2D
class_name WorkerBase

export(float, 1.0, 30.0, 1.0) var movementspeed: float = 10.0
export(float, 0.90, 0.98, 0.01)var friction: float = 0.95

var workplace#: BuildingBase = null

# func findJob(_workplace: BuildingBase) -> void:
# 	workplace = _workplace

# func leaveJob() -> void:
# 	workplace = null


func hasJob() -> bool:
	return workplace != null
