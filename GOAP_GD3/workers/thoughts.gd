extends Label

var timer := 0.0
var timeout := 3.0
func _ready():
	text = "Hello World"

func _process( delta:float ):
	if timer < timeout:
		timer += delta
		if timer >= timeout:
			text = ""

func think( thought:String ):
	if timer >= timeout:
		text = thought
		timeout = 3.0
	else:
		text += "\n"+thought
		timeout += 1.0
