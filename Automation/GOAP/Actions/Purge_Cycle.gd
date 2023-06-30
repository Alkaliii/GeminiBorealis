extends goapACTION

class_name Purge_Cycle_Action

func _ready():
	set_action_name("Purge_Cycle")
	set_cost(1)

func get_requirements() -> Dictionary:
	return {
		"at_market_site": true
	}

func get_effects() -> Dictionary:
	return {
		"cargo_is_empty": true,
		"cargo_is_full": false
	}

enum states {IDLE,YIELD,DOCKING,SELLING}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			if relevant["shipData"]["nav"]["status"] == "IN_ORBIT":
				cur = states.DOCKING
			elif relevant["shipData"]["nav"]["status"] == "DOCKED":
				cur = states.SELLING
		states.DOCKING:
			dock(relevant)
			cur = states.YIELD
		states.SELLING:
			sell(relevant)
			cur = states.YIELD
	if Automation._FleetData["FAKESHIP-1"]["cargo"]["units"] == 0: #leftover
		cur = states.IDLE
		return true
	return false

func sell(relevant):
	print(relevant["ship"], " is Purging")
	yield(get_tree(),"idle_frame")
	print(relevant["ship"], " has finished purging")
	Automation._FleetData["FAKESHIP-1"]["cargo"]["units"] = 0

func dock(relevant):
	print("Docking ",relevant["ship"])
	yield(get_tree(),"idle_frame")
	print(relevant["ship"], " has docked @ location")
	Automation._FleetData["FAKESHIP-1"]["nav"]["status"] = "DOCKED"
	cur = states.SELLING
