extends Control

var SHIPDATA

# Called when the node enters the scene tree for the first time.
func _ready():
	Automation.connect("OperationChanged",self,"setCO")
	pass # Replace with function body.

func setdat(data):
	SHIPDATA = data
	$VBoxContainer/HBoxContainer/ShipName.bbcode_text = data["symbol"]
	$VBoxContainer/ShipType.bbcode_text = data["registration"]["role"]
	$VBoxContainer/CurrentOperation.bbcode_text = "[color=#949495]CO: [b][wave]..."

func setCO(data):
	if data["Ship"] != SHIPDATA["symbol"]: return
	$VBoxContainer/CurrentOperation.bbcode_text = str("[color=#949495]CO: [b]",data["Op"])

func _on_Button_pressed():
	for g in Save.groups: if Save.groups[g].has("Ships"):
		for s in Save.groups[g]["Ships"]: if s == SHIPDATA["symbol"]:
			Save.groups[g]["Ships"].erase(SHIPDATA["symbol"])
	
	self.queue_free()
