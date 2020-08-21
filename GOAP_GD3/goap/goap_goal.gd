
extends Node



######################
# BEGIN COPY CONTENT #
######################

#extends "res://goap/goap_goal.gd"



func setup():
	
	# Called after setup_common()
	
	name = "" # String to identify the goal from others after creation
	priority = 1.0 # The higher this number, the more important the goal. Agent will always want to fulfill the goal with the highest priority first
	type = TYPE_NORMAL # Defines goal type. Definitions of enums are found in ancestor script
	
	# Define symbols by adding them to goals list with add_symbol(string symbol, bool value)
	
	return



func evaluate():
	
	# Go through all symbols and check if they are in the state this goal desires
	# If one symbol is not fulfilled, this goal may be used in planning
	# Returns a dictionary of all of goal's symbols in worldstate if any is not satisfied, otherwise null
	
	return null



func on_completion():
	
	# Fires when all symbols of this goal have the desired state after completion of an action by a GOAP agent, signified by the completion of the last action in the plan
	# 'times_completed' increases by one each time before this event is called
	# Signal 'goal_completed' is emitted after this, unless 'emit_signal' is set to false
	# ONESHOT goals will delete themselves after this
	# DIMINISHING type goals will reduce their priority automatically to (priority_default ( == priority in setup()) / times_completed + 1)
	
	return



####################
# END COPY CONTENT #
####################



const TYPE_CRITICAL = 0 # This goal / symbol is always checked against when formulating a plan as it is crucial to the entity's nature and health
const TYPE_NORMAL = 1 # This goal / symbol may be pushed back if there can't be a plan formulated for it to let other goals come into consideration
const TYPE_REPEATABLE = 2 # This goal / symbol may be repeatedly executed
const TYPE_DIMINISHING = 3 # This goal / symbol becomes increasingly more undesirable
const TYPE_IDLE = 4 # This goal / symbol is only considered when all other type are satisfied (meaning there aren't any goals of other types left to fulfill)
const TYPE_ONESHOT = 5 # This goal removes itself from the system after completion



signal goal_completed



var agent # The goap_agent that has this action as grandchild. Set by agent
var entity # The object the goap_agent is attached to. Set by agent

var emit_signal = true # If true, emits signal 'goal_completed' after own completion function ran
var goals = {} # Dicitonary of all possible goalstates to be returned with priorities and type
#var name = "" # String to identify the goal from others after creation
var priority = 1.0 # The higher this number, the more important the goal. Agent will always want to fulfill the goal with the highest priority first
var priority_default = 1.0 # This is used for diminishing type goals, whose priority sinks with completion
var times_completed = 0 # To be used in goal logic
var times_completed_total = 0 # Stat counter. Not used in calculations
var type = TYPE_NORMAL # Defines goal type. See enums / const for more info



func _ready():
	
	call_deferred("setup_common")



func setup_common():
	
	setup()
	
	# If node is not named after this goal, rename it
	if (name != ""): set_name(name)
	
	# Set priority value for diminishing type goals
	priority_default = priority
	
	return



func on_completion_common():
	
	# Called when all symbols are satisfied through an action by a GOAP agent
	times_completed += 1
	times_completed_total += 1
	
	on_completion() # Call specified code
	
	if (emit_signal):
		
		emit_signal("goal_completed")
	
	# Delete ONESHOT goals
	if (type == TYPE_ONESHOT):
		
		agent.remove_goal(name)
	
	# Make diminishing goals less desirable
	if (type == TYPE_DIMINISHING):
		
		priority = priority_default / times_completed + 1



func add_symbol(symbol, value = true):
	
	# Adds a symbol to the dictionary of goalstates
	# Due to the nature of dictionaries, duplicate symbols can not exist
	
	goals[symbol] = value
	
	return



func delete_symbol(symbol):
	
	# Synonym of remove_symbol()
	goals.erase(symbol)
	
	return



func get_goals():
	
	# Synonym of get_goalstate()
	var out = {}
	for key in goals.keys():
		
		out[key] = goals[key]
	
	return out



func get_goalstate():
	
	# Synonym of get_goals()
	var out = {}
	for key in goals.keys():
		
		out[key] = goals[key]
	
	return out

func remove_symbol(symbol):
	
	# Synonym of delete_symbol()
	goals.erase(symbol)
	
	return
