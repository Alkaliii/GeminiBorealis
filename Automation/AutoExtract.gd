extends STATEMACHINE
class_name AutoExtractFSM

var shipSymbol : String
var shipData : Dictionary
var Cooldown : int
var Leftover : int
var possibleFocus = ["PRECIOUS_STONES","QUARTZ_SAND","SILICON_CRYSTALS",
"AMMONIA_ICE","LIQUID_HYDROGEN","LIQUID_NITROGEN","ICE_WATER","EXOTIC_MATTER",
"ADVANCED_CIRCUITRY","GRAVITON_EMITTERS","IRON","IRON_ORE","COPPER","COPPER_ORE",
"ALUMINUM","ALUMINUM_ORE","SILVER","SILVER_ORE","GOLD","GOLD_ORE","PLATINUM",
"PLATINUM_ORE","DIAMONDS","URANITE","URANITE_ORE","MERITIUM","MERITIUM_ORE",
"HYDROCARBON","ANTIMATTER","FERTILIZERS","FABRICS","FOOD","JEWELRY","MACHINERY",
"FIREARMS","ASSAULT_RIFLES","MILITARY_EQUIPMENT","EXPLOSIVES","LAB_INSTRUMENTS",
"AMMUNITION","ELECTRONICS","SHIP_PLATING","EQUIPMENT","FUEL","MEDICINE","DRUGS",
"CLOTHING","MICROPROCESSORS","PLASTICS","POLYNUCLEOTIDES","BIOCOMPOSITES",
"NANOBOTS","AI_MAINFRAMES","QUANTUM_DRIVES","ROBOTIC_DRONES","CYBER_IMPLANTS",
"GENE_THERAPEUTICS","NEURAL_CHIPS","MOOD_REGULATORS","VIRAL_AGENTS",
"MICRO_FUSION_GENERATORS","SUPERGRAINS","LASER_RIFLES","HOLOGRAPHICS",
"SHIP_SALVAGE","RELIC_TECH","NOVEL_LIFEFORMS","BOTANICAL_SPECIMENS",
"CULTURAL_ARTIFACTS","REACTOR_SOLAR_I","REACTOR_FUSION_I","REACTOR_FISSION_I",
"REACTOR_CHEMICAL_I","REACTOR_ANTIMATTER_I","ENGINE_IMPULSE_DRIVE_I",
"ENGINE_ION_DRIVE_I","ENGINE_ION_DRIVE_II","ENGINE_HYPER_DRIVE_I",
"MODULE_MINERAL_PROCESSOR_I","MODULE_CARGO_HOLD_I","MODULE_CREW_QUARTERS_I",
"MODULE_ENVOY_QUARTERS_I","MODULE_PASSENGER_CABIN_I","MODULE_MICRO_REFINERY_I",
"MODULE_ORE_REFINERY_I","MODULE_FUEL_REFINERY_I","MODULE_SCIENCE_LAB_I",
"MODULE_JUMP_DRIVE_I","MODULE_JUMP_DRIVE_II","MODULE_JUMP_DRIVE_III",
"MODULE_WARP_DRIVE_I","MODULE_WARP_DRIVE_II","MODULE_WARP_DRIVE_III",
"MODULE_SHIELD_GENERATOR_I","MODULE_SHIELD_GENERATOR_II","MOUNT_GAS_SIPHON_I",
"MOUNT_GAS_SIPHON_II","MOUNT_GAS_SIPHON_III","MOUNT_SURVEYOR_I","MOUNT_SURVEYOR_II",
"MOUNT_SURVEYOR_III","MOUNT_SENSOR_ARRAY_I","MOUNT_SENSOR_ARRAY_II",
"MOUNT_SENSOR_ARRAY_III","MOUNT_MINING_LASER_I","MOUNT_MINING_LASER_II",
"MOUNT_MINING_LASER_III","MOUNT_LASER_CANNON_I","MOUNT_MISSILE_LAUNCHER_I",
"MOUNT_TURRET_I"]
var focusList : Array

export (Dictionary) var EXTRACT_POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_EXTRACTrequest_completed",
	"API_ext": str("my/ships/",shipSymbol,"/extract"), #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": str(shipSymbol,"EXTRACT",Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "POST"
}

export (Dictionary) var SURVEY_POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_SURVEYrequest_completed",
	"API_ext": str("my/ships/",shipSymbol,"/survey"), #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": str(shipSymbol,"SURVEY",Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "POST"
}

export (Dictionary) var ORBIT_POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_ORBITrequest_completed",
	"API_ext": str("my/ships/",shipSymbol,"/orbit"), #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": str(shipSymbol,"ORBIT",Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "POST"
}

