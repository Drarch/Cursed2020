extends Node

######################
# START COPY CONTENT #
######################

#extends "res://goap/goap_action.gd"

func setup():
	# Called after setup_common()
	cost = 0.0 # Higher cost actions are considered less preferable over lower cost actions when planning
	name = "" # String identifier of this action. setup_common() will make sure the action's node is named after this
	type = TYPE_NORMAL # See ancestor script for type descriptions
	# Movement - use add_movement(string id)
	# Preconditions - use add_precondition(string symbol, bool value)
	# Effects - use add_effect(string symbol, bool value)
	return

func reset():
	# Called when planner wants to consider this action
	# Sets action's state to the state it should be before running execute() for the first time
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
	return COMPLETED

####################
# END COPY CONTENT #
####################

###########
# GENERAL #
###########

const ABORTED = 0 # Action's execution code has encountered an unsolvable state, it is aborting its execution
const CONTINUED = 1 # Action's execution code has run successfully, but the action is not done yet
const COMPLETED = 2 # Action's execution code has run successfully and the action is done executing
const TYPE_NORMAL = 0 # Action may be used once in a plan
const TYPE_REPEATABLE = 1 # Action may be used multiple times in a plan
const TYPE_MOVEMENT = 2 # Action may be used multiple times in a plan. Changes entity position

signal aborted # Emitted when this action could not proceed execution
signal completed # Emitted when this action has achieved what it wanted to do
signal ended # Action has stopped executing

var agent # The goap_agent that has this action as grandchild. Set by agent
var entity # The object the goap_agent is attached to. Set by agent

var cost = 0.0 # Higher cost actions are considered less preferable over lower cost actions when planning
#var name = "" # String identifier of this action. setup_common() will make sure the action's node is named after this
var type = TYPE_NORMAL # Defines the action's type, which determines reusability in a plan

func _ready():
	call_deferred("setup_common")

func execute_common():
	# Call specific execution code
	return execute()

func reset_common():
	# Call specific reset code
	reset()

func setup_common():
	# Call specific setup code
	setup()
	if (name != ""): set_name(name)

##############
# SETGETTERS #
##############

func get_type():
	return type

#############################
# EFFECTS AND PRECONDITIONS #
#############################

var effects = {}
var movements = {} # List of movement symbols the action may use to get to target_location
var preconditions = {}

func add_effect(symbol, boolean):
	effects[symbol] = boolean

func add_movement(id):
	movements[id] = true

func add_precondition(symbol, boolean):
	preconditions[symbol] = boolean

func get_effects():
	return effects

func get_preconditions():
	return preconditions

func remove_effect(symbol):
	if (effects.has(symbol)): effects.erase(symbol)

func remove_precondition(symbol):
	if (preconditions.has(symbol)): preconditions.erase(symbol)
