extends Node

class_name goapOFFICER

var _goals
var _action_planner
var _current_goal
var _current_plan
var _current_plan_step = 0

var _relevant_data = {
	"ship": null,
	"shipData": null,
	"cooldown": null
}

var _ship_state : Dictionary
enum has {NOT_STARTED,PAUSED,STARTED}
var officer = has.NOT_STARTED

func _ready():
	var nil = true
	while nil:
		yield(get_tree(),"idle_frame")
		if _goals.empty(): continue
		else: break
	for g in _goals:
		g.state = _ship_state

#if goal, do plan
#else figure something new out
func _process(delta):
	if officer != has.STARTED: return
	var goal = _get_best_goal()
	if _current_goal == null or goal != _current_goal:
		var whiteboard = {}
		
		for s in _ship_state:
			whiteboard[s] = _ship_state[s]
		
		_current_goal = goal
		#_current_plan = Automation.get_action_planner().get_plan(_current_goal,whiteboard)
		#initiate with an action planner
		_current_plan = _action_planner.get_plan(_current_goal,whiteboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)

func _get_best_goal():
	var highest_priority
	
	#initiate with goals
	for goal in _goals:
		if goal.is_valid() and (highest_priority == null or goal.get_priority() > highest_priority.get_priority()):
			highest_priority = goal
	
	return highest_priority

func _follow_plan(plan, delta):
	if plan.size() == 0: return
	
	var is_step_complete = plan[_current_plan_step].execute(_relevant_data, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
		if _current_plan_step - 1 >= 0:
			print(str("_finished: (",plan[_current_plan_step - 1].get_action_name(),") on ",plan[_current_plan_step - 1].symbol," @ ",Time.get_datetime_string_from_system()))
		print(str("NEW TASK: (",plan[_current_plan_step].get_action_name(),") on ",plan[_current_plan_step].symbol," @ ",Time.get_datetime_string_from_system()))
		
	elif is_step_complete:
		var desires = _current_goal.get_desire()
		for d in desires:
			_ship_state[d] = desires[d]
		for g in _goals:
			g.state = _ship_state