export (Dictionary) var DOCK_POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_DOCKrequest_completed",
	"API_ext": str("my/ships/",shipSymbol,"/dock"), #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": str(shipSymbol,"DOCK",Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "POST"
}

export (Dictionary) var MARKET_POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_MARKETrequest_completed",
	"API_ext": str("systems/","systemSymbol","/waypoints/","waypointSymbol","/market"), #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": str(shipSymbol,"MARKET",Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "GET"
}

func _ready():
	add_state("Extract") #-> Cooldown,Orbit,Survey
	add_state("Yield_Cooldown") #-> Extract
	add_state("Yield_Orbit") #-> Extract
	add_state("Survey") #-> Cooldown
	add_state("Cargo_Full") #-> Dock
	add_state("Yield_Dock") #-> Purge,Visit
	add_state("Visit_Market") #-> Purge
	add_state("Purge") #-> Orbit
	add_state("pause")
	add_state("error")

func endFSM():
	Automation.callQueue.erase(EXTRACT_POST_REQUEST_OBj.RID)
	Automation.callQueue.erase(SURVEY_POST_REQUEST_OBj.RID)
	Automation.callQueue.erase(ORBIT_POST_REQUEST_OBj.RID)
	
	var operation = {"Ship":shipSymbol,"Op":"[wave]AWAITING ORDERS"}
	Automation.emit_signal("OperationChanged",operation)
	self.queue_free()

func state_logic(delta):
	match state:
		STATES.Extract: pass
		STATES.Yield_Cooldown:
			if Cooldown == 0: return
			if Cooldown < Time.get_unix_time_from_system():
				cooldownOver()
		STATES.Yield_Orbit:
			if shipData["nav"]["status"] == "IN_ORBIT":
				set_state(STATES.Extract)
		STATES.Survey: pass
		STATES.Yield_Dock:
			if shipData["nav"]["status"] == "DOCKED":
				if Automation._MarketData.has(shipData["nav"]["waypointSymbol"]):
					set_state(STATES.Purge)
				else:
					set_state(STATES.Visit_Market)
		STATES.Visit_Market:
			if Automation._MarketData.has(shipData["nav"]["waypointSymbol"]):
				set_state(STATES.Purge)
		STATES.Purge:
			if shipData["cargo"]["units"] <= Leftover:
				ORBIT_POST_REQUEST_OBj.API_ext = str("my/ships/",shipSymbol,"/orbit")
				ORBIT_POST_REQUEST_OBj.RID = str(shipSymbol,"ORBIT",Time.get_unix_time_from_system())
				Automation.callQueue.push_back(ORBIT_POST_REQUEST_OBj)
				print(shipSymbol," is ORBITING")
				set_state(STATES.Yield_Orbit)
		STATES.error: pass

func cooldownOver():
	Cooldown = 0
	yield(get_tree().create_timer(3),"timeout")
	Agent.cooldowns.erase(shipSymbol)
	set_state(STATES["Extract"])

func validateLOCATION():
	var extractTrait = ["MINERAL_DEPOSITS","COMMON_METAL_DEPOSITS","PRECIOUS_METAL_DEPOSITS","RARE_METAL_DEPOSITS","METHANE_POOLS","ICE_CRYSTALS","EXPLOSIVE_GASES"]
	var pt = Automation._SystemsData[shipData["nav"]["systemSymbol"]]["waypoints"]
	for w in Automation._SystemsData[shipData["nav"]["systemSymbol"]]["waypoints"]: if pt[w]["symbol"] == shipData["nav"]["waypointSymbol"]:
		var wpt = Automation._SystemsData[shipData["nav"]["systemSymbol"]]["waypoints"][w]
		for t in wpt["traits"]: if t["symbol"] in extractTrait:
			return true
	return false

func validateMOUNT():
	var extractGas = ["MOUNT_GAS_SIPHON_I","MOUNT_GAS_SIPHON_II","MOUNT_GAS_SIPHON_III"]
	var extractOre = ["MOUNT_MINING_LASER_I","MOUNT_MINING_LASER_II","MOUNT_MINING_LASER_III"]
	for m in shipData["mounts"]: if m["symbol"] in extractGas or m["symbol"] in extractOre:
		return true
	return false

func validateSTATUS():
	if shipData["nav"]["status"] == "IN_ORBIT":
		return true
	
	#this can be auto resolved
	ORBIT_POST_REQUEST_OBj.API_ext = str("my/ships/",shipSymbol,"/orbit")
	ORBIT_POST_REQUEST_OBj.RID = str(shipSymbol,"ORBIT",Time.get_unix_time_from_system())
	Automation.callQueue.push_back(ORBIT_POST_REQUEST_OBj)
	print(shipSymbol," is ORBITING")
	return false

