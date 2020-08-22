extends "res://goap/goap_agent.gd"

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
