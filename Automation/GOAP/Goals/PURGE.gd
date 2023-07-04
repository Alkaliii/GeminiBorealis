extends goapGOAL

class_name PURGEgoal

func _ready():
	set_goal_name("PURGE")

func is_valid() -> bool:
	if !state.empty() and state["cargo_is_full"] == true:
		return true
	elif !state.empty() and state["cargo_is_empty"] == false:
		return true
	elif !state.empty() and state["cargo_is_empty"] == true:
		return false
	return false
	#return true if !state.empty() and state["cargo_is_full"] == true else false

func get_desire() -> Dictionary:
	return {
		"cargo_is_empty": true
	}
