extends WorkerBase


func _ready():
	Globals.workerBuilder += 1

func _exit_tree():
	Globals.workerBuilder -= 1
