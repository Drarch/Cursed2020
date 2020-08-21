extends Node

######################
# BEGIN COPY CONTENT #
######################
#extends "res://goap/goap_agent.gd"

# Agent emits following signals:
#  - action_completed - Emitted when an action returns ACTION_COMPLETED and is subsequently popped off the queue
#  - no_goals - Emitted when the planner tries to work, but arrived at the end of goals_current
#  - plan_aborted - Emitted when an action failed execution and therefore broke the plan
#  - plan_failed - Emitted when no valid plan could be found
#  - plan_finished - Emitted when a plan was fully and successfully executed
#  - plan_found - Emitted when a valid plan was found
func setup():
	# Called after setup_common(), which is called deferredly in _ready()

	# ATTENTION! If the agent is not at "entity/agent" in the entity's node tree, change and uncomment the 'entity = ' line below!
#	entity = get_node("../")

	update_interval = GOAP_CACHE.UPDATE_INTERVAL_DEFAULT # Time in seconds between each call of execute()
	update_pause = GOAP_CACHE.UPDATE_PAUSE_DEFAULT # Time in seconds the agent will not plan / execute for when a plan could not be formed

	debug_connect_planstatus = false
	debug_show_call_build_graph = false
	debug_show_call_execute = false
	debug_show_call_generate_goalqueue = false
	debug_show_call_generate_plan = false
	debug_show_call_interval = false
	debug_show_call_plan = false
	debug_show_call_setup_common = false

	return

####################
# END COPY CONTENT #
####################

###################
# DEBUG VARIABLES #
###################

var debug_connect_planstatus = true
var debug_show_call_build_graph = true
var debug_show_call_execute = false
var debug_show_call_generate_goalqueue = false
var debug_show_call_generate_plan = false
var debug_show_call_interval = false
var debug_show_call_plan = false
var debug_show_call_setup_common = false

func no_goals():
	entity.get_node("Thoughts").think("I have not thing to do!")

func plan_aborted(action_name):
	entity.get_node("Thoughts").think("I'll stop what I'm doing! I'll: " + action_name)

func plan_failed():
	entity.get_node("Thoughts").think("I had a PLAN, but it ende as usual: FAILED!")

func plan_found(cost):
	var plan_string = ""
	var i = 0
	while (i < actions_current.size()):
		plan_string += actions_current[i].name + "\n"
		i += 1
	entity.get_node("Thoughts").think("I have a PLAN!\nCOST: " + str(cost) + "\nPLAN: " + plan_string)

###########
# GENERAL #
###########

var entity # The parent object using this agent
var update_interval = GOAP_CACHE.UPDATE_INTERVAL_DEFAULT # Time in seconds between each call of execute()
var update_pause = GOAP_CACHE.UPDATE_PAUSE_DEFAULT # Time in seconds the agent will not plan / ececute for when a plan could not be formed
var updater # Timer object that calls interval()

func _ready():
	call_deferred("setup_common")

func setup_common():
	actions = get_node("Actions")
	entity = get_node("../")
	goals = get_node("Goals")

	if (debug_show_call_setup_common): entity.get_node("Thoughts").think("I have CALLED setup_common()")
	# Go through all actions and goals and set their agent and entity references
	for action in actions.get_children():
		action.agent = self
		action.entity = entity
		if (action.type == action.TYPE_MOVEMENT):
			actions_movement.append(action)
		else:
			actions_available.append(action)

	if (actions_available.size() < 1):
		entity.get_node("Thoughts").think("I have NO ACTIONS AVAILABLE!")

	for goal in goals.get_children():
		goal.agent = self
		goal.entity = entity
		goals_available.append(goal)

	if (goals_available.size() < 1):
		entity.get_node("Thoughts").think("I have NO GOALS AVAILABLE!")

	setup() # Calls specific setup that is overwritten by agent implementations

	# Initialise updating timer
	updater = Timer.new()
	add_child(updater)
	updater.set_wait_time(update_interval)
	updater.connect("timeout", self, "interval")
	updater.start()

	if (debug_connect_planstatus):
		connect("no_goals", self, "no_goals")
		connect("plan_failed", self, "plan_failed")
		connect("plan_found", self, "plan_found")

