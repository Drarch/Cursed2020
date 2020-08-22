extends Sprite

# This is where ore, wood, and tools are stored

var axes = 0
var ore = 1
var picks = 0
var wood = 1
var fish = 3

func _ready():
	update_stock()

func update_stock():
	$picks.text = str(picks)
	$axes.text  = str(axes)
	$wood.text  = str(wood)
	$ore.text   = str(ore)
	$fish.text   = str(fish)
