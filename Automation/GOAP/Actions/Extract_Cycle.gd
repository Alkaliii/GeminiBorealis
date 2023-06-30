extends goapACTION

class_name Extract_Cycle_Action
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

func _ready():
	set_action_name("Extract_Cycle")
	set_cost(1)

func get_requirements() -> Dictionary:
	var location = Automation._FleetData[symbol]["nav"]["waypointSymbol"]
	#determine extract site location
	var extract_site
	var extractTrait = ["MINERAL_DEPOSITS","COMMON_METAL_DEPOSITS","PRECIOUS_METAL_DEPOSITS","RARE_METAL_DEPOSITS","METHANE_POOLS","ICE_CRYSTALS","EXPLOSIVE_GASES"]
	var systemDir = Automation._SystemsData[Automation._FleetData[symbol]["nav"]["systemSymbol"]]["waypoints"]
	for waypoint in systemDir: for t in systemDir[waypoint]["traits"]: if t["symbol"] in extractTrait:
		extract_site = waypoint
		break
	#if at extract site already, change requirements
	if location == extract_site:
		return {
			"survey": true
		}
	return {
		"at_extract_site": true,
		"survey": true
	}

func get_effects() -> Dictionary:
	return {
		"cargo_is_full": true,
		"cargo_is_empty": false
	}

enum states {IDLE,YIELD,ORBITING,EXTRACTING,COOLING_DOWN}
var cur = states.IDLE
func execute(relevant, delta) -> bool:
	match cur:
		states.IDLE:
			if Automation._FleetData[symbol]["nav"]["status"] == "IN_ORBIT":
				cur = states.EXTRACTING
			elif Automation._FleetData[symbol]["nav"]["status"] == "DOCKED":
				cur = states.ORBITING
			var operation = {"Ship":symbol,"Op":"IDLE"}
			Automation.emit_signal("OperationChanged",operation)
		states.ORBITING:
			cur = states.YIELD
			var operation = {"Ship":symbol,"Op":"ORBITING"}
			Automation.emit_signal("OperationChanged",operation)
			
			outputRID(str("SUBTASK:(orbit ship) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
			
			orbit(Automation._FleetData[symbol]["nav"]["status"])
		states.EXTRACTING:
			cur = states.YIELD
			var operation = {"Ship":symbol,"Op":"EXTRACTING"}
			Automation.emit_signal("OperationChanged",operation)
			
			outputRID(str("SUBTASK:(extract resources) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
			
			extract(relevant)
		states.COOLING_DOWN:
			if Agent.cooldowns[symbol] < Time.get_unix_time_from_system():
				cur = states.EXTRACTING
	if Automation._FleetData[symbol]["cargo"]["units"] >= Automation._FleetData[symbol]["cargo"]["capacity"]:
		cur = states.IDLE
		return true
	return false

func checkSURVEY():
	var bestSurvey = {"survey": null, "FM": 1}
	if Agent.surveys.size() > 0:
		for s in Agent.surveys:
			var SUR = Agent.surveys[s]
			if Time.get_unix_time_from_datetime_string(SUR["expiration"]) < Time.get_unix_time_from_system():
				Agent.surveys.erase(s)
				continue
			if SUR["symbol"] == Automation._FleetData[symbol]["nav"]["waypointSymbol"]:
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

func extract(relevant):
	var survey = checkSURVEY()
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_extract_resources"
	req.API_ext = str("my/ships/",symbol,"/extract")
	if survey != null: req.data = {"survey":survey}
	req.RID = str(officer,"-EXTRACT_RESOURCES"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)
#	print(relevant["ship"], " is Extracting")
#	yield(get_tree(),"idle_frame")
#	print(relevant["ship"], " has finished extracting and is now on cooldown")
#	Automation._FleetData["FAKESHIP-1"]["cargo"]["units"] += 50

func _on_extract_resources(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		API.emit_signal("extract_resources_complete",PARSE)
		Agent.emit_signal("cooldownStarted",PARSE["data"]["cooldown"]["expiration"],PARSE["data"]["cooldown"]["shipSymbol"])
		Automation.emit_signal("EXTRACTRESOURCES",PARSE)
		var operation = {"Ship":symbol,"Op":"COOLDOWN"}
		Automation.emit_signal("OperationChanged",operation)
		
		outputRID(str("YIELD:(extract cooldown) started in /",self.get_action_name(),"/ on ",symbol," @ ",Time.get_datetime_string_from_system()))
		
		#Agent.cooldowns[symbol] = PARSE["data"]["cooldown"]["expiration"]
		yield(get_tree(),"idle_frame")
		cur = states.COOLING_DOWN

func orbit(relevant):
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_orbit_ship"
	req.API_ext = str("my/ships/",symbol,"/orbit")
	req.RID = str(officer,"-ORBIT_SHIP"," : ",symbol,Time.get_datetime_string_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)
	
#	print("Orbiting ",relevant["ship"])
#	yield(get_tree(),"idle_frame")
#	print(relevant["ship"], " has reached orbit")
#	Automation._FleetData["FAKESHIP-1"]["nav"]["status"] = "IN_ORBIT"

func _on_orbit_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		PARSE["meta"] = symbol
		Automation.emit_signal("SHIPSTATUSUPDATE",PARSE)
		API.emit_signal("orbit_ship_complete",PARSE)
		cur = states.EXTRACTING