###########
# PLANNER #
###########
signal no_goals # Emitted when the planner tries to work, but arrived at the end of goals_current
signal plan_failed # Emitted when no valid plan could be found
signal plan_found # Emitted when a valid plan was found

var actions_current = [] # Queue of actions part of the plan currently executed. [0] is the action currently to be performed
var actions_movement = [] # Unsorted list of actions that allow the entity to change its position. This may be required several times over in a plan, which is why it has a special pool
var goals_current = [] # Queue of goals sorted by urgency. [0] is the goal the planner wants to work on. If that fails, [0] is popped off and the next goal inspected

func generate_plan():
	if (debug_show_call_generate_plan): entity.get_node("Thoughts").think("I have CALLED generate_plan()")
	# Set goals_current to be a list of goals to be fulfilled
	generate_goalqueue()

	if (goals_current.size() < 1):
		# No goals found
		emit_signal("no_goals")
		return

	# Work on goal with highest priority
	while (goals_current.size() > 0):
		# Try to plan for goal. goals_current entries are arrays of size 2, with
		#  - [0]: Reference to the goal
		#  - [1]: The goal's evaluation of the worldstate
		# Plan returns its cost as element [0]

		var plan = plan(goals_current[0][0].get_goalstate(), goals_current[0][1])
		if (plan != null):
			var plancost = plan[0]
			plan.pop_front()

			# Plan was found, apply to actions_current
			while (plan.size() > 0):
				actions_current.append(plan[0])
				plan.pop_front()

			emit_signal("plan_found", plancost)
			return
		else:
			# No plan was found, try next goal
			emit_signal("plan_failed")
			goals_current.pop_front()
	return

func generate_goalqueue():
	if (debug_show_call_generate_goalqueue): entity.get_node("Thoughts").think("I have CALLED generate_goalqueue()")
	# Populate goals_current with goals that are not satisfied in the current worldstate, sorted by priority
	# There are several types of goals:
	#  - CRITICAL: These goals are tantamount to the entity's survival or somehow take precedence over all others
	#  - NORMAL: Nothing out of the ordinary here. These goals are general desires of the entity without special attention
	#  - REPEATABLE: No idea yet. I wanted this to do something, but I forgot why it shouldn't be NORMAL
	#  - DIMINISHING: These goals lose priority after each time they are completed
	#  - IDLE: These goals are the least important and form the back of the queue. Always.
	#  - ONESHOT: These goals will only be completed once, then remove themselves from the system. Their priority is NORMAL equivalent
	# Goals will check the worldstate and report back whether or not they are fulfilled. This way we don't add goals already completed

	var queue = DS.PriorityQueue.new([], false) # Priority queue that sorts the highest priority to the root
	var queue_idle = DS.PriorityQueue.new([], false) # See above
	var queue_critical = DS.PriorityQueue.new([], false) # See above
	var prio_lowest = 0 # Track lowest priority so IDLE goals can be placed below it
	var prio_highest = 0 # Track highest priority so CRITICAL goals can be placed above it
	var eval # Goals return their evaluation as a dictionary of their symbols in worldstate, if not null because they are all satisfied

	goals_current = [] # Reset goalqueue

	if (goals_available.size() > 0):
		# We have goals in the pool, let's evaluate
		for goal in goals_available:
			# Goals with the same priority enter the queue on a FIFO basis
			# This means the first goal entered with priority 5 will be executed before other goals of priority 5

			# Sort by type
			if (goal.type == goal.TYPE_IDLE):
				# Goal is super unimportant
				eval = goal.evaluate()
				if (eval != null):
					# Goal not fulfilled
					queue_idle.insert(goal.priority, [goal, eval])
				continue
			if (goal.type == goal.TYPE_CRITICAL):
				# Goal is super important
				eval = goal.evaluate()
				if (eval != null):
					# Goal not fulfilled
					queue_critical.insert(goal.priority, [goal, eval])
				continue

			# Goal is neither super important nor unimportant
			eval = goal.evaluate()
			if (eval != null):
				# Goal not fulfilled
				queue.insert(goal.priority, [goal, eval])

		# Populate goals_current, with TYPE_CRITICAL goals being first and TYPE_IDLE goals being last
		while (queue_critical.get_size() > 0):
			goals_current.append(queue_critical.remove_root())
		while (queue.get_size() > 0):
			goals_current.append(queue.remove_root())
		while (queue_idle.get_size() > 0):
			goals_current.append(queue_idle.remove_root())
		if (debug_show_call_generate_goalqueue):
			var goal_string = ""
			var i = 0
			while (i < goals_current.size()):
				goal_string += goals_current[i][0].name + ", eval: " + str(goals_current[i][1]) + "; "
				i += 1
			entity.get_node("Thoughts").think("generate_goalqueue() RETURNING " + goal_string)
		return
	else:
		# No goals to evaluate, which really makes no sense for a GOAP_Agent
		entity.get_node("Thoughts").think("I have NO GOALS AVAILABLE!")
		return

