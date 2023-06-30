extends goapACTION

class_name Devise_Extract_Site_Flight_Plan_Action

func _ready():
	set_action_name("Devise_Extract_Site_Flight_Plan")
	set_cost(1)

func get_requirements() -> Dictionary:
	if Automation._FleetData[symbol]["fuel"]["current"] > 3: 
		return {}
	return {
		"enough_fuel_to_extract": true
	}

func get_effects() -> Dictionary:
	return {
		"extract_site_flight_plan": true
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
			
			compute(Automation._FleetData[symbol])
		states.IN_PROGRESS: pass
		states.COMPLETE:
			cur = states.IDLE
			return true
	return false

func compute(relevant):
	var flightPlan
	
	#determine ship location
	var location = relevant["nav"]["waypointSymbol"]
	#determine extract site location
	var extract_site
	var extractTrait = ["MINERAL_DEPOSITS","COMMON_METAL_DEPOSITS","PRECIOUS_METAL_DEPOSITS","RARE_METAL_DEPOSITS","METHANE_POOLS","ICE_CRYSTALS","EXPLOSIVE_GASES"]
	var systemDir = Automation._SystemsData[relevant["nav"]["systemSymbol"]]["waypoints"]
	for waypoint in systemDir: for t in systemDir[waypoint]["traits"]: if t["symbol"] in extractTrait:
		extract_site = waypoint
		break
	#if at extract site already, pass action
	if location == extract_site:
		flightPlan = ["at site"]
		if !officerOBj.sharedData.has(symbol):
			officerOBj.sharedData[symbol] = {"extract_site_fp":flightPlan}
		else: officerOBj.sharedData[symbol]["extract_site_fp"] = flightPlan
		cur = states.COMPLETE
		return
	#if not, calculate distance to extract site
	var dist = Vector2(systemDir[location]["x"],systemDir[location]["y"]).distance_to(Vector2(systemDir[extract_site]["x"],systemDir[extract_site]["y"]))
	
	var max_reach
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
	match refuel: #set reach
		true: max_reach = relevant["fuel"]["capacity"]
		false: max_reach = relevant["fuel"]["current"] - 3
	if dist < max_reach:
		match refuel: #set 1-2 step flightPlan
			true: flightPlan = ["refuel",extract_site]
			false: flightPlan = [extract_site]
		if !officerOBj.sharedData.has(symbol):
			officerOBj.sharedData[symbol] = {"extract_site_fp":flightPlan}
		else: officerOBj.sharedData[symbol]["extract_site_fp"] = flightPlan
		cur = states.COMPLETE
		return
	else: #ASTAR
		var AS = AStar2D.new()
		var idx = 0
		var nodees = []
		for waypoint in systemDir: #Add and weight
			var ASdist = Vector2(systemDir[location]["x"],systemDir[location]["y"]).distance_to(Vector2(waypoint["x"],waypoint["y"]))
			ASdist = clamp(ASdist * (1/float(max_reach)),0,1)
			AS.add_point(idx,Vector2(waypoint["x"],waypoint["y"]),ASdist)
			nodees[waypoint] = [Vector2(waypoint["x"],waypoint["y"]),idx]
			idx += 1
		
		for A in systemDir: #connect limited by reach
			var Apos = Vector2(A["x"],A["y"])
			var Aidx = nodees[A][1]
			for B in systemDir:
				var Bidx = nodees[B][1]
				var Bpos = Vector2(B["x"],B["y"])
				if Apos.distance_to(Bpos) < max_reach:
					AS.connect_points(Aidx,Bidx,false)
		
		var path = AS.get_id_path(nodees[location][1],nodees[extract_site][1])
		if !path.empty():
			flightPlan = []
			for n in path:
				flightPlan.push_back(nodees.keys()[path.find(n)])
				#pretty much if navigate finds that it's at a node it can't refuel at
				#during a multistep trip, it's gonna drift...
			if !officerOBj.sharedData.has(symbol):
				officerOBj.sharedData[symbol] = {"extract_site_fp":flightPlan}
			else: officerOBj.sharedData[symbol]["extract_site_fp"] = flightPlan
			cur = states.COMPLETE
			return
		else:
			flightPlan = [extract_site]
			if !officerOBj.sharedData.has(symbol):
				officerOBj.sharedData[symbol] = {"extract_site_fp":flightPlan}
			else: officerOBj.sharedData[symbol]["extract_site_fp"] = flightPlan
			cur = states.COMPLETE
			return
		
	
#	print("Pathing...")
#	yield(get_tree(),"idle_frame")
#	print("Path Found! Flight Plan Created")
#	cur = states.COMPLETE
