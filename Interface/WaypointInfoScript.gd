extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("login",self,"hide")
	Agent.connect("mapHOME",self,"hide")

func setdat(data):
	var Title = $HBoxContainer/Title
	var Badge = $HBoxContainer/WaypointBadge
	var Traits = $Traits
	var Desc = $Description
	var Dets = $Details
	
	Badge.wpt = data["data"]["type"]
	Badge.setdat()
	Title.bbcode_text = str(data["data"]["symbol"])
	var traittext : Array
	for t in data["data"]["traits"]:
		var col = ""
		var colend = ""
		var sym = t["symbol"]
		match t["symbol"]:
			"MARKETPLACE": 
				col = "[color=#FFBF00]"
				colend = "[/color]"
			"SHIPYARD": 
				col = "[color=#c026d3][wave]"
				colend = "[/wave][/color]"
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
	Traits.bbcode_text = str("[color=#71797E]",traittext)
	var descRNG = RandomNumberGenerator.new()
	descRNG.randomize()
	var gNum = descRNG.randi_range(0,data["data"]["traits"].size() - 1)
	if data["data"]["traits"].size() != 0:
		Desc.bbcode_text = data["data"]["traits"][gNum]["description"]
	elif data["data"]["type"] == "JUMP_GATE": Desc.bbcode_text = "The gateway to the universe."
	else: Desc.bbcode_text = "no description avalible"
	var submit = data["data"]["chart"]["submittedBy"]
	if submit == Agent.AgentFaction: submit = str("[wave]",Agent.AgentFaction,"[/wave]")
	Dets.bbcode_text = str("[color=#71797E][right][b]Submitted by ",submit,"[/b] ",data["data"]["chart"]["submittedOn"])
