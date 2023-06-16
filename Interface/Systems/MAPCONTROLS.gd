extends Control

var location
var Primary
var Secondary
var SecondWayPoint
var Near

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/FocusMap.hide()
	$HBoxContainer/CalculateDistance.hide()
	Agent.connect("chart",self,"showFocus")
	Agent.connect("selectedWaypoint",self,"setSecondWPT")
	Agent.connect("mapSEL",self,"setCamNear")
	pass # Replace with function body.

func setCamNear(data):
	Near = data
	$VBoxContainer/CameraNear.bbcode_text = str("[right]",data)

func showFocus(data = null):
	location = data["data"]["symbol"]
	Primary = data
	$VBoxContainer/PreviousLocation.bbcode_text = str("[right][color=#949495]",location)
	$HBoxContainer/FocusMap.show()
	$HBoxContainer/CalculateDistance.show()

func setSecondWPT(data):
	SecondWayPoint = data
	
	for w in Agent.systemData["data"]:
		if w["symbol"] == SecondWayPoint:
			Secondary = w

func _on_FocusMap_pressed():
	#print("hi")
	Agent.emit_signal("mapHOME")
	$HBoxContainer/FocusMap.hide()

func _on_CalculateDistance_pressed():
	#Agent.queryWaypoint(Agent.CurrentSystem, "[b]SELECT LOCATION")
	#yield(Agent,"selectedWaypoint")
	
	for w in Agent.systemData["data"]:
		if w["symbol"] == Near:
			Secondary = w
	
	if SecondWayPoint == "CANCEL": return
	
	var one = Vector2(Primary["data"]["x"],Primary["data"]["y"])
	var two = Vector2(Secondary["x"],Secondary["y"])
	
	Agent.emit_signal("mapGenLine",one,two)
	
	print((one-two).length())
