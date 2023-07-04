extends goapACTION

class_name Devise_Market_Site_Flight_Plan_Action

func _ready():
	set_action_name("Devise_Market_Site_Flight_Plan")
	set_cost(1)

func get_requirements() -> Dictionary:
	if Automation._FleetData[symbol]["fuel"]["current"] > 3: 
		return {}
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
	
	#setup cargo
	var cargo2sell = []
	var expectedIncome = 0
	for c in Automation._FleetData[symbol]["cargo"]["inventory"]:
		cargo2sell.push_back(c["symbol"])
		if Agent.sellgood.has(c["symbol"]):
			expectedIncome += Agent.sellgood[c["symbol"]]["LatestSellPrice"] * c["units"]
	if !officerOBj.sharedData.has(symbol):
		officerOBj.sharedData[symbol] = {}
	officerOBj.sharedData[symbol]["expectedIncome"] = expectedIncome
	
	#determine market site locations
	var market_site
	var sites = []
	var marketTrait = ["MARKETPLACE"]
	var systemDir = Automation._SystemsData[relevant["nav"]["systemSymbol"]]["waypoints"]
	var marketDir = Automation._MarketData
	for waypoint in systemDir: for t in systemDir[waypoint]["traits"]: if t["symbol"] in marketTrait:
		sites.push_back(waypoint)
	for market in marketDir: if !sites.has(market):
		if !marketDir[market]["imports"].empty():
			for i in marketDir[market]["imports"]:
				if i["symbol"] in cargo2sell:
					sites.push_back(market)
					break
		
		if !marketDir[market]["exchange"].empty():
			for i in marketDir[market]["exchange"]:
				if i["symbol"] in cargo2sell:
					sites.push_back(market)
					break
			break
	
	#determine best site
	var marketScores = []
	for m in sites:
		var score = 0
		var dir = marketDir
		if systemDir.has(m) and !marketDir.has(m):
			#If in system but not scouted, prioritize.
			score = 999
			marketScores.push_back({"market":m,"score":score})
			continue
		
		var useDetailedMarketData = false
		
		if dir[m].has("tradeGoods"):
			useDetailedMarketData = true
		
		#increase score by marketSellPrice or latestsellprice if market imports a good that is being sold
		for i in dir[m]["imports"]:
			if i["symbol"] in cargo2sell:
				if useDetailedMarketData:
					for tg in dir[m]["tradeGoods"]:
						if tg["symbol"] == i["symbol"]:
							score += tg["sellPrice"]
							continue
				elif i["symbol"] in Agent.sellgood:
					score += Agent.sellgood[i["symbol"]]["LatestSellPrice"]
				else: score += 20
		
		#increase score by marketSellPrice or half of latestsellprice if market exchanges a good that is being sold
		for i in dir[m]["exchange"]:
			if i["symbol"] in cargo2sell:
				if useDetailedMarketData:
					for tg in dir[m]["tradeGoods"]:
						if tg["symbol"] == i["symbol"]:
							score += tg["sellPrice"]
							continue
				elif i["symbol"] in Agent.sellgood:
					score += round(Agent.sellgood[i["symbol"]]["LatestSellPrice"] / 2.0)
				else: score += 10
		
		marketScores.push_back({"market":m,"score":score})
	
	var best_market = {"market":null,"score":-1}
	for m in marketScores:
		if m["score"] > best_market["score"]:
			best_market = m
	market_site = best_market["market"]
	print(marketScores)
	
	#if at market site already, pass action
	if location == market_site:
		flightPlan = ["at site"]
		if !officerOBj.sharedData.has(symbol):
			officerOBj.sharedData[symbol] = {"market_site_fp":flightPlan}
		else: officerOBj.sharedData[symbol]["market_site_fp"] = flightPlan
		cur = states.COMPLETE
		return
	#if not, calculate distance to market site
	var dist = Vector2(systemDir[location]["x"],systemDir[location]["y"]).distance_to(Vector2(systemDir[market_site]["x"],systemDir[market_site]["y"]))
	
	var max_reach
	var refuel = false
	for m in Automation._SystemsData: if m == location: #determine if location is a refuel site
		for tg in Automation._MarketData[m]["exchange"]:
			if tg["symbol"] == "FUEL": 
				refuel = true
				break
		if !refuel: for tg in Automation._MarketData[m]["exports"]:
			if tg["symbol"] == "FUEL": 
				refuel = true
				break
		if !refuel: for tg in Automation._MarketData[m]["imports"]:
			if tg["symbol"] == "FUEL": 
				refuel = true
				break
		break
	match refuel: #set reach
		true: max_reach = relevant["fuel"]["capacity"]
		false: max_reach = relevant["fuel"]["current"] - 3
	if dist < max_reach:
		match refuel: #set 1-2 step flightPlan
			true: flightPlan = ["refuel",market_site]
			false: flightPlan = [market_site]
		if !officerOBj.sharedData.has(symbol):
			officerOBj.sharedData[symbol] = {"market_site_fp":flightPlan}
		else: officerOBj.sharedData[symbol]["market_site_fp"] = flightPlan
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
		
		var path = AS.get_id_path(nodees[location][1],nodees[market_site][1])
		if !path.empty():
			flightPlan = []
			for n in path:
				flightPlan.push_back(nodees.keys()[path.find(n)])
				#pretty much if navigate finds that it's at a node it can't refuel at
				#during a multistep trip, it's gonna drift...
			if !officerOBj.sharedData.has(symbol):
				officerOBj.sharedData[symbol] = {"market_site_fp":flightPlan}
			else: officerOBj.sharedData[symbol]["market_site_fp"] = flightPlan
			cur = states.COMPLETE
			return
		else:
			flightPlan = [market_site]
			if !officerOBj.sharedData.has(symbol):
				officerOBj.sharedData[symbol] = {"market_site_fp":flightPlan}
			else: officerOBj.sharedData[symbol]["market_site_fp"] = flightPlan
			cur = states.COMPLETE
			return
#	print("Pathing...")
#	yield(get_tree(),"idle_frame")
#	print("Path Found! Flight Plan Created")
#	cur = states.COMPLETE
