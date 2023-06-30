extends goapGOAL

class_name DONT_EMPTYgoal

func _ready():
	set_goal_name("DONT_EMPTY")

func get_desire() -> Dictionary:
	return {
		"enough_fuel": true
	}
