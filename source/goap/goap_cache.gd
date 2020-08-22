extends Node

const UPDATE_INTERVAL_DEFAULT = 0.5 # Time in seconds between an agent's execute() calls
const UPDATE_PAUSE_DEFAULT = 5.0 # Time in seconds for which an agent will not call execute() when no plan could be formed

# Debug variables. Enable printout to console on startup
var debug_show_cache_actions = false
var debug_show_cache_actions_from_effect = false
var debug_show_cache_actions_from_effect_value = false
var debug_show_cache_actions_from_precondition = false
var debug_show_cache_actions_from_precondition_value = false
var debug_show_cache_actions_from_type = false
var debug_show_cache_goals = false
var debug_show_cache_goals_from_symbol = false
var debug_show_cache_goals_from_symbol_value = false
var debug_show_cache_symbols = false

# This script must be autoloaded with name "GOAP_CACHE" in order to be usable by the GOAP system
# Holds data that an agent might need, but would be too ineffective to save on a per agent basis, because many agents need to access the same data
# Also holds functions for custom datastructures

# cache_actions - a dictionary of all actions available to the goap system with keys being the name of the action script and the value being the filepath. Read in at compile. Actions must be stored in res://goap/actions
# cache_actions_from_effect - a dictionary with keys being the symbols used and the value being an array with the names of the actions that change the symbol
# cache_actions_from_effect_value - a dictionary with keys being a symbol and either "|true" or "|false" appended as key and action names as values in an array
# cache_actions_from_precondition - a dictionary with keys being the symbols necessary to make an action valid and as values an array with the names of actions that need this symbol
# cache_actions_from_precondition_value - a dictionary with keys being a symbol and either "|true" or "|false" appended as key and action names as values in an array
# cache_actions_from_type - an array with the names of actions sorted by type (NORMAL, REPEATABLE etc.)

# cache_goals - a dictionary of all goals available to the goap system with keys being the name of the goal script and the value being the filepath. Read in at compile. Goals must be stored in res://goap/goals
# cache_goals_from_symbol - a dictionary with keys being the symbols used to evaluate goal's satisfaction status and value being the name of goals with this symbol
# cache_goals_from_symbol_value - a dicitionary with keys being the symbols used to evaluate the goal's status and either "|true" or "|false" appended, the values being names of goals with these symbols in this state

# cache_symbols - an array of all symbols (strings) used by all goap_agents

var cache_actions = {} # Typical entry: {"a_eatPlant":"res://goap/actions/a_eatPlant.gd", "a_drinkFromPuddle":"res://goap/actions/a_drinkFromPuddle.gd"}
var cache_actions_from_effect = {} # Typical entry: {"s_atePlant":["a_eatPlant"], "s_drankWater":["a_drinkFromPuddle", "a_drinkFromRiver", "a_drinkFromWell"]}
var cache_actions_from_effect_value = {} # Typical entry: {"s_atePlant|True":["atePlant"], "s_hasWeapon|False":["a_dropWeapon"]}
var cache_actions_from_precondition = {} # Typical entry: {"s_isAlive":["a_eatPlant", "a_drinkWater"], "s_canMove":["a_attackMelee"]}
var cache_actions_from_precondition_value = {} # Typical entry: {"s_hasAmmo|True":["a_pickupAmmo"]}
var cache_actions_from_type = [] # Typical entry: [0]["a_eatPlant", "a_drinkWater"], [1]["a_drinkPotion", "a_healWounds"]

var cache_goals = {} # Typical entry: {"g_beHydrated":"res://goap/goals/g_beHydrated.gd"}
var cache_goals_from_symbol = {} # Typical entry: {"s_atePlant":["g_eatPlants"], "s_drankWater":["g_drinkWater"]}
var cache_goals_from_symbol_value = {} # Typical entry: {"s_atePlant|True":["g_eatPlants"]}

var cache_symbols = [] # Typical entry: ["s_atePlant", "s_drankWater"]

