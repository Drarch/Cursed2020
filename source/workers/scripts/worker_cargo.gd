extends WorkerBase


func _ready():
	Globals.workerCargo += 1

func _exit_tree():
	Globals.workerCargo -= 1
