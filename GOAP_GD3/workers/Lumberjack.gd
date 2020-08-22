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
		
	if (hasWood):
		$twigs.visible = false
		
	$wood.visible = hasWood
	$axe.visible = !(!hasAxe)

func _draw():
	if twigs>0:
		$twigs.text = str(twigs)
		$twigs.visible = true
		
	if (hasWood):
		$twigs.visible = false
		
	$wood.visible = hasWood
	$axe.visible = !(!hasAxe)
