extends Control

const cargoline = preload("res://Interface/Ships/CargoListing.tscn")
var ArrivalTime = null
var CooldownTime = null
var SHIPDATA

var NAVWAYPOINT
var sSURVEY

func _ready():
	Agent.connect("login",self,"clearInfo")
	Agent.connect("mapHOME",self,"clearInfo")
	Agent.connect("shipfocused",self,"setdat")
	Agent.connect("JettisonCargo",self,"refreshCargo")
	Agent.connect("selectedWaypoint",self,"prepNav")
	pass # Replace with function body.

func _process(delta):
	updateTransit()

func updateTransit():
	if ArrivalTime != null:
		var future = Time.get_unix_time_from_datetime_string(ArrivalTime)
		var present = Time.get_unix_time_from_system()
		if present > future:
			$VBoxContainer/TransitTime.bbcode_text = "ARRIVED [color=#949495]MANUALLY REFRESH"
			ArrivalTime = null
			if Agent.menu == "SHIPS":
				Agent.emit_signal("requestFleetUpdate")
			return
		
		var difference = int(future-present)
		var seconds = difference%60
		var minutes = difference/60
		var left = "%02d:%02d" % [minutes,seconds]
		$VBoxContainer/TransitTime.bbcode_text = str("ETA:[b] ", left)

func clearInfo():
	for r in $VBoxContainer/ScrollContainer/Inventory.get_children():
		r.queue_free()
	self.hide()

func refreshCargo(data):
	for r in $VBoxContainer/ScrollContainer/Inventory.get_children():
		r.queue_free()
	
	for c in data["data"]["cargo"]["inventory"]:
		yield(get_tree(),"idle_frame")
		var cargo = cargoline.instance()
		cargo.setdat(c)
		$VBoxContainer/ScrollContainer/Inventory.add_child(cargo)

