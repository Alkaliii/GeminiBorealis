extends Node

class_name goapACTION_PLANNER

var _actions: Array
var _symbol: String
var _officer: String
var _officerOBj
var _debug: bool

#Set actions to use while planning
func set_actions(actions: Array):
	_actions = actions
	for a in self.get_children():
		a.symbol = _symbol
		a.officer = _officer
		a.officerOBj = _officerOBj
		a.printRID = _debug


func get_plan(goal: goapGOAL,whiteboard = {}) -> Array:
	print("Goal: %s" % goal.get_goal_name())
	var desire = goal.get_desire().duplicate()
	
	if desire.empty():
		return []
	
	return compute_plan(goal,desire,whiteboard)

func compute_plan(goal: goapGOAL,desire: Dictionary,whiteboard):
	var root = {
		"action": goal,
		"state": desire,
		"children": []
	}
	
	if _build_plans(root,whiteboard.duplicate()):
		var plans = _transform_tree_2_array(root,whiteboard)
		return cheapest_plan(plans)
	return []

func cheapest_plan(plans):
	var best_plan
	for p in plans:
		#_print_plan(p)
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	_print_plan(best_plan)
	return best_plan.actions

func _build_plans(step, whiteboard):
	var has_followup = false
	var state = step.state.duplicate()
	
	for s in step.state:
		if state[s] == whiteboard.get(s):
			state.erase(s)
	
	#Solution found
	if state.empty():
		return true
	
	for action in _actions:
		if !action.is_valid(): continue
		
		var should_use = false
		var effects = action.get_effects()
		var desire = state.duplicate()
		
		for s in desire:
			if desire[s] == effects.get(s):
				desire.erase(s)
				should_use = true
		
		if should_use:
			var requirements = action.get_requirements()
			for r in requirements:
				desire[r] = requirements[r]
			
			var s = {
				"action": action,
				"state": desire,
				"children": []
			}
			
			if desire.empty() or _build_plans(s,whiteboard.duplicate()):
				step.children.push_back(s)
				has_followup = true
	return has_followup

func _transform_tree_2_array(p, whiteboard):
	var plans = []
	
	if p.children.size() == 0:
		plans.push_back({
			"actions": [p.action],
			"cost": p.action.get_cost(whiteboard)
			})
		return plans
	
	for c in p.children:
		for child_plan in _transform_tree_2_array(c,whiteboard):
			if p.action.has_method("get_cost"):
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.get_cost(whiteboard)
			plans.push_back(child_plan)
	return plans

func _print_plan(plan):
	var actions = []
	for a in plan.actions:
		actions.push_back(a.get_action_name())
	print({
		"cost": plan.cost,
		"actions": actions
	})
