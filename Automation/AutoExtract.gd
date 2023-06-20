extends STATEMACHINE
class_name AutoExtractFSM

var shipSymbol : String
var shipData : Dictionary
var Cooldown : int
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

func _ready():
	add_state("Extract")
	add_state("Yield_Cooldown")
	add_state("Yield_Orbit")
	add_state("Survey")
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
			if Cooldown < Time.get_unix_time_from_system():
				set_state(STATES["Extract"])
		STATES.Yield_Orbit:
			if shipData["nav"]["status"] == "IN_ORBIT":
				set_state(STATES.Extract)
		STATES.Survey: pass
		STATES.error: pass

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
	match new_state:
		STATES.Extract:
			var operation = {"Ship":shipSymbol,"Op":"EXTRACTING"}
			Automation.emit_signal("OperationChanged",operation)
			
			if shipData["cargo"]["units"] == shipData["cargo"]["capacity"]:
				set_state(null)
				operation = {"Ship":shipSymbol,"Op":"CARGO FULL"}
				Automation.emit_signal("OperationChanged",operation)
				OfficerStatus = 2
				return
			
			var _1 = false
			_1 = validateLOCATION()
			var _2 = false
			_2 = validateMOUNT()
			var _3 = false
			_3 = validateSTATUS()
			yield(get_tree(),"idle_frame")
			if !_1: 
				set_state(STATES["error"])
				return
			elif !_2: 
				set_state(STATES["error"])
				return
			elif !_3:
				set_state(STATES["Yield_Orbit"])
				return
			if _1 and _2 and _3: #Triple Affirmative
				var SUR = checkSURVEY()
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
		STATES.Yield_Cooldown:
			var operation
			if shipData["cargo"]["units"] == shipData["cargo"]["capacity"]:
				set_state(null)
				operation = {"Ship":shipSymbol,"Op":"CARGO FULL"}
				Automation.emit_signal("OperationChanged",operation)
				OfficerStatus = 2
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
		pass
#		if Automation.progressQueue.size() > 0 and Automation.progressQueue.has(SURVEY_POST_REQUEST_OBj.RID):
#			var req = Automation.progressQueue[EXTRACT_POST_REQUEST_OBj.RID]
#			Automation.progressQueue.erase(EXTRACT_POST_REQUEST_OBj.RID)
#			Automation.callQueue.push_back(req)
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
		pass
#		if Automation.progressQueue.size() > 0 and Automation.progressQueue.has(SURVEY_POST_REQUEST_OBj.RID):
#			var req = Automation.progressQueue[SURVEY_POST_REQUEST_OBj.RID]
#			Automation.progressQueue.erase(SURVEY_POST_REQUEST_OBj.RID)
#			Automation.callQueue.push_back(req)
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
		pass
#		if Automation.progressQueue.size() > 0 and Automation.progressQueue.has(SURVEY_POST_REQUEST_OBj.RID):
#			var req = Automation.progressQueue[ORBIT_POST_REQUEST_OBj.RID]
#			Automation.progressQueue.erase(ORBIT_POST_REQUEST_OBj.RID)
#			Automation.callQueue.push_back(req)
	else:
		shipData["nav"] = cleanbody["data"]["nav"]
		cleanbody["meta"] = shipData["symbol"]
		Agent.emit_signal("OrbitFinished",cleanbody)
		
		Automation.progressQueue.erase(ORBIT_POST_REQUEST_OBj.RID)