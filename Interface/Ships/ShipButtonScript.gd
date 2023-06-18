extends Control

var ShipDat
var cooldownTime = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("fleetUpdated",self,"refreshSelf")
	Agent.connect("cooldownStarted",self,"setCooldown")
	pass # Replace with function body.

func _process(delta):
	if cooldownTime != null:
		var present = Time.get_unix_time_from_system()
		var difference = cooldownTime - present
		$VBoxContainer/ButtonStatus/Button.text = str(ShipDat["registration"]["role"]," (",difference,")")
		
		if cooldownTime < present:
			cooldownTime = null
			$VBoxContainer/ButtonStatus/Button.text = str(ShipDat["registration"]["role"])
			OS.request_attention()

func setCooldown(cTime, sym):
	if sym != ShipDat["symbol"]: return
	cooldownTime = Time.get_unix_time_from_datetime_string(cTime)
	if Time.get_unix_time_from_datetime_string(cTime) > Time.get_unix_time_from_system():
		Agent.cooldowns[ShipDat["symbol"]] = cooldownTime

func refreshSelf():
	if ShipDat == null: return
	if Agent.focusShip == ShipDat["symbol"]:
		_on_Button_pressed()

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
	
	if data["nav"]["status"] == "IN_TRANSIT":
		Agent.emit_signal("mapGenLine",
		Vector2(data["nav"]["route"]["departure"]["x"],data["nav"]["route"]["departure"]["y"]),
		Vector2(data["nav"]["route"]["destination"]["x"],data["nav"]["route"]["destination"]["y"]), Color(1,1,0,0.5), true, data["nav"]["route"]["arrival"])
	
	Waypoint.bbcode_text = str("[right][color=#949495][b]",data["nav"]["route"]["destination"]["type"],"[/b] ",data["nav"]["route"]["destination"]["symbol"])
	
	if Agent.cooldowns.has(data["symbol"]):
		cooldownTime = Agent.cooldowns[data["symbol"]]

func refresh():
	Agent.call_deferred("emit_signal","shipfocused",ShipDat)
	#Agent.emit_signal("shipfocused",ShipDat)

func _on_Button_pressed():
	Agent.emit_signal("shipfocused",ShipDat)
	Agent.focusShip = ShipDat["symbol"]