func setdat(data):
	self.show()
	if SHIPDATA == data: return
	SHIPDATA = data
	
	var type = $VBoxContainer/ShipType
	var symbol = $VBoxContainer/ShipName
	var status = $VBoxContainer/HBoxContainer/ShipStatusBadge
	var location = $VBoxContainer/HBoxContainer/Location
	var flight = $VBoxContainer/FlightInfo
	var fuel = $VBoxContainer/HBoxContainer3/FuelLabel
	var fuelbar = $VBoxContainer/HBoxContainer3/ProgressBar
	var transit = $VBoxContainer/TransitTime
	var actions = $VBoxContainer/Actions/OptionButton
	
	for r in $VBoxContainer/ScrollContainer/Inventory.get_children():
		r.queue_free()
	
	for c in data["cargo"]["inventory"]:
		yield(get_tree(),"idle_frame")
		var cargo = cargoline.instance()
		cargo.setdat(c)
		$VBoxContainer/ScrollContainer/Inventory.add_child(cargo)
	
	actions.clear()
	
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("ASSIGN GROUP")
		actions.add_item("RENAME")
	
	type.bbcode_text = str(data["registration"]["role"])
	var SHID = data["symbol"]
	symbol.bbcode_text = str("[",SHID,"]")
	status.sns = data["nav"]["status"]
	status.setdat()
	match data["nav"]["status"]:
		"IN_TRANSIT":
			location.bbcode_text = str("-> [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.show()
		"IN_ORBIT":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.hide()
			actions.add_item("DOCK")
		"DOCKED":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = ""
			transit.hide()
			actions.add_item("ORBIT")
			actions.add_item("REFUEL")
	
	var twee
	if data["reactor"]["symbol"] != "REACTOR_SOLAR_I":
		fuel.bbcode_text = str("[b]FUEL: ",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),"%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		fuel.bbcode_text = str("[b]SOLR: 100%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",100.0,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if data["nav"]["status"] == "IN_TRANSIT":
		ArrivalTime = data["nav"]["route"]["arrival"]
	else: 
		ArrivalTime = null
	
	if data["nav"]["status"] == "IN_ORBIT":
		actions.add_item("NAVIGATE")
	
#	#Check Jump
#	if data["nav"]["route"]["destination"]["type"] == "JUMP_GATE" and data["nav"]["status"] == "IN_ORBIT":
#		actions.add_item("JUMP")
#	elif data["nav"]["status"] == "IN_ORBIT":
#		for m in data["modules"]:
#			if m["symbol"] in ["MODULE_JUMP_DRIVE_I","MODULE_JUMP_DRIVE_II","MODULE_JUMP_DRIVE_III"]:
#				actions.add_item("JUMP")
#				break
#	#Check Warp
#	if data["nav"]["status"] == "IN_ORBIT":
#		for m in data["modules"]:
#			if m["symbol"] in ["MODULE_WARP_DRIVE_I","MODULE_WARP_DRIVE_II","MODULE_WARP_DRIVE_III"]:
#				actions.add_item("WARP")
#				break
	
	#Check Refinery
	for m in data["modules"]:
		if m["symbol"] in ["MODULE_MICRO_REFINERY_I","MODULE_ORE_REFINERY_I","MODULE_FUEL_REFINERY_I"]:
			actions.add_item("REFINE")
			break
	
	#Extract/Survey
	if data["nav"]["status"] == "IN_ORBIT":
		var extractGas = ["MOUNT_GAS_SIPHON_I","MOUNT_GAS_SIPHON_II","MOUNT_GAS_SIPHON_III"]
		var extractOre = ["MOUNT_MINING_LASER_I","MOUNT_MINING_LASER_II","MOUNT_MINING_LASER_III"]
		var surveyWpt = ["MOUNT_SURVEYOR_I","MOUNT_SURVEYOR_II","MOUNT_SURVEYOR_III"]
		var extractTrait = ["MINERAL_DEPOSITS","COMMON_METAL_DEPOSITS","PRECIOUS_METAL_DEPOSITS","RARE_METAL_DEPOSITS","METHANE_POOLS","ICE_CRYSTALS","EXPLOSIVE_GASES"]
		
		for w in Agent.systemData["data"]: if w["symbol"] == data["nav"]["waypointSymbol"]:
			for t in w["traits"]: if t["symbol"] in extractTrait:
				for m in data["mounts"]:
					if m["symbol"] in surveyWpt:
						actions.add_item("SURVEY")
						break
				for m in data["mounts"]:
					if m["symbol"] in extractGas or m["symbol"] in extractOre:
						actions.add_item("EXTRACT")
						break
				break
			else: continue
		
	actions.add_separator()
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("INSTALL HARDWARE")
		actions.add_item("REMOVE HARDWARE")
	if data["nav"]["status"] in ["IN_TRANSIT","IN_ORBIT"]:
		actions.add_item("CHANGE FLIGHT MODE")


func _on_Button_pressed():
	match $VBoxContainer/Actions/OptionButton.get_item_text($VBoxContainer/Actions/OptionButton.selected):
		"ASSIGN GROUP": pass
		"RENAME": pass
		"DOCK":
			Dock()
		"ORBIT":
			Orbit()
		"REFUEL":
			Refuel()
		"NAVIGATE":
			Navigate()
		#"JUMP": pass
		#"WARP": pass
		"REFINE": pass
		"SURVEY":
			Survey()
		"EXTRACT":
			Extract()
		"INSTALL HARDWARE": pass
		"REMOVE HARDWARE": pass
		"CHANGE FLIGHT MODE": pass

func prepNav(data):
	NAVWAYPOINT = data

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/navigate
func Navigate():
	Agent.queryWaypoint(SHIPDATA["nav"]["systemSymbol"])
	yield(Agent,"selectedWaypoint")
	
	if NAVWAYPOINT == "CANCEL": return
	
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_NAVrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/navigate")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var data = JSON.print({"waypointSymbol": NAVWAYPOINT})
	var header = ["Content-Type: application/json",headerstring]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_NAVrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("NavigationFinished",cleanbody)
		Agent.emit_signal("mapGenLine",
		Vector2(cleanbody["data"]["nav"]["route"]["departure"]["x"],cleanbody["data"]["nav"]["route"]["departure"]["y"]),
		Vector2(cleanbody["data"]["nav"]["route"]["destination"]["x"],cleanbody["data"]["nav"]["route"]["destination"]["y"]), Color(1,1,0,0.5), true, cleanbody["data"]["nav"]["route"]["arrival"])
		Agent.emit_signal("FocusMapNav",
			{
			"data":
				{
				"x": (cleanbody["data"]["nav"]["route"]["departure"]["x"]+cleanbody["data"]["nav"]["route"]["destination"]["x"])/2,
				"y": (cleanbody["data"]["nav"]["route"]["departure"]["y"]+cleanbody["data"]["nav"]["route"]["destination"]["y"])/2
				}
			})
		refreshONNAV(cleanbody)
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)