func plan(state_goal, state_world):
	if (debug_show_call_plan): entity.get_node("Thoughts").think("I have CALLED plan(GOALSTATE: "\
		+ str(state_goal) + "; WORLDSTATE: " + str(state_world) + ")")

	# Both state_world and state_goal are a single dictionary with strings for keys, representing {symbols}, and a boolean value
	# Checking beforehand guarantees us that the two states differ in at least one symbol, so it makes sense to plan
	# Returns null if a plan could not be found
	# Otherwise returns a sorted list of actions that can be performed to achieve the goalstate
	var actions_usable = [] # Unsorted array of actions valid for this plan

	# Limit the number of available actions to the actions that can actually run (according to their check_proceduralPrecondition)
	for action in actions_available:
		# Start with default values
		action.reset_common()
		if (action.evaluate()):
			actions_usable.append(action)

	# Start building the graph

	# This list is for actions that are in the currently inspected branch of the graph already and that may not be used repeatedly in a plan
	var closed = []
	# plan returns [0]its total cost and [1..n]the list of actions to perform in order
	# plan returns null if no actions could be found
	var plan = build_graph(null, state_world, state_goal, actions_usable, closed)
	if (plan != null):
		if (plan.size() < 2):
			# Plan only has cost and no actions attached
			return null
	return plan

