extends goapACTION

class_name Devise_Market_Site_Flight_Plan_Action

func _ready():
	set_action_name("Devise_Market_Site_Flight_Plan")
	set_cost(1)

func get_requirements() -> Dictionary:
	return {
		"enough_fuel_to_purge": true
	}

func get_effects() -> Dictionary:
	return {
		"market_site_flight_plan": true
	}

enum states {IDLE,IN_PROGRESS,COMPLETE}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			
			cur = states.IN_PROGRESS
			var operation = {"Ship":symbol,"Op":"FLIGHT PLANNING"}
			Automation.emit_signal("OperationChanged",operation)
			
			outputRID(str("SUBTASK:(compute) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
			
			compute()
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func compute():
	print("Pathing...")
	yield(get_tree(),"idle_frame")
	print("Path Found! Flight Plan Created")
	cur = states.COMPLETE
