extends VBoxContainer

const shipline = preload("res://Interface/Ships/ShipButton.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("login", self, "show")
	Agent.connect("requestFleetUpdate",self,"show")
	Agent.connect("PurchaseCargo",self,"show")
	Agent.connect("JettisonCargo",self,"show")
	Agent.connect("TransferCargo",self,"show")
	Agent.connect("SellCargo",self,"show")
	Agent.connect("NavigationFinished",self,"show")
	Agent.connect("DockFinished",self,"show")
	Agent.connect("OrbitFinished",self,"show")
	Agent.connect("RefuelFinished",self,"show")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	API.connect("list_ships_complete",self,"_on_request_completed")

func _on_request_completed(cleanbody): #result, response_code, headers, body
#	var json = JSON.parse(body.get_string_from_utf8())
#	var cleanbody = json.result
	if cleanbody.has("data"):
		setdat(cleanbody)
		Agent._FleetData = cleanbody
		Agent.emit_signal("fleetUpdated")
		Automation.emit_signal("LISTSHIPS",cleanbody)
		
		#need some lines for handling an agent with more than 20 ships
		
#	else:
#		Agent.dispError(cleanbody)
##		getfail()
#		print(json.result)

func show(arg = null):
	self.modulate = Color(1,1,1,0)
	self.visible = true
	var twee = get_tree().create_tween()
	twee.tween_property(self, "modulate", Color(1,1,1,1), 1)
	yield(get_tree(),"idle_frame")
	
	if arg != null:
		#sellCargo and purchaseCargo returns cacheable data
		if arg.has("data") and arg["data"].has("transaction"):
			for ship in Agent._FleetData["data"]:
				if ship["symbol"] == arg["data"]["transaction"]["shipSymbol"]:
					if arg["data"].has("cargo"): 
						ship["cargo"] = arg["data"]["cargo"]
						print("dataCached[s/pCargo]",arg["data"]["transaction"]) #arg["data"]["transaction"]
					if arg["data"].has("fuel"):
						ship["fuel"] = arg["data"]["fuel"]
						print("dataCached[rFuel]",arg["data"]["transaction"])
					Agent.emit_signal("fleetUpdated")
		#transferCargo and jettisonCargo returns cacheable data
		elif arg.has("data") and arg["data"].has("cargo"):
			for ship in Agent._FleetData["data"]:
				if ship["symbol"] == Agent.focusShip:
					ship["cargo"] = arg["data"]["cargo"]
					print("dataCached[t/jCargo]")
					Agent.emit_signal("fleetUpdated")
		else:
			setShips()
	else:
		setShips()
	
	$Label.bbcode_text = str("[b]", Agent.AgentSymbol,"[/b]'s Fleet")
	
	for c in $Actions.get_children():
		c.queue_free()

func setdat(data):
	for r in $ScrollContainer/HBoxContainer.get_children():
		r.queue_free()
	
	for s in data["data"]:
		var ship = shipline.instance()
		ship.setdat(s)
		$ScrollContainer/HBoxContainer.add_child(ship)

func setShips():
	API.list_ships(self)
#	var url = str("https://api.spacetraders.io/v2/my/ships?limit=20")
#	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
#	var header = ["Accept: application/json",headerstring]
#	$HTTPRequest.request(url, header)
