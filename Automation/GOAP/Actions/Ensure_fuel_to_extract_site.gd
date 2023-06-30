extends goapACTION

class_name Ensure_fuel_to_extract_site_Action

func _ready():
	set_action_name("Ensure_fuel_to_extract_site")
	set_cost(1)

func is_valid() -> bool:
	if Automation._FleetData[symbol]["fuel"]["current"] > 3: 
		return false
	return true

func get_requirements() -> Dictionary:
	return {}
#		"at_refuel_site": true
#	}

func get_effects() -> Dictionary:
	return {
		"enough_fuel_to_extract": true
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
			#cur = states.COMPLETE
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func ensure():
	yield(get_tree(),"idle_frame")
	cur = states.COMPLETE
	return
	if Automation._FleetData[symbol]["fuel"]["current"] < 3:
		var location = Automation._FleetData[symbol]["nav"]["waypointSymbol"]
		var refuel = false
		for m in Automation._MarketData: if m["symbol"] == location: #determine if location is a refuel site
			for tg in m["exchange"]:
				if tg["symbol"] == "FUEL": 
					refuel = true
					break
			if !refuel: for tg in m["exports"]:
				if tg["symbol"] == "FUEL": 
					refuel = true
					break
			if !refuel: for tg in m["imports"]:
				if tg["symbol"] == "FUEL": 
					refuel = true
					break
			break
	
#	print("not enough fuel, refueling")
#	yield(get_tree(),"idle_frame")
#	print("finished refueling")
	cur = states.COMPLETE
