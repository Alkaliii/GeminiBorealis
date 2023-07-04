extends goapACTION

class_name Navigate_to_extract_site_Action

func _ready():
	set_action_name("Navigate_to_extract_site")
	set_cost(1)

func is_valid() -> bool:
	var location = Automation._FleetData[symbol]["nav"]["waypointSymbol"]
	#determine extract site location
	var extract_site
	var extractTrait = ["MINERAL_DEPOSITS","COMMON_METAL_DEPOSITS","PRECIOUS_METAL_DEPOSITS","RARE_METAL_DEPOSITS","METHANE_POOLS","ICE_CRYSTALS","EXPLOSIVE_GASES"]
	var systemDir = Automation._SystemsData[Automation._FleetData[symbol]["nav"]["systemSymbol"]]["waypoints"]
	for waypoint in systemDir: for t in systemDir[waypoint]["traits"]: if t["symbol"] in extractTrait:
		extract_site = waypoint
		break
	#if at extract site already, pass action
	if location == extract_site:
		return false
	return true

func get_requirements() -> Dictionary:
	return {
		"extract_site_flight_plan": true
	}

func get_effects() -> Dictionary:
	return {
		"at_extract_site": true
	}

enum states {IDLE,IN_PROGRESS,COMPLETE}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			cur = states.IN_PROGRESS
			var operation = {"Ship":symbol,"Op":"TRANSIT"}
			Automation.emit_signal("OperationChanged",operation)
			
			navigate(Automation._FleetData[symbol])
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func navigate(relevant):
	var flightPlan = officerOBj.sharedData[symbol]["extract_site_fp"]
	if flightPlan.size() == 1:
		singleStep(flightPlan)
	else:
		multiStep(flightPlan)
	
#	if Automation._FleetData["FAKESHIP-1"]["nav"]["status"] == "DOCKED":
#		print("Orbiting ",relevant["ship"])
#		Automation._FleetData["FAKESHIP-1"]["nav"]["status"] = "IN_ORBIT"
#	print("Navigating to extract site")
#	yield(get_tree().create_timer(5),"timeout")
#	print("At extract site")
#	cur = states.COMPLETE

