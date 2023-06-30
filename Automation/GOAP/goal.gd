extends Node

class_name goapGOAL

var _goal_name : String
var state : Dictionary
var prio = 1

func set_goal_name(goal_name):
	_goal_name = goal_name

func get_goal_name():
	return _goal_name

#Should this goal be performed?
func is_valid() -> bool:
	return true

#How important is completing this goal
#Can vary dynamically
func get_priority() -> int:
	return prio
	#Bigger = More Important

func set_priority(new):
	prio = new


#{"desire": true}
#can differ from raw data,
#"cargo_is_full": true
#ship cargo[capacity] = ship cargo[units]
func get_desire() -> Dictionary:
	return {}
