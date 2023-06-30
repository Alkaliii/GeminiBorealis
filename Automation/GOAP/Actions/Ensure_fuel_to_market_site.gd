extends goapACTION

class_name Ensure_fuel_to_market_site_Action

func _ready():
	set_action_name("Ensure_fuel_to_market_site")
	set_cost(1)

func get_requirements() -> Dictionary:
	return {}
#		"at_refuel_site": true
#	}

func get_effects() -> Dictionary:
	return {
		"enough_fuel_to_purge": true
	}

enum states {IDLE,IN_PROGRESS,COMPLETE}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			cur = states.IN_PROGRESS
			var operation = {"Ship":symbol,"Op":"PREP"}
			Automation.emit_signal("OperationChanged",operation)
			
			outputRID(str("SUBTASK:(ensure) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
			
			ensure()
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func ensure():
	print("not enough fuel, refueling")
	yield(get_tree(),"idle_frame")
	print("finished refueling")
	cur = states.COMPLETE
