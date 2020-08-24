extends WorkerBase


func _ready():
	Globals.workerLumber += 1

func _exit_tree():
	Globals.workerLumber -= 1
