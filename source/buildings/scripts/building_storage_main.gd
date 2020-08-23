extends  BuildingBase

func _ready():
	Globals.mainStorage = self


func hireEmploye(entity: Node2D) -> bool:
	if employers.size() < maxEmployers:
		employers.append(entity)
		entity.workplace = self
		entity.source = self
		updateWorkplace()
		return true

	return false