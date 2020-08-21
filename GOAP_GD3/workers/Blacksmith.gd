extends Sprite

# The blacksmith takes wood and ore from the stockpile and turns them into axes and picks

var hasAxe  := false
var hasOre  := false
var hasPick := false
var hasWood := false
var movementspeed = 50
onready var pile = get_node("../Stockpile")

func _ready():
	print("smith ready")
	
func update_inventory():
	$ore.visible = !(!hasOre)
	$wood.visible = !(!hasWood)
	
	$axe.visible = !(!hasAxe)
	$pick.visible = !(!hasPick)

func _draw():
	print("smith")
	$ore.visible = !(!hasOre)
	$wood.visible = !(!hasWood)
	
	$axe.visible = !(!hasAxe)
	$pick.visible = !(!hasPick)