func build_graph(action_inspected, worldstate, goalstate, action_pool, list_closed):
	if (debug_show_call_build_graph):
		var action_name = ""
		if (action_inspected != null):
			action_name = action_inspected.name
		var pool_string = ""
		var i = 0
		while (i < action_pool.size()):
			pool_string += action_pool[i].name + ", "
			i += 1
		pool_string += "(end)"
		var closed_string = ""
		i = 0
		while (i < list_closed.size()):
			closed_string += list_closed[i] + ", "
			i += 1
		closed_string += "(end)"
		entity.get_node("Thoughts").think("I have CALLED build_graph(ACTION_INSPECTED: "\
		+ action_name + "; WORLDSTATE: " + str(worldstate) + "; GOALSTATE: " + str(goalstate)\
		+ "; ACTION_POOL: " + pool_string + "; LIST_CLOSED: " + closed_string + ")")
	# Nesting itself, this is the A* part
	# Takes following arguments:
	# node - The currently inspected action_node
	# worldstate - the current state in the plan. Beginning the search, this is equal to the desired goal's evaluation. This function applies the effects and preconditions to this state to evaluate the next step
	# goalstate - The state we want to achieve by planning
	# action_pool - The pool [array] of valid actions for traversing from this node to any other. In this context always the actions_usable array
	# list_closed - A set of actions that have already been investigated, found to be valid (usable in plan) and that may not be used in the same plan twice. Therefore these actions are not valid for inspection further down the graph
	# Each node is a state, while actions represent edges leading to states
	# A node saves its open and closed list

	# Look at node's state. If its state corresponds to the overall goalstate, the plan is complete
	if (compare_states(goalstate, worldstate)):
		# worldstate has all symbols that goalstate has and all common symbols have the same value -> we found a valid path
		# Since we always check the child with the best value first (lowest cost), we have found not only a valid path, but the best valid path
		# To get the path, we repeatedly move from this node to its parent and add them to the plan, until we reach the start node, which has no parent
		var path = [0] # The previous action fulfilled the goalstate, so we initialise the path with [0]its cost counter
		if (action_inspected != null):
			# Check for movement
			if (action_inspected.movements.size() > 0):
				# Action needs entity to move somewhere first
				# Look at all available movement actions
				var cheapest = null
				var cheapest_cost = -1
				for moveaction in actions_movement:
					for entry in action_inspected.movements.keys():
						# A movement action can be taken if it fulfills ONE of the movement entries
						if (moveaction.movements.has(entry)):
							# Movement action allows that kind of movement, consider it
							var c = moveaction.get_cost()
							if (cheapest == null || c < cheapest_cost):
								cheapest = moveaction
								cheapest_cost = c
							break
				if (cheapest == null):
					# No movement action found, can't commit action to plan
					return null
				else:
					path[0] += cheapest_cost
					path.append(cheapest)
			path.append(action_inspected)
		return path
	else:
		# The node currently inspected is in a state different from the plan goalstate
		# Therefore we inspect actions that bring us closer to the plan goalstate
		# The goalstate has symbols that must be fulfilled by actions with these symbols as effects
		var actions_selectable = DS.PriorityQueue.new([], true) # Empty priority queue that sorts lowest priority (cost) value towards root
		# Loop through symbols in current worldstate
		for symbol in goalstate:
			# Get a list of all actions with this symbol as effect
			var valuekey = symbol + "|" + str(goalstate[symbol])
			var effect_action_names = {}
			if (GOAP_CACHE.cache_actions_from_effect_value.has(valuekey)):
				effect_action_names = GOAP_CACHE.cache_actions_from_effect_value[valuekey] # Returns a cached list of action names that have an effect that sets this symbol to the desired state (as held in current_worldstate)
			# Filter out actions that
			#  - do not have the effect we are looking for
			#  - are not of type repeatable and already on the closed list
			# Also, we want movement and repeatable actions to be available for planning, as long as the same action isn't considered
			#	in two consecutive nodes. We don't want to consider "move_to" after just considering it, but afterwards it's okay
			# This results in actions added that
			#	have the desired effect
			#	AND
			#	are not on the list of already used actions
			#		OR
			#		are of TYPE_REPEATABLE OR TYPE_MOVEMENT
			#			AND
			#			are not the last action inspected
			for action in action_pool:
				var inspected_name = ""
				if (action_inspected != null): inspected_name = action_inspected.name
				if (effect_action_names.has(action.name) && (!list_closed.has(action.name)\
					|| (action.type == action.TYPE_REPEATABLE || action.type == action.TYPE_MOVEMENT) && (action.name != inspected_name)) ):
					# Add action to the list of actions we can inspect
					# The position in the list is determined by the action's cost. The less it costs, the more interested we are in inspecting it
					actions_selectable.insert(action.get_cost(), action)
		# Look at selectable actions and add them as a child to the graph, from where we start a new search with a new worldstate
		while (actions_selectable.get_size() > 0):
			var action = actions_selectable.get_root_value()
			# Add action to closed list so we don't inspect it again
			var new_list_closed = []
			var i = 0
			while (i < list_closed.size()):
				# Copy old list. Same reason as stated in duplicate_state()
				new_list_closed.append(list_closed[i])
				i += 1
			new_list_closed.append(action.name)
			# Modify world and goalstate
			# We filtered out all actions that don't help us move toward our goal
			# Now we redefine the goal so nodes below us find a path to solve the overall goal plus the preconditions for this action
			var new_worldstate = apply_effects(action, worldstate)
			var new_goalstate = apply_preconditions(action, goalstate)
			# Recursive call. If a valid plan is found, it will be sent back up the tree. Else, null will be returned to report failure
			var path = build_graph(action, new_worldstate, new_goalstate, action_pool, new_list_closed)
			if (debug_show_call_build_graph):
				var path_string = ""
				if (path != null):
					i = 1
					while (i < path.size()):
						path_string += path[i].name + ", "
						i += 1
					path_string += "(end)"
				else:
					path_string = "NULL"
				entity.get_node("Thoughts").think("NESTED build_graph() FOR ACTION '" + action.name + "' RETURNED: " + str(path_string))

			if (path != null):
				# A valid plan was found. Add our action and send it up the tree
				# Since we added the currently inspected action to the queue with its cost as its priority,
				#   we can use the priority value to add up the total cost of the plan for analysis
				if (action_inspected != null):
					path[0] += actions_selectable.get_root_priority()
					# Check for movement
					if (action_inspected.movements.size() > 0):
						# Action needs entity to move somewhere first
						# Look at all available movement actions
						var cheapest = null
						var cheapest_cost = -1
						for moveaction in actions_movement:
							for entry in action_inspected.movements.keys():
								# A movement action can be taken if it fulfills ONE of the movement entries
								if (moveaction.movements.has(entry)):
									# Movement action allows that kind of movement, consider it
									var c = moveaction.get_cost()
									if (cheapest == null || c < cheapest_cost):
										cheapest = moveaction
										cheapest_cost = c
									break
						if (cheapest == null):
							# No movement action found, can't commit action to plan
							return null
						else:
							path[0] += cheapest_cost
							path.append(cheapest)
					path.append(action_inspected)
				return path
			# Delete action from queue and try the next
			actions_selectable.remove_root()
		# We have not found an action that yields results we want
		return null