func _ready():
	# Read in all actions
	var dir = Directory.new()
	if (dir.open("res://goap/actions") == OK):
		# Iterate through all files
		dir.list_dir_begin()
		var filename = dir.get_next()
		while (filename != ""):
			if (filename.begins_with("a_") && filename.ends_with(".gd")):
				filename = filename.get_basename()
				cache_actions[filename] = "res://goap/actions/" + filename + ".gd"
				if (debug_show_cache_actions): print("GOAP PRELOAD: Added action " + str(filename))
			
			filename = dir.get_next()

		dir.list_dir_end()
	else:
		print("GOAP FATAL ERROR: CACHE COULD NOT LOCATE ACTIONS DIRECTORY!")
	
	# Read in all goals
	dir = Directory.new()
	if (dir.open("res://goap/goals") == OK):
		# Iterate through all files
		dir.list_dir_begin()
		var filename = dir.get_next()
		while (filename != ""):
			if (filename.begins_with("g_") && filename.ends_with(".gd")):
				filename = filename.get_basename()
				cache_goals[filename] = "res://goap/goals/" + filename + ".gd"
				if (debug_show_cache_goals): print("GOAP PRELOAD: Added goal " + str(filename))
			filename = dir.get_next()
		dir.list_dir_end()
	else:
		print("GOAP FATAL ERROR: CACHE COULD NOT LOCATE GOALS DIRECTORY!")

	# Actions need to be loaded once to get their effects and preconditions. This can't happen in _ready(), so call a deferred setup. Same for goals and their symbols
	call_deferred("setup")
	call_deferred("printout")

func setup():
	# Analyze goals for symbols
	for goal_name in cache_goals.keys():
		# In order for goals to have symbols, one must be spawned and readied
		var goal = load(cache_goals[goal_name]).new()
		add_child(goal)
		goal.setup()
		
		var symbols = goal.goals.keys()
		for symbol in symbols:
			if (!cache_symbols.has(symbol)):
				# Symbol hasn't been added yet, so do that
				cache_symbols.append(symbol)
				if (debug_show_cache_symbols): print("GOAP PRELOAD: Added '" + symbol + "' to symbols")
			
			if (!cache_goals_from_symbol.has(symbol)):
				cache_goals_from_symbol[symbol] = []
			
			cache_goals_from_symbol[symbol].append(goal_name)
			if (debug_show_cache_goals_from_symbol): print("GOAP PRELOAD: Added '" + goal_name + "' to cache_goals_from_symbol[" + symbol + "]")
			
			var valuekey = symbol + "|" + str(goal.goals[symbol])
			
			if (!cache_goals_from_symbol_value.has(valuekey)):
				cache_goals_from_symbol_value[valuekey] = []
				if (debug_show_cache_goals_from_symbol_value): print("GOAP PRELOAD: Added '" + valuekey + "' as key to cache_goals_from_symbol_value")
			
			cache_goals_from_symbol_value[valuekey].append(goal_name)
			if (debug_show_cache_goals_from_symbol_value): print("GOAP PRELOAD: Added '" + goal_name + "' to cache_goals_from_symbol_value[" + valuekey + "]")

		goal.queue_free()

	# Analyze actions for symbols both in effects and preconditions
	for action_name in cache_actions.keys():
		# In order to get the effects and preconditions, an instance of an action has to exist, because eff. and prec. are assigned after _ready() was called
		var action = load(cache_actions[action_name]).new()
		add_child(action)
		action.setup()

		# Loop through all effects
		var symbols = action.effects
		for symbol in symbols.keys():
			if (!cache_symbols.has(symbol)):
				cache_symbols.append(symbol)
				if (debug_show_cache_symbols): print("GOAP PRELOAD: Added '" + symbol + "' to symbols")
			
			if (!cache_actions_from_effect.has(symbol)):
				cache_actions_from_effect[symbol] = []
				if (debug_show_cache_actions_from_effect): print("GOAP PRELOAD: Added '" + symbol + "' as key to cache_actions_from_effect")

			cache_actions_from_effect[symbol].append(action_name)
			if (debug_show_cache_actions_from_effect): print("GOAP PRELOAD: Added '" + action_name + "' to cache_actions_from_effect[" + symbol + "]")

			var valuekey = symbol + "|" + str(symbols[symbol])
			
			if (!cache_actions_from_effect_value.has(valuekey)):
				cache_actions_from_effect_value[valuekey] = []
				if (debug_show_cache_actions_from_effect_value): print("GOAP PRELOAD: Added '" + valuekey + "' as key to cache_actions_from_effect_value")
			
			cache_actions_from_effect_value[valuekey].append(action_name)
			if (debug_show_cache_actions_from_effect_value): print("GOAP PRELOAD: Added '" + action_name + "' to cache_actions_from_effect_value[" + valuekey + "]")

		# Loop through all preconditions
		symbols = action.preconditions
		for symbol in symbols.keys():
			if (!cache_symbols.has(symbol)):
				cache_symbols.append(symbol)
				if (debug_show_cache_symbols): print("GOAP PRELOAD: Added '" + symbol + "' to symbols")
			
			if (!cache_actions_from_precondition.has(symbol)):
				cache_actions_from_precondition[symbol] = []
				if (debug_show_cache_actions_from_precondition): print("GOAP PRELOAD: Added '" + symbol + "' as key to cache_actions_from_precondition")
			
			cache_actions_from_precondition[symbol].append(action_name)
			if (debug_show_cache_actions_from_precondition): print("GOAP PRELOAD: Added '" + action_name + "' to cache_actions_from_precondition[" + symbol + "]")
			
			var valuekey = symbol + "|" + str(symbols[symbol])
			
			if (!cache_actions_from_precondition_value.has(valuekey)):
				cache_actions_from_precondition_value[valuekey] = []
				if (debug_show_cache_actions_from_precondition_value): print("GOAP PRELOAD: Added '" + valuekey + "' as key to cache_actions_from_precondition_value")
			
			cache_actions_from_precondition_value[valuekey].append(action_name)
			if (debug_show_cache_actions_from_precondition_value): print("GOAP PRELOAD: Added '" + action_name + "' to cache_actions_from_precondition_value[" + valuekey + "]")

		# Cache by type
		if (action.type> cache_actions_from_type.size() - 1):
			# New type introduced, enlargen cache array
			cache_actions_from_type.resize(action.type + 1)
			
			# Set new indexes to empty lists for actions to be appended to
			var i = 0
			while (i < cache_actions_from_type.size()):
				if (cache_actions_from_type[i] == null): cache_actions_from_type[i] = []
				i += 1

		cache_actions_from_type[action.type].append(action_name)
		if (debug_show_cache_actions_from_type): print("GOAP PRELOAD: Added '" + action_name + "' to cache_actions_from_type[" + str(action.type) + "]")

		action.queue_free()

