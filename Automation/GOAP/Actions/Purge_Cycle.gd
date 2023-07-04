extends goapACTION

class_name Purge_Cycle_Action

var effects = {
	"cargo_is_empty": true,
	"cargo_is_full": false
}

func _ready():
	set_action_name("Purge_Cycle")
	set_cost(1)

func get_requirements() -> Dictionary:
	return {
		"at_market_site": true
	}

func get_effects() -> Dictionary:
	if Automation._FleetData[symbol]["cargo"]["units"] > 0:
		effects = {
			"cargo_is_empty": true,
			"cargo_is_full": false
		}
	return effects

enum states {IDLE,YIELD,SCOUTING,DOCKING,SELLING,FINISHED}
var cur = states.IDLE
var Leftover
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			if Automation._FleetData[symbol]["nav"]["status"] == "IN_ORBIT":
				cur = states.DOCKING
			elif Automation._MarketData.empty() or !Automation._MarketData.has(Automation._FleetData[symbol]["nav"]["waypointSymbol"]):
				cur = states.YIELD
				var operation = {"Ship":symbol,"Op":"SHOPPING"}
				Automation.emit_signal("OperationChanged",operation)
				
				get_market()
				#API.get_market(self,Automation._FleetData[symbol]["nav"]["systemSymbol"],Automation._FleetData[symbol]["nav"]["waypointSymbol"])
			elif Automation._FleetData[symbol]["nav"]["status"] == "DOCKED":
				cur = states.SELLING
		states.DOCKING:
			cur = states.YIELD
			var operation = {"Ship":symbol,"Op":"DOCKING"}
			Automation.emit_signal("OperationChanged",operation)
			
			dock_ship()
		states.SELLING:
			cur = states.YIELD
			var operation = {"Ship":symbol,"Op":"PURGING"}
			Automation.emit_signal("OperationChanged",operation)
			
			purge(Automation._FleetData[symbol])
		states.FINISHED:
			cur = states.IDLE
			var operation = {"Ship":symbol,"Op":"IDLE"}
			Automation.emit_signal("OperationChanged",operation)
			return true
#	if Automation._FleetData["FAKESHIP-1"]["cargo"]["units"] == 0: #leftover
#		cur = states.IDLE
#		return true
	return false

func purge(relevant):
	outputRID(str("SUBTASK:(purge) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
	
	var purgelist : Array
	var rmvAMT : int
	var income = 0
	var startwith = relevant["cargo"]["units"]
	for c in relevant["cargo"]["inventory"]:
		for g in Automation._MarketData[relevant["nav"]["waypointSymbol"]]["tradeGoods"]:
			if c["symbol"] == g["symbol"]:
				purgelist.push_back({"sym":g["symbol"],"amt":c["units"]})
				rmvAMT += c["units"]
				income += g["sellPrice"] * c["units"]
	
	if !officerOBj.sharedData[symbol].has("income"):
		officerOBj.sharedData[symbol]["income"] = income
	else: officerOBj.sharedData[symbol]["income"] += income
	
	print(purgelist)
	for purgable in purgelist:
		var req = _POST_REQUEST_OBj.duplicate()
		req.Callback = "_on_sell_cargo"
		req.API_ext = str("my/ships/",symbol,"/sell")
		req.data = {"symbol": purgable["sym"], "units": purgable["amt"]}
		req.RID = str(officer,"-SELL"," : ",symbol," (",purgable["sym"],purgable["amt"],")",Time.get_datetime_string_from_system())
		Automation.callQueue.push_back(req)
		yield(self,"cargo_sold")
		
	Leftover = startwith - rmvAMT
	
	if Leftover == 0:
		effects = {
			"cargo_is_empty": true,
			"cargo_is_full": false
		}
		print(symbol,"/expected ",officerOBj.sharedData[symbol]["expectedIncome"])
		print(symbol,"/actual ",officerOBj.sharedData[symbol]["income"])
		officerOBj.sharedData[symbol].erase("income")
	else:
		effects = {
			"cargo_is_empty": false,
			"cargo_is_full": false
		}
	API.get_market(self,Automation._FleetData[symbol]["nav"]["systemSymbol"],Automation._FleetData[symbol]["nav"]["waypointSymbol"])
	cur = states.FINISHED
#	print(relevant["ship"], " is Purging")
#	yield(get_tree(),"idle_frame")
#	print(relevant["ship"], " has finished purging")
#	Automation._FleetData["FAKESHIP-1"]["cargo"]["units"] = 0

signal cargo_sold
func _on_sell_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		#set_state(STATES["error"])
		pass
	else:
		#shipData["cargo"] = cleanbody["data"]["cargo"]
		emit_signal("cargo_sold")
		Agent.emit_signal("SellCargo",cleanbody)

#func dock(relevant):
#	print("Docking ",relevant["ship"])
#	yield(get_tree(),"idle_frame")
#	print(relevant["ship"], " has docked @ location")
#	Automation._FleetData["FAKESHIP-1"]["nav"]["status"] = "DOCKED"
#	cur = states.SELLING

func dock_ship():
	outputRID(str("SUBTASK:(dock_ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_dock_ship"
	req.API_ext = str("my/ships/",symbol,"/dock")
	req.RID = str(officer,"-DOCK_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

func _on_dock_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		PARSE["meta"] = symbol
		Automation.emit_signal("SHIPSTATUSUPDATE",PARSE)
		API.emit_signal("dock_ship_complete",PARSE)
		cur = states.IDLE

func get_market():
	outputRID(str("SUBTASK:(get_market) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_market"
	req.API_ext = str("systems/",Automation._FleetData[symbol]["nav"]["systemSymbol"],"/waypoints/",Automation._FleetData[symbol]["nav"]["waypointSymbol"],"/market")
	req.RID = str(officer,"-GET_MARKET"," : ",symbol,Time.get_datetime_string_from_system())
	Automation.callQueue.push_back(req)

func _on_get_market(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		Automation.emit_signal("GETMARKET",PARSE)
		while !Automation._MarketData.has(Automation._FleetData[symbol]["nav"]["waypointSymbol"]):
			yield(get_tree(),"idle_frame")
			if Automation._MarketData.has(Automation._FleetData[symbol]["nav"]["waypointSymbol"]):
				break
		cur = states.IDLE