func apply_preconditions(action, state):
	var out = duplicate_state(state)
	# Need to copy state, else we will apply preconditions to it, find no valid plan,
	# 	then return to actions further up the tree and have these preconditions as residue in the goalstate,
	# 	which with 90%+ accuracy bombs any further planning
	var preconditions = action.get_preconditions()
	for symbol in preconditions.keys():
		out[symbol] = preconditions[symbol]
	return out

func apply_effects(action, state):
	var out = duplicate_state(state)
	# Need to copy state, else we will apply effects to it, find no valid plan,
	# 	then return to actions further up the tree and have these effects as residue in the goalstate,
	# 	which with 90%+ accuracy bombs any further planning
	var effects = action.get_effects()
	for symbol in effects.keys():
		out[symbol] = effects[symbol]
	return out

func duplicate_state(dict):
	# Create a new dictionary and populate it with the input dictionary's values
	var out = {}
	for key in dict.keys():
		out[key] = dict[key]
	return out

func compare_states(state_a, state_b):
	# Returns true if all symbols in state_a are present in state_b and the values are equal as well
	# Returns false if not all symbols of state_a are present in state_b or there is one or more value mismatch
	# Make sure all symbols can be compared
	if (state_b.has_all(state_a.keys())):
		# All symbols exists, so we can compare them
		for symbol_a in state_a.keys():
			for symbol_b in state_b.keys():
				# Compare values
				if (state_a[symbol_a] != state_b[symbol_b]):
					# Found a mismatch
					return false
		# No mismatch found
		return true
	else:
		# Symbol mismatch. We must assume it has not the state we want
		return false
##################
# EXECUTION LOOP #
##################

# Execution loop consists of
#  - planning: Feed the planner the goalstate and the current worldstate in the hopes of getting a queue of actions to execute back
#  - execution: If there are actions to perform, do that
#  - waiting: There are no actions to perform and no plan has been made. The entity goes into hibernation until woken up

const ACTION_ABORTED = 0 # Action's execution code has encountered an unsolvable state, it is aborting its execution
const ACTION_CONTINUED = 1 # Action's execution code has run successfully, but the action is not done yet
const ACTION_COMPLETED = 2 # Action's execution code has run successfully and the action is done executing

