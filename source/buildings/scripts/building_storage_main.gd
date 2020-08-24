extends  BuildingBase

func _ready():
	Globals.mainStorage = self


func hireEmploye() -> bool:
	if employers.size() < maxEmployers:
		var entity = spawnWorker(employerType)
		if entity:
			
			employers.append(entity)
			entity.workplace = self
			entity.source = self
			updateWorkplace()
			return true

	return false

func getJob() -> int:
	return employerType
