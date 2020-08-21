extends Sprite
# Gathers and mines ore to be used for new tools

var hasOre = false
var hasPick = false
var movementspeed = 75
var orechunks = 0
onready var pile = get_node("../Stockpile")

func add_orechunk():
	orechunks += 1
	if (orechunks >= 3):
		orechunks = 0
		hasOre = true

	update_inventory()

func update_inventory():
	if orechunks>0:
		$orechunks.text = str(orechunks)
		$orechunks.visible = true
		$ore_block.visible = false
		
	if (hasOre):
		$ore_block.visible = true
		$orechunks.visible = false
	
	$pick.visible = !(!hasPick)

func _draw():
	print ("miner")
	if orechunks>0:
		$orechunks.text = str(orechunks)
		$orechunks.visible = true
		$ore_block.visible = false
		
	if (hasOre):
		$ore_block.visible = true
		$orechunks.visible = false
	
	$pick.visible = !(!hasPick)