signal action_completed # Emitted when an action returns ACTION_COMPLETED and is subsequently popped off the queue
signal plan_aborted # Emitted when an action failed execution and therefore broke the plan
signal plan_finished # Emitted when a plan was fully and successfully executed

func interval():
	if (debug_show_call_interval): entity.get_node("Thoughts").think("I have CALLED interval()")
	# Called periodically via timer 'updater'
	if (actions_current.size() > 0):
		# Actions left to execute
		execute()

	else:
		# No actions left, let's find a new plan
		# Planner will set actions_current directly
		generate_plan()
		if (actions_current.size() > 0):
			# New plan was found
			updater.set_wait_time(update_interval)
			return
		else:
			# No new plan was found, the agent goes into hibernation for a bit
			# To wake up, simply call 'interval()'
			updater.set_wait_time(update_pause)
	return

func execute():
	if (debug_show_call_execute): entity.get_node("Thoughts").think("I have CALLED execute()")
	# Called whenever an action is to begin/continue its execution code, which is determined by the update interval timer

	# Plan has actions left
	var status = actions_current[0].execute_common()
	if (status == ACTION_CONTINUED):
		# Action is still running
		return
	elif (status == ACTION_ABORTED):
		# Action interrupted, continuation impossible
		emit_signal("plan_aborted", actions_current[0].get_name())
		actions_current = [] # Empty plan to force replanning
		return
	elif (status == ACTION_COMPLETED):
		# Action completed successfully
		emit_signal("action_completed", actions_current[0].get_name())
		actions_current.pop_front()
		if (actions_current.size() < 1):
			# Plan finished, no actions left
			emit_signal("plan_finished")
			return
		return
	else:
		# Unexpected return value
		entity.get_node("Thoughts").think("RECEIVED UNEXPECTED VALUE '" + str(status) + "' FROM ACTION '" + actions_current[0].get_name() + "'")
		return

#####################
# ACTIONS AND GOALS #
#####################
var actions # Node that has all available actions as children
var actions_available = [] # Pool of action nodes that are attached to this agent. Base for planner to find solutions
var goals # Node that has all available goals as children
var goals_available = [] # Pool of goal nodes that are attached to this agent. Base for planner to find solutions for

func add_action(action_name):
	# Check if action already exists for agent
	if (!has_action(action_name)):
		# Not found, so add it
		if (GOAP_CACHE.get_cache_actions().has(action_name)):

			# Found in cache, use cached filepath
			var new_action = load(GOAP_CACHE.get_cache_actions()[action_name]).new()
			actions.add_child(new_action)

			# Check for type
			if (new_action.type == new_action.TYPE_MOVEMENT):
				actions_movement.append(new_action)
			else:
				actions_available.append(new_action)
	return

func add_goal(goal_name):
	# Check if goal already exists for agent
	if (!has_goal(goal_name)):
		# Not found, so add it
		if (GOAP_CACHE.get_cache_goals().has(goal_name)):
			# Found in cache, use cached filepath
			var new_goal = load(GOAP_CACHE.get_cache_goals()[goal_name]).new()
			goals.add_child(new_goal)
			goals_available.append(new_goal)
	return

func has_action(action_name):
	for action in actions_available:
		if (action.name == action_name): return true
	return false

func has_goal(goal_name):
	for goal in goals_available:
		if (goal.name == goal_name): return true
	return false

func remove_action(action_name):
	for action in actions_available:
		if (action.name == action_name):
			# Existing action found, remove from tree
			actions_available.erase(action)
			action.queue_free()
			return

	for action in actions_movement:
		if (action.name == action_name):
			# Existing action found, remove from tree
			actions_movement.erase(action)
			action.queue_free()
			return
	return

func remove_goal(goal_name):
	for goal in goals_available:
		if (goal.name == goal_name):
			# Existing goal found, remove from tree
			goals_available.erase(goal)
			goal.queue_free()
	return
