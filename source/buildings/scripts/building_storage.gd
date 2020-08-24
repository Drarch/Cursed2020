extends  BuildingBase

func setView() -> void:
	var frool := randi() % FLOOR_DIRECTIONS.size()
	while FLOOR_DIRECTIONS[frool] != direction:
		frool = randi() % FLOOR_DIRECTIONS.size()
	$components/Wall.frame = frool
	
	roof = $components/Roof as Sprite
	roof.frame = randi() % 8 + 48
#	while ROOF_DIRECTIONS[roof.frame] != -1 and ROOF_DIRECTIONS[roof.frame] != direction:
#		roof.frame = randi() % ROOF_DIRECTIONS.size()
