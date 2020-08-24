extends WorkerBase


func _ready():
	Globals.workerUnemployed += 1

func _exit_tree():
	Globals.workerUnemployed -= 1
