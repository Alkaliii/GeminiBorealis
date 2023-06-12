extends VBoxContainer

const waypoint = preload("res://WaypointButton.tscn")
const wayaction = preload("res://WaypointFunctionButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	$WaypointInfo.hide()
	Agent.connect("login", self, "show")
	Agent.connect("chart", self, "setWaypointDat")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		setdat(cleanbody)
#	else:
#		getfail()
	print(json.result)

func setWaypointDat(data):
	var twee = get_tree().create_tween()
	$WaypointInfo.modulate = Color(1,1,1,0)
	$WaypointInfo.show()
	twee.tween_property($WaypointInfo, "modulate", Color(1,1,1,1), 1)
	
	for c in $WaypointInfo/Actions.get_children():
		c.queue_free()
	
	if data["data"]["orbitals"].size() != 0:
		for o in data["data"]["orbitals"]:
			var orbital = wayaction.instance()
			orbital.text = str("Visit Orbital ",o["symbol"])
			orbital.wpt = 3
			orbital.ss = data["data"]["systemSymbol"]
			orbital.ws = o["symbol"]
			$WaypointInfo/Actions.add_child(orbital)
	
	$WaypointInfo/Title.bbcode_text = str("[b]",data["data"]["type"],"[/b] ", data["data"]["symbol"])
	var traittext : Array
	for t in data["data"]["traits"]:
		var col = ""
		var colend = ""
		var sym = t["symbol"]
		match t["symbol"]:
			"MARKETPLACE": 
				col = "[color=#FFBF00]"
				colend = "[/color]"
				var marketplace = wayaction.instance()
				marketplace.text = "Visit Marketplace"
				marketplace.wpt = 0
				marketplace.ss = data["data"]["systemSymbol"]
				marketplace.ws = data["data"]["symbol"]
				$WaypointInfo/Actions.add_child(marketplace)
			"SHIPYARD": 
				col = "[color=#DA70D6][wave]"
				colend = "[/wave][/color]"
				var shipyard = wayaction.instance()
				shipyard.text = "Visit Shipyard"
				shipyard.wpt = 1
				shipyard.ss = data["data"]["systemSymbol"]
				shipyard.ws = data["data"]["symbol"]
				$WaypointInfo/Actions.add_child(shipyard)
			"OUTPOST": 
				col = "[color=#FFBF00]"
				colend = "[/color]"
			"TRADING_HUB": 
				col = "[color=#FFBF00]"
				colend = "[/color]"
			"PRECIOUS_METAL_DEPOSITS":
				col = "[color=#FFFFFF][wave]"
				colend = "[/wave][/color]"
			"RARE_METAL_DEPOSITS":
				col = "[color=#FFFFFF][wave]"
				colend = "[/wave][/color]"
			"COMMON_METAL_DEPOSITS":
				sym = "COM.MET_DEPOSITS"
		traittext.push_back(str("[b]",col,sym,colend,"[/b][color=#71797E]"))
	$WaypointInfo/Traits.bbcode_text = str("[color=#71797E]",traittext)
	var descRNG = RandomNumberGenerator.new()
	descRNG.randomize()
	var gNum = descRNG.randi_range(0,data["data"]["traits"].size() - 1)
	if data["data"]["traits"].size() != 0:
		$WaypointInfo/Description.bbcode_text = data["data"]["traits"][gNum]["description"]
	else: $WaypointInfo/Description.bbcode_text = "no description avalible"
	var submit = data["data"]["chart"]["submittedBy"]
	if submit == Agent.AgentFaction: submit = str("[wave]",Agent.AgentFaction,"[/wave]")
	$WaypointInfo/Details.bbcode_text = str("[color=#71797E][right][b]Submitted by ",submit,"[/b] ",data["data"]["chart"]["submittedOn"])

func setdat(data):
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

func setSystem():
	var url = str("https://api.spacetraders.io/v2/systems/",Agent.CurrentSystem)
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	$HTTPRequest.request(url, header)
