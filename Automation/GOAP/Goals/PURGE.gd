extends goapGOAL

class_name PURGEgoal

func _ready():
	set_goal_name("PURGE")

func is_valid() -> bool:
	return true if !state.empty() and state["cargo_is_full"] == true else false

func get_desire() -> Dictionary:
	return {
		"cargo_is_empty": true,
		"cargo_is_full": false
	}
