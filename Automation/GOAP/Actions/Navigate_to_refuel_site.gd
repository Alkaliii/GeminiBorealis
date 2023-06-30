extends goapACTION

class_name Navigate_to_refuel_site_Action

func _ready():
	set_action_name("Navigate_to_refuel_site")
	set_cost(1)

func get_requirements() -> Dictionary:
	return {
		"refuel_site_flight_plan": true
	}

func get_effects() -> Dictionary:
	return {
		"at_refuel_site": true
	}

enum states {IDLE,IN_PROGRESS,COMPLETE}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			navigate(relevant)
			cur = states.IN_PROGRESS
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func navigate(relevant):
	if Automation._FleetData["FAKESHIP-1"]["nav"]["status"] == "DOCKED":
		print("Orbiting ",relevant["ship"])
		Automation._FleetData["FAKESHIP-1"]["nav"]["status"] = "IN_ORBIT"
	print("Navigating to refuel site")
	yield(get_tree().create_timer(5),"timeout")
	print("At refuel site")
	cur = states.COMPLETE
