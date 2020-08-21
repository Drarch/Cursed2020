extends Sprite
# Gathers and chops wood to be used for new tools

var hasAxe = false
var hasWood = false
var movementspeed = 60
onready var pile = get_node("../Stockpile")
var twigs = 0

func add_twig():
	twigs += 1

	if (twigs >= 3):
		twigs = 0
		hasWood = true
		$twigs.visible = false
		
	update_inventory()

func update_inventory():
	if twigs>0:
		$twigs.text = str(twigs)
		$twigs.visible = true
		$wood.visible = false
		
	if (hasWood):
		$wood.visible = true
		$twigs.visible = false
	
	$axe.visible = !(!hasAxe)

func _draw():
	print("lumber dude")
	if twigs>0:
		$twigs.text = str(twigs)
		$twigs.visible = true
		$wood.visible = false
		
	if (hasWood):
		$wood.visible = true
		$twigs.visible = false
	
	$axe.visible = !(!hasAxe)
