extends "res://goap/goap_action.gd"

# onready var navigation = 

var path := []

var pointStart = null
var pointEnd = null
var pointCurrent = null

var moving: bool = false

func setup():
	# Called after setup_common()
	cost = 1.0 # Higher cost actions are considered less preferable over lower cost actions when planning
	name = "a_move_navigation_2D" # String identifier of this action. setup_common() will make sure the action's node is named after this
	type = TYPE_MOVEMENT # See ancestor script for type descriptions
	
	# Movement - use add_movement(string id)
	add_movement("navigation2d")
	
	# Preconditions - use add_precondition(string symbol, bool value)
	
	# Effects - use add_effect(string symbol, bool value)
	return

func reset():
	# Called when planner wants to consider this action
	# Sets action's state to the state it should be before running execute() for the first time
	pointEnd = null
	moving = false
	path.clear()

	return

func evaluate():
	# Planner calls this after resetting the action
	# If returning true, the planner will consider this action for its current plan
	# If returning false, the planner will not include this action in the plan for the currently inspected goal at all!
	return true

func get_cost():
	# Called when the planner wants to calculate the next best action
	# Higher cost actions are considered less preferable over lower cost actions when planning
	return cost

func get_target_location():
	# This is called when a TYPE_MOVEMENT action is to be executed by the agent next
	# The agent will call 'get_target_location()' on the action coming after the TYPE_MOVEMENT action in the current plan
	# This function must return a Vector2 as coordinate in the world to move to
	# If returning null, agent will abort plan, since its movement does not have a valid target
	# This function should only need to return a Vector2 if it has a precondition "s_atPoint" or similar, 
	# 	so TYPE_MOVEMENT actions should only be planned to occur before actions that need the agent to be at a 
	# 	certain location and therefore are able to return a position to move to
	return null

func execute():
	# Manipulate the world through this code
	# Gets called in intervals. The deltatime between these calls is stored as 'lastdelta'
	# Return one of these constants:
	#  - ABORTED - Action's execution code has encountered an unsolvable state, it is aborting its execution
	#  - CONTINUED - Action's execution code has run successfully, but the action is not done yet
	#  - COMPLETED - Action's execution code has run successfully and the action is done executing
	
	# Move towards target position via linear interpolation
	if (!is_processing()):
		# Start movement
		set_process(true)
		moving = true
		pointEnd = agent.actions_current[1].get_target_location()
		_calculatePath(pointEnd)
		pointEnd = path.back()
	

	if (pointEnd == null):
		# Target location not set, abort
		reset()
		set_process(false)
		return ABORTED
	
	
	if entity.position.distance_squared_to(pointEnd) < 1000:
		# Stop moving
		set_process(false)
		reset()
		return COMPLETED

	return CONTINUED

func _process(delta):
	# Move closer to target
	pointStart = entity.get_global_position()

	# if pointStart && pointEnd:
	# 	var xx = lerp(pointStart.x, pointEnd.x, min(1.0, entity.movementspeed * delta / max(pointStart.distance_to(pointEnd),1)))
	# 	var yy = lerp(pointStart.y, pointEnd.y, min(1.0, entity.movementspeed * delta / max(pointStart.distance_to(pointEnd),1)))
	# 	entity.set_global_position(Vector2(xx, yy))

	if pointStart && !path.empty():
		# player.position += player.position.direction_to(points.front()) * 400 * delta
		pointCurrent = path.front()

		var xx = lerp(pointStart.x, pointCurrent.x, min(1.0, entity.movementspeed * delta / max(pointStart.distance_to(pointCurrent),1)))
		var yy = lerp(pointStart.y, pointCurrent.y, min(1.0, entity.movementspeed * delta / max(pointStart.distance_to(pointCurrent),1)))

		entity.set_global_position(Vector2(xx, yy))
		
		if entity.position.distance_squared_to(pointCurrent) < 1000:
			path.pop_front()
	


func _calculatePath(destination: Vector2) -> void:
	path = Globals.navigation.get_simple_path(entity.position, destination, false)
