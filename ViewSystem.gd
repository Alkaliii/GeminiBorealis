extends VBoxContainer

const waypoint = preload("res://WaypointButton.tscn")
const wayaction = preload("res://WaypointFunctionButton.tscn")

export var waypointInfo : NodePath
var selected : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	get_node(waypointInfo).hide()
	Agent.connect("login", self, "show")
	Agent.connect("chart", self, "setWaypointDat")
	Agent.connect("mapHOME",self,"unFocus")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func unFocus():
	for r in $Actions.get_children():
		r.queue_free()
	
	for b in $ScrollContainer/HBoxContainer.get_children():
		b.release_focus()

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		setdat(cleanbody)
		Agent.emit_signal("systemFetch",cleanbody)
		fetchSysWay()
#	else:
#		getfail()
	print(json.result)

func setWaypointDat(data):
	var twee = get_tree().create_tween()
	get_node(waypointInfo).modulate = Color(1,1,1,0)
	get_node(waypointInfo).show()
	twee.tween_property(get_node(waypointInfo), "modulate", Color(1,1,1,1), 1)
	
	get_node(waypointInfo).setdat(data)
	
	#move to here
	for c in $Actions.get_children():
		c.queue_free()
		
	if data["data"]["orbitals"].size() != 0:
		for o in data["data"]["orbitals"]:
			var orbital = wayaction.instance()
			orbital.text = str(o["symbol"])
			orbital.wpt = 3
			orbital.ss = data["data"]["systemSymbol"]
			orbital.ws = o["symbol"]
			orbital.setOrbital()
			$Actions.add_child(orbital)
	
	for t in data["data"]["traits"]:
		var col = ""
		var colend = ""
		var sym = t["symbol"]
		match t["symbol"]:
			"MARKETPLACE":
				var visiting = false
				for s in Agent._FleetData["data"]:
					if s["nav"]["waypointSymbol"] == data["data"]["symbol"] and s["nav"]["status"] != "IN_TRANSIT":
						visiting = true
				
				if visiting:
					col = "[color=#FFBF00]"
					colend = "[/color]"
					var marketplace = wayaction.instance()
					marketplace.text = "Open Market"
					marketplace.wpt = 0
					marketplace.ss = data["data"]["systemSymbol"]
					marketplace.ws = data["data"]["symbol"]
					$Actions.add_child(marketplace)
				#else suggest navigating to location
			"SHIPYARD":
				var visiting = false
				for s in Agent._FleetData["data"]:
					if s["nav"]["waypointSymbol"] == data["data"]["symbol"] and s["nav"]["status"] != "IN_TRANSIT":
						visiting = true
						
				if visiting:
					col = "[color=#DA70D6][wave]"
					colend = "[/wave][/color]"
					var shipyard = wayaction.instance()
					shipyard.text = "Open Shipyard"
					shipyard.wpt = 1
					shipyard.ss = data["data"]["systemSymbol"]
					shipyard.ws = data["data"]["symbol"]
					$Actions.add_child(shipyard)
	if data["data"]["type"] == "JUMP_GATE":
		var jump = wayaction.instance()
		jump.text = "Open Jump Gate"
		jump.wpt = 2
		jump.ss = data["data"]["systemSymbol"]
		jump.ws = data["data"]["symbol"]
		$Actions.add_child(jump)

func setdat(data):
	for r in $ScrollContainer/HBoxContainer.get_children():
		r.queue_free()
	
	for w in data["data"]["waypoints"]:
		var new = waypoint.instance()
		new.symbol = w["symbol"]
		new.type = w["type"]
		new.xpos = w["x"]
		new.ypos = w["y"]
		new.text = str(w["type"]," ",w["symbol"])
		new.setXY(str("[color=#71797E]x:[b]",w["x"],"[/b]/y:[b]",w["y"]))
		$ScrollContainer/HBoxContainer.add_child(new)

func show():
	self.modulate = Color(1,1,1,0)
	self.visible = true
	var twee = get_tree().create_tween()
	twee.tween_property(self, "modulate", Color(1,1,1,1), 1)
	yield(get_tree(),"idle_frame")
	setSystem()
	$Label.bbcode_text = str("Current System:[b]", Agent.CurrentSystem)
	
	for c in $Actions.get_children():
		c.queue_free()

#change system lets you go to any system you have a ship in
#or and system that can be found using get jump gate (select if multiple) for the current system

func setSystem():
	var url = str("https://api.spacetraders.io/v2/systems/",Agent.CurrentSystem)
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	$HTTPRequest.request(url, header)

func fetchSysWay():
	var HTTP = HTTPRequest.new()
	HTTP.use_threads = true
	HTTP.connect("request_completed",self,"_on_WAYrequest_completed")
	self.add_child(HTTP)
	var url = str("https://api.spacetraders.io/v2/systems/",Agent.CurrentSystem,"/waypoints")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	HTTP.request(url, header)

func _on_WAYrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("systemWayFetch",cleanbody)
		Agent.systemData = cleanbody
