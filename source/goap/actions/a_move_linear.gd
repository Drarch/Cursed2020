extends "res://goap/goap_action.gd"

var point_start = null
var point_end = null

func setup():
	# Called after setup_common()
	cost = 1.0 # Higher cost actions are considered less preferable over lower cost actions when planning
	name = "a_move_linear" # String identifier of this action. setup_common() will make sure the action's node is named after this
	type = TYPE_MOVEMENT # See ancestor script for type descriptions
	# Movement - use add_movement(string id)
	add_movement("linear")
	
	# Preconditions - use add_precondition(string symbol, bool value)
	
	# Effects - use add_effect(string symbol, bool value)
	return

func reset():
	# Called when planner wants to consider this action
	# Sets action's state to the state it should be before running execute() for the first time
	point_end = null
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
	
	point_end = agent.actions_current[1].get_target_location()
	
	if (point_end == null):
		# Target location not set, abort
		set_process(false)
		return ABORTED
	
	if (point_start == point_end):
		# Stop moving
		set_process(false)
		point_end = null
		return COMPLETED

	return CONTINUED

func _process(delta):
	# Move closer to target
	point_start = entity.get_global_position()
	if point_start && point_end:
		var xx = lerp(point_start.x, point_end.x, min(1.0, entity.movementspeed * delta / max(point_start.distance_to(point_end),1)))
		var yy = lerp(point_start.y, point_end.y, min(1.0, entity.movementspeed * delta / max(point_start.distance_to(point_end),1)))
		entity.set_global_position(Vector2(xx, yy))
