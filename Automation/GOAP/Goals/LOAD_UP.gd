extends goapGOAL

class_name LOAD_UPgoal

func _ready():
	set_goal_name("LOAD_UP")

func is_valid() -> bool:
	return true if !state.empty() and state["cargo_is_empty"] == true else false

func get_desire() -> Dictionary:
	return {
		"cargo_is_full": true
	}
