extends Control

var ShipDat


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data):
	ShipDat = data
	var Name = $VBoxContainer/ShipName
	var Inspect = $VBoxContainer/ButtonStatus/Button
	var Status = $VBoxContainer/ButtonStatus/ShipStatusBadge
	var Waypoint = $VBoxContainer/ShipWaypoint
	
	var SHID = data["symbol"]
	var FUEL = str(" FUEL:",round(float(data["fuel"]["current"])/float(data["fuel"]["capacity"]+0.001)*100.0),"%")
	if data["reactor"]["symbol"] == "REACTOR_SOLAR_I": FUEL = " SOLAR"
	
	Name.bbcode_text = str("[b]",SHID,"[/b][color=#949495]",FUEL)
	Inspect.text = str(data["registration"]["role"])
	Status.sns = data["nav"]["status"]
	Status.setdat()
	Waypoint.bbcode_text = str("[right][color=#949495][b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