func printout():
	# Print the contents of all action and goal cashes to the console
	if (debug_show_cache_actions): print("GOAP PRELOAD READOUT: cache_actions = " + str(cache_actions))
	if (debug_show_cache_actions_from_effect): print("GOAP PRELOAD READOUT: cache_actions_from_effect = " + str(cache_actions_from_effect)) 
	if (debug_show_cache_actions_from_effect_value): print("GOAP PRELOAD READOUT: cache_actions_from_effect_value = " + str(cache_actions_from_effect_value)) 
	if (debug_show_cache_actions_from_precondition): print("GOAP PRELOAD READOUT: cache_actions_from_precondition = " + str(cache_actions_from_precondition)) 
	if (debug_show_cache_actions_from_precondition_value): print("GOAP PRELOAD READOUT: cache_actions_from_precondition_value = " + str(cache_actions_from_precondition_value))
	if (debug_show_cache_actions_from_type): print("GOAP PRELOAD READOUT: cache_actions_from_type = " + str(cache_actions_from_type))

	if (debug_show_cache_goals): print("GOAP PRELOAD READOUT: cache_goals = " + str(cache_goals))
	if (debug_show_cache_goals_from_symbol): print("GOAP PRELOAD READOUT: cache_goals_from_symbol = " + str(cache_goals_from_symbol))
	if (debug_show_cache_goals_from_symbol_value): print("GOAP PRELOAD READOUT: cache_goals_from_symbol_value = " + str(cache_goals_from_symbol_value))

	if (debug_show_cache_symbols): print("GOAP PRELOAD READOUT: cache_symbols: " + str(cache_symbols))

func get_cache_actions():
	return cache_actions

func get_cache_actions_from_effect():
	return cache_actions_from_effect

func get_cache_actions_from_effect_value():
	return cache_actions_from_effect_value

func get_cache_actions_from_precondition():
	return cache_actions_from_precondition

func get_cache_actions_from_precondition_value():
	return cache_actions_from_precondition_value

func get_cache_actions_from_type():
	return cache_actions_from_type

func get_cache_goals():
	return cache_goals

func get_cache_goals_from_symbol():
	return cache_goals_from_symbol

func get_cache_goals_from_symbol_value():
	return cache_goals_from_symbol_value

func get_cache_symbols():
	return cache_symbols