func refreshONNAV(data):
	if data["data"]["nav"]["status"] != "IN_TRANSIT": return
	data = data["data"]
	SHIPDATA["fuel"] = data["fuel"]
	SHIPDATA["nav"] = data["nav"]
	
	var status = $VBoxContainer/HBoxContainer/ShipStatusBadge
	var location = $VBoxContainer/HBoxContainer/Location
	var flight = $VBoxContainer/FlightInfo
	var fuel = $VBoxContainer/HBoxContainer3/FuelLabel
	var fuelbar = $VBoxContainer/HBoxContainer3/ProgressBar
	var transit = $VBoxContainer/TransitTime
	var actions = $VBoxContainer/Actions/OptionButton
	
	actions.clear()
	
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("ASSIGN GROUP")
		actions.add_item("RENAME")
	
	status.sns = data["nav"]["status"]
	status.setdat()
	match data["nav"]["status"]:
		"IN_TRANSIT":
			location.bbcode_text = str("-> [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.show()
		"IN_ORBIT":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.hide()
			actions.add_item("DOCK")
		"DOCKED":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = ""
			transit.hide()
			actions.add_item("ORBIT")
			actions.add_item("REFUEL")
	
	var twee
	if data["fuel"]["capacity"] != 0:
		fuel.bbcode_text = str("[b]FUEL: ",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),"%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		fuel.bbcode_text = str("[b]SOLR: 100%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",100.0,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	if data["nav"]["status"] == "IN_TRANSIT":
		ArrivalTime = data["nav"]["route"]["arrival"]
	else: ArrivalTime = null
	
	actions.add_separator()
	if data["nav"]["status"] in ["IN_TRANSIT","IN_ORBIT"]:
		actions.add_item("CHANGE FLIGHT MODE")

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/dock
func Dock():
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_DOCKrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/dock")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_DOCKrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("DockFinished",cleanbody)
		refreshONDOCK(cleanbody)
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)

func refreshONDOCK(data):
	data = data["data"]
	
	var status = $VBoxContainer/HBoxContainer/ShipStatusBadge
	var location = $VBoxContainer/HBoxContainer/Location
	var flight = $VBoxContainer/FlightInfo
	var transit = $VBoxContainer/TransitTime
	
	var actions = $VBoxContainer/Actions/OptionButton
	
	actions.clear()
	
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("ASSIGN GROUP")
		actions.add_item("RENAME")
	
	status.sns = data["nav"]["status"]
	status.setdat()
	match data["nav"]["status"]:
		"IN_TRANSIT":
			location.bbcode_text = str("-> [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.show()
		"IN_ORBIT":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.hide()
			actions.add_item("DOCK")
		"DOCKED":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = ""
			transit.hide()
			actions.add_item("ORBIT")
			actions.add_item("REFUEL")
	
	#Check Refinery
	for m in SHIPDATA["modules"]:
		if m["symbol"] in ["MODULE_MICRO_REFINERY_I","MODULE_ORE_REFINERY_I","MODULE_FUEL_REFINERY_I"]:
			actions.add_item("REFINE")
			break
	actions.add_separator()
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("INSTALL HARDWARE")
		actions.add_item("REMOVE HARDWARE")
	if data["nav"]["status"] in ["IN_TRANSIT","IN_ORBIT"]:
		actions.add_item("CHANGE FLIGHT MODE")

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/orbit
func Orbit():
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_ORBITrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/orbit")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_ORBITrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("OrbitFinished",cleanbody)
		refreshONORBIT(cleanbody)
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)

