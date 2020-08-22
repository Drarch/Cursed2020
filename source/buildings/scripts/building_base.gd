extends Node2D
class_name BuildingBase

const FLOOR_DIRECTIONS := [0, 1, 0, 1, 2, 3, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0 , 1, 0, 1, 0, 1, 0, 1, 2, 3, 0, 0, 1, 3, 2, 2, 3, 0, 1, 2, 3, 0, 1, 0, 0, 1, 1, 0, 1]
const WALL_DIRECTIONS := [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, -1, -1, -1, -1, -1, -1, -1, -1]
const ROOF_DIRECTIONS := [-1, -1, -1, -1, 0, 1, 3, 2,0, 1, 3, 2, 0, 1, 3, 2, 0 , 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1, 3, 2, 0, 1,3, 2, 0, -1, -1, -1, -1, -1, -1, -1]

onready var roof := $Roof as Sprite

var direction: int

func _ready() -> void:
	# Globals.cityView.construct(self)
	pass

func increase():
	var sprite := get_child(get_child_count() - 2).duplicate() as Sprite
	sprite.position.y -= 33
	add_child(sprite)
	
	if get_child_count() == 3:
		sprite.texture = preload("res://tileset/tileset_buildings_walls.png")
		sprite.hframes = 8
		sprite.vframes = 3
		
		var wall := randi() % WALL_DIRECTIONS.size()
		while WALL_DIRECTIONS[wall] != -1 and WALL_DIRECTIONS[wall] != direction and WALL_DIRECTIONS[wall] != opposite(direction):
			wall = randi() % WALL_DIRECTIONS.size()
		sprite.frame = wall
		sprite.position.y -= 44
	
	roof.position.y = sprite.position.y
	roof.raise()

func opposite(i: int) -> int:
	return [2, 3, 0, 1][i]

func randView() -> void:
	var frool := randi() % FLOOR_DIRECTIONS.size()
	while FLOOR_DIRECTIONS[frool] != direction:
		frool = randi() % FLOOR_DIRECTIONS.size()
	$Wall.frame = frool
	
	roof = $Roof as Sprite
	roof.frame = randi() % ROOF_DIRECTIONS.size()
	while ROOF_DIRECTIONS[roof.frame] != -1 and ROOF_DIRECTIONS[roof.frame] != direction:
		roof.frame = randi() % ROOF_DIRECTIONS.size()

func destroy():
	if roof:
		get_child(get_child_count() - 1).free()
		
	get_child(get_child_count() - 1).free()
	if get_child_count() == 0:
		queue_free()