func singleStep(fp):
	#print("singleStepNavigation")
	outputRID(str("SUBTASK:(single step navigation) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
	var waypointSymbol = fp[0]
	if waypointSymbol == "at site":
		cur = states.COMPLETE
		return
	
	#self orbit
	if Automation._FleetData[symbol]["nav"]["status"] == "DOCKED":
		var operation = {"Ship":symbol,"Op":"ORBITING"}
		Automation.emit_signal("OperationChanged",operation)
		
		outputRID(str("SUBTASK:(orbit ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
		
		orbit()
		yield(self,"orbit_complete")
		operation = {"Ship":symbol,"Op":"TRANSIT"}
		Automation.emit_signal("OperationChanged",operation)
		outputRID(str("/",self.get_action_name(),"/ RESUMING:(single step navigation) on ", symbol," @ ",Time.get_datetime_string_from_system()))
	
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_navigate_ship"
	req.API_ext = str("my/ships/",symbol,"/navigate")
	req.data = {"waypointSymbol":waypointSymbol}
	req.RID = str(officer,"-NAVIGATE_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)
	
	yield(self,"navigate_complete")
	
	cur = states.COMPLETE

func multiStep(fp):
	#print("multiStepNavigation")
	outputRID(str("SUBTASK:(multi step navigation) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
	for x in fp:
		match x:
			"refuel":
				#self dock
				if Automation._FleetData[symbol]["nav"]["status"] == "IN_ORBIT":
					var operation = {"Ship":symbol,"Op":"DOCKING"}
					Automation.emit_signal("OperationChanged",operation)
						
					outputRID(str("SUBTASK:(dock ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
					
					dock_ship()
					yield(self,"orbit_complete")
				
				var operation = {"Ship":symbol,"Op":"REFUELING"}
				Automation.emit_signal("OperationChanged",operation)
				
				outputRID(str("SUBTASK:(refuel ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
				
				refuel_ship()
				yield(self,"refuel_complete")
			"at site":
				cur = states.COMPLETE
				return
			_: #symbol hopefully
				var site = Automation._SystemsData[Automation._FleetData[symbol]["nav"]["systemSymbol"]]["waypoints"][x]
				var sitePOS = Vector2(site["x"],site["y"])
				var location = Automation._SystemsData[Automation._FleetData[symbol]["nav"]["systemSymbol"]]["waypoints"][Automation._FleetData[symbol]["nav"]["waypointSymbol"]]
				var locationPOS = Vector2(location["x"],location["y"])
				if sitePOS.distance_to(locationPOS) < Automation._FleetData[symbol]["fuel"]["current"] - 3:
					#self orbit
					if Automation._FleetData[symbol]["nav"]["status"] == "DOCKED":
						var operation = {"Ship":symbol,"Op":"ORBITING"}
						Automation.emit_signal("OperationChanged",operation)
						
						outputRID(str("SUBTASK:(orbit ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
						
						orbit()
						yield(self,"orbit_complete")
						operation = {"Ship":symbol,"Op":"TRANSIT"}
						Automation.emit_signal("OperationChanged",operation)
						outputRID(str("/",self.get_action_name(),"/ RESUMING:(multi step navigation) on ", symbol," @ ",Time.get_datetime_string_from_system()))
					#navigate
					var waypointSymbol = x
					var req = _POST_REQUEST_OBj.duplicate()
					req.Callback = "_on_navigate_ship"
					req.API_ext = str("my/ships/",symbol,"/navigate")
					req.data = {"waypointSymbol":waypointSymbol}
					req.RID = str(officer,"-NAVIGATE_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
					
					Automation.callQueue.push_back(req)
					outputRID(req.RID)
					
					yield(self,"navigate_complete")
	cur = states.COMPLETE

func refuel_ship():
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_refuel_ship"
	req.API_ext = str("my/ships/",symbol,"/refuel")
	req.RID = str(officer,"-REFUEL_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal refuel_complete
func _on_refuel_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		API.emit_signal("refuel_ship_complete",PARSE)
		emit_signal("refuel_complete")

func dock_ship():
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_dock_ship"
	req.API_ext = str("my/ships/",symbol,"/dock")
	req.RID = str(officer,"-DOCK_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal dock_complete
func _on_dock_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		PARSE["meta"] = symbol
		Automation.emit_signal("SHIPSTATUSUPDATE",PARSE)
		API.emit_signal("dock_ship_complete",PARSE)
		emit_signal("dock_complete")

signal navigate_complete
func _on_navigate_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		PARSE["meta"] = symbol
		Automation.emit_signal("SHIPSTATUSUPDATE",PARSE)
		API.emit_signal("navigate_ship_complete",PARSE)
		
		Agent.emit_signal("NavigationFinished",PARSE)
		Agent.emit_signal("mapGenLine",
		Vector2(PARSE["data"]["nav"]["route"]["departure"]["x"],PARSE["data"]["nav"]["route"]["departure"]["y"]),
		Vector2(PARSE["data"]["nav"]["route"]["destination"]["x"],PARSE["data"]["nav"]["route"]["destination"]["y"]), Color(1,1,0,0.5), true, PARSE["data"]["nav"]["route"]["arrival"])
		Agent.emit_signal("FocusMapNav",
			{
			"data":
				{
				"x": (PARSE["data"]["nav"]["route"]["departure"]["x"]+PARSE["data"]["nav"]["route"]["destination"]["x"])/2,
				"y": (PARSE["data"]["nav"]["route"]["departure"]["y"]+PARSE["data"]["nav"]["route"]["destination"]["y"])/2
				}
			})
		
		var expire = Time.get_unix_time_from_datetime_string(PARSE["data"]["nav"]["route"]["arrival"])
		while expire > Time.get_unix_time_from_system():
			yield(get_tree(),"idle_frame")
			if expire < Time.get_unix_time_from_system():
				break
		
		emit_signal("navigate_complete")

func orbit():
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_orbit_ship"
	req.API_ext = str("my/ships/",symbol,"/orbit")
	req.RID = str(officer,"-ORBIT_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal orbit_complete
func _on_orbit_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		PARSE["meta"] = symbol
		Automation.emit_signal("SHIPSTATUSUPDATE",PARSE)
		API.emit_signal("orbit_ship_complete",PARSE)
		emit_signal("orbit_complete")