func refreshONORBIT(data):
	data = data["data"]
	
	var status = $VBoxContainer/HBoxContainer/ShipStatusBadge
	var location = $VBoxContainer/HBoxContainer/Location
	var flight = $VBoxContainer/FlightInfo
	var transit = $VBoxContainer/TransitTime
	
	var actions = $VBoxContainer/Actions/OptionButton
	
	actions.clear()
	
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("ASSIGN GROUP")
		actions.add_item("RENAME")
	
	status.sns = data["nav"]["status"]
	status.setdat()
	match data["nav"]["status"]:
		"IN_TRANSIT":
			location.bbcode_text = str("-> [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.show()
		"IN_ORBIT":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = str("[color=#949495]/// FLIGHT MODE: [b]",data["nav"]["flightMode"])
			transit.hide()
			actions.add_item("DOCK")
		"DOCKED":
			location.bbcode_text = str("@ [b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["waypointSymbol"])
			flight.bbcode_text = ""
			transit.hide()
			actions.add_item("ORBIT")
			actions.add_item("REFUEL")
	
	#Check Refinery
	for m in SHIPDATA["modules"]:
		if m["symbol"] in ["MODULE_MICRO_REFINERY_I","MODULE_ORE_REFINERY_I","MODULE_FUEL_REFINERY_I"]:
			actions.add_item("REFINE")
			break
	actions.add_separator()
	if data["nav"]["status"] == "DOCKED":
		actions.add_item("INSTALL HARDWARE")
		actions.add_item("REMOVE HARDWARE")
	if data["nav"]["status"] in ["IN_TRANSIT","IN_ORBIT"]:
		actions.add_item("CHANGE FLIGHT MODE")

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/refuel
func Refuel():
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_REFUELrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/refuel")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_REFUELrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("RefuelFinished",cleanbody)
		refreshONREFUEL(cleanbody)
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)

func refreshONREFUEL(data):
	data = data["data"]
	
	var fuel = $VBoxContainer/HBoxContainer3/FuelLabel
	var fuelbar = $VBoxContainer/HBoxContainer3/ProgressBar
	
	var twee
	if SHIPDATA["reactor"]["symbol"] != "REACTOR_SOLAR_I":
		fuel.bbcode_text = str("[b]FUEL: ",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),"%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",round((float(data["fuel"]["current"])/float(data["fuel"]["capacity"]))*100.0),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	else:
		fuel.bbcode_text = str("[b]SOLR: 100%")
		twee = get_tree().create_tween()
		twee.tween_property(fuelbar,"value",100.0,0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/survey
func Survey():
	if CooldownTime != null and Time.get_unix_time_from_datetime_string(CooldownTime) > Time.get_unix_time_from_system():
		#tell player about cooldown
		return
	else: CooldownTime = null
	
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_SURVEYrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/survey")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_SURVEYrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		for s in cleanbody["data"]["surveys"]:
			Agent.surveys[s["signature"]] = s
		CooldownTime = cleanbody["data"]["cooldown"]["expiration"]
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)


func prepExtract(signature):
	sSURVEY = signature

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/extract
func Extract():
	sSURVEY = null
	if CooldownTime != null and Time.get_unix_time_from_datetime_string(CooldownTime) > Time.get_unix_time_from_system():
		#tell player about cooldown
		return
	else: CooldownTime = null
	
	if Agent.surveys.size() != 0:
		Agent.emit_signal("query_Survey",SHIPDATA["nav"]["waypointSymbol"])
		yield(Agent,"selectedSurvey")
	
	if sSURVEY == "CANCEL" or sSURVEY == null:
		sSURVEY = null
	else:
		var expire = Time.get_unix_time_from_datetime_string(Agent.surveys[sSURVEY]["expiration"])
		if expire < Time.get_unix_time_from_system():
			Agent.surveys.erase(sSURVEY)
			sSURVEY = null
	
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_EXTRACTrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.focusShip,"/extract")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var data
	var header
	
	if sSURVEY != null:
		data = JSON.print({"survey": Agent.surveys[sSURVEY]})
		header = ["Content-Type: application/json",headerstring]
		HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	else:
		header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
		HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_EXTRACTrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		refreshCargo(cleanbody)
		CooldownTime = cleanbody["data"]["cooldown"]["expiration"]
	else:
		Agent.dispError(cleanbody)
	print(json.result)
