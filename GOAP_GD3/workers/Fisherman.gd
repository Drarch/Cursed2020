extends Sprite

# The blacksmith takes wood and ore from the stockpile and turns them into axes and picks

var hasFish = false

var movementspeed = 50
onready var pile = get_node("../Stockpile")

func _ready():
	pass
	
func update_inventory():
	$fish.visible = hasFish

func _draw():
	$fish.visible = hasFish