func checkSURVEY():
	var bestSurvey = {"survey": null, "FM": 1}
	if Agent.surveys.size() > 0:
		for s in Agent.surveys:
			var SUR = Agent.surveys[s]
			if Time.get_unix_time_from_datetime_string(SUR["expiration"]) < Time.get_unix_time_from_system():
				Agent.surveys.erase(s)
				continue
			if SUR["symbol"] == shipData["nav"]["waypointSymbol"]:
				var focusMatch = 0
				if focusList.size() > 0: for d in SUR["deposits"]: if d["symbol"] in focusList:
					focusMatch += 1
				match SUR["size"]:
					"SMALL":
						focusMatch += 1
					"MODERATE":
						focusMatch += 2
					"BIG":
						focusMatch += 3
				if bestSurvey["FM"] < focusMatch:
					bestSurvey = {"survey": SUR, "FM": focusMatch}
	return bestSurvey["survey"]

func _get_transition(delta):
	return null

func _enter_state(new_state, old_state):
	yield(get_tree(),"idle_frame")
	
	shipData = Automation._FleetData[shipSymbol]
	
	match new_state:
		STATES.Extract:
			var operation = {"Ship":shipSymbol,"Op":"EXTRACTING"}
			Automation.emit_signal("OperationChanged",operation)
			
			if shipData["cargo"]["units"] == shipData["cargo"]["capacity"]:
				set_state(STATES.Cargo_Full)
				operation = {"Ship":shipSymbol,"Op":"CARGO FULL"}
				Automation.emit_signal("OperationChanged",operation)
				return
			
			var _1 = true
			var _2 = true
			var _3 = true
			
			if !validateLOCATION(): 
				set_state(STATES["error"])
				return
			if !validateMOUNT(): 
				set_state(STATES["error"])
				return
			if !validateSTATUS():
				set_state(STATES["Yield_Orbit"])
				return
			if _1 and _2 and _3: #Triple Affirmative
				var SUR = checkSURVEY()
				yield(get_tree(),"idle_frame")
				if SUR == null:
					var surveyWpt = ["MOUNT_SURVEYOR_I","MOUNT_SURVEYOR_II","MOUNT_SURVEYOR_III"]
					for m in shipData["mounts"]:
						if m["symbol"] in surveyWpt:
							set_state(STATES["Survey"])
							return
				
				if Agent.cooldowns.has(shipSymbol):
					Cooldown = Agent.cooldowns[shipSymbol]
					set_state(STATES["Yield_Cooldown"])
					return
				
				EXTRACT_POST_REQUEST_OBj.API_ext = str("my/ships/",shipSymbol,"/extract")
				EXTRACT_POST_REQUEST_OBj.RID = str(shipSymbol,"EXTRACT",Time.get_unix_time_from_system())
				EXTRACT_POST_REQUEST_OBj.data = SUR
				Automation.callQueue.push_back(EXTRACT_POST_REQUEST_OBj)
				print(shipSymbol," is EXTRACTING")
			#print("help")
		STATES.Yield_Cooldown:
			var operation
			if shipData["cargo"]["units"] == shipData["cargo"]["capacity"]:
				set_state(STATES.Cargo_Full)
				operation = {"Ship":shipSymbol,"Op":"CARGO FULL"}
				Automation.emit_signal("OperationChanged",operation)
				return
			operation = {"Ship":shipSymbol,"Op":"COOLING DOWN"}
			Automation.emit_signal("OperationChanged",operation)
		STATES.Yield_Orbit:
			var operation = {"Ship":shipSymbol,"Op":"ORBITING"}
			Automation.emit_signal("OperationChanged",operation)
		STATES.Survey:
			var operation = {"Ship":shipSymbol,"Op":"SURVEYING"}
			Automation.emit_signal("OperationChanged",operation)
			SURVEY_POST_REQUEST_OBj.API_ext = str("my/ships/",shipSymbol,"/survey")
			SURVEY_POST_REQUEST_OBj.RID = str(shipSymbol,"SURVEY",Time.get_unix_time_from_system())
			Automation.callQueue.push_back(SURVEY_POST_REQUEST_OBj)
			print(shipSymbol," is SURVEYING")
		STATES.Cargo_Full:
			DOCK_POST_REQUEST_OBj.API_ext = str("my/ships/",shipSymbol,"/dock")
			DOCK_POST_REQUEST_OBj.RID = str(shipSymbol,"DOCK",Time.get_unix_time_from_system())
			Automation.callQueue.push_back(DOCK_POST_REQUEST_OBj)
			print(shipSymbol," is DOCKING")
			set_state(STATES["Yield_Dock"])
		STATES.Yield_Dock:
			var operation = {"Ship":shipSymbol,"Op":"DOCKING"}
			Automation.emit_signal("OperationChanged",operation)
		STATES.Visit_Market:
			var operation = {"Ship":shipSymbol,"Op":"SHOPPING"}
			Automation.emit_signal("OperationChanged",operation)
			MARKET_POST_REQUEST_OBj.API_ext = str("systems/",shipData["nav"]["systemSymbol"],"/waypoints/",shipData["nav"]["waypointSymbol"],"/market")
			MARKET_POST_REQUEST_OBj.RID = str(shipSymbol,"MARKET",Time.get_unix_time_from_system())
			Automation.callQueue.push_back(MARKET_POST_REQUEST_OBj)
			print(shipSymbol," is SHOPPING")
		STATES.Purge:
			var operation = {"Ship":shipSymbol,"Op":"PURGING"}
			Automation.emit_signal("OperationChanged",operation)
			var purgelist : Array
			var rmvAMT : int
			for c in shipData["cargo"]["inventory"]:
				for g in Automation._MarketData[shipData["nav"]["waypointSymbol"]]["tradeGoods"]:
					if c["symbol"] == g["symbol"]:
						purgelist.push_back({"sym":g["symbol"],"amt":c["units"]})
						rmvAMT += c["units"]
			
			print(purgelist)
			for purgable in purgelist:
				var PURGE_POST_REQUEST_OBj = {
					"Author": self,
					"Callback": "_on_SELLrequest_completed",
					"API_ext": str("my/ships/",shipSymbol,"/sell"), #After "v2" in https://api.spacetraders.io/v2
					"data": {"symbol": purgable["sym"], "units": purgable["amt"]}, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
					"RID": str(shipSymbol,"SELL",purgable["sym"],Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
					"TYPE": "POST"
				}
				
				Automation.callQueue.push_back(PURGE_POST_REQUEST_OBj)
				yield(self,"cargo_sold")
			
			Leftover = shipData["cargo"]["capacity"] - rmvAMT
			
		STATES.error:
			var operation = {"Ship":shipSymbol,"Op":"[color=#EE4B2B]ERROR"}
			Automation.emit_signal("OperationChanged",operation)
			OfficerStatus = 1

func _exit_state(old_state, new_state):
	pass

func _on_EXTRACTrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		set_state(STATES["error"])
	else:
		Cooldown = Time.get_unix_time_from_datetime_string(cleanbody["data"]["cooldown"]["expiration"])
		shipData["cargo"] = cleanbody["data"]["cargo"]
		Agent.emit_signal("cooldownStarted",cleanbody["data"]["cooldown"]["expiration"],cleanbody["data"]["cooldown"]["shipSymbol"])
		Automation.emit_signal("EXTRACTRESOURCES",cleanbody)
		set_state(STATES["Yield_Cooldown"])
		
		Automation.progressQueue.erase(EXTRACT_POST_REQUEST_OBj.RID)

func _on_SURVEYrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		set_state(STATES["error"])
	else:
		Cooldown = Time.get_unix_time_from_datetime_string(cleanbody["data"]["cooldown"]["expiration"])
		Agent.emit_signal("cooldownStarted",cleanbody["data"]["cooldown"]["expiration"],cleanbody["data"]["cooldown"]["shipSymbol"])
		for s in cleanbody["data"]["surveys"]:
			Agent.surveys[s["signature"]] = s
		Save.writeUserSave()
		set_state(STATES["Yield_Cooldown"])
		
		Automation.progressQueue.erase(SURVEY_POST_REQUEST_OBj.RID)

func _on_ORBITrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		set_state(STATES["error"])
	else:
		shipData["nav"] = cleanbody["data"]["nav"]
		cleanbody["meta"] = shipData["symbol"]
		Agent.emit_signal("OrbitFinished",cleanbody)
		
		Automation.progressQueue.erase(ORBIT_POST_REQUEST_OBj.RID)

func _on_DOCKrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		set_state(STATES["error"])
	else:
		shipData["nav"] = cleanbody["data"]["nav"]
		cleanbody["meta"] = shipData["symbol"]
		Agent.emit_signal("DockFinished",cleanbody)
		
		Automation.progressQueue.erase(DOCK_POST_REQUEST_OBj.RID)

func _on_MARKETrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		set_state(STATES["error"])
	else:
		Agent.emit_signal("visitmarket",cleanbody,shipData["nav"]["waypointSymbol"],shipData["nav"]["systemSymbol"],true)

signal cargo_sold
func _on_SELLrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("error"):
		#set_state(STATES["error"])
		pass
	else:
		shipData["cargo"] = cleanbody["data"]["cargo"]
		emit_signal("cargo_sold")
		Agent.emit_signal("SellCargo",cleanbody)
