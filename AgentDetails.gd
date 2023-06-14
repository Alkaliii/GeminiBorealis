extends Node

export var AID : String
export var AgentCredits : String
export var Headquaters : String
export var CurrentSystem : String
export var AgentFaction : String
export var AgentSymbol : String
export var USERTOKEN : String

export var _FleetData : Dictionary
export var interfaceShip : String

signal login
signal chart(cleanbody)
signal shipyard(cleanbody)
signal visitmarket(cleanbody)
signal closeShop
signal fleetUpdated
signal AcceptContract
signal PurchaseShip
signal PurchaseCargo
signal SellCargo

signal query_Ship(shipArr)
signal interfaceShipSet
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cleanHQ():
	var delete = true
	var HQ = Headquaters
	while delete:
		if HQ[(HQ.length()-1)] == "-":
			HQ.erase(HQ.length()-1, 1)
			delete = false
			break
		else: HQ.erase(HQ.length()-1, 1)
	CurrentSystem = HQ

func clear():
	AID = ""
	AgentCredits = ""
	Headquaters = ""
	CurrentSystem = ""
	AgentFaction = ""
	AgentSymbol = ""
	USERTOKEN = ""

func queryUser_Ship(waypoint = null):
	var Ships : Array
	if waypoint == null:
		for s in _FleetData["data"]:
			Ships.push_back(s)
	else:
		for s in _FleetData["data"]:
			if s["nav"]["waypointSymbol"] == waypoint and s["nav"]["status"] != "IN_TRANSIT":
				Ships.push_back(s)
	if Ships.size() == 1:
		setInterfaceShip(Ships[0]["symbol"])
		return
	emit_signal("query_Ship", Ships)

func setInterfaceShip(symbol):
	interfaceShip = symbol
	print(symbol)
	emit_signal("interfaceShipSet")

func acceptContract(CID, node):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", node, "_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/my/contracts/",CID,"/accept")
	var headerstring = str("Authorization: Bearer ", USERTOKEN)
	var header = ["Accept: application/json",headerstring,"Content-Type: application/json","Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

#https://api.spacetraders.io/v2/my/ships
func purchaseShip(ShipType, Waypoint, node):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", node, "_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships")
	var headerstring = str("Authorization: Bearer ", USERTOKEN)
	var data = JSON.print({"shipType": ShipType, "waypointSymbol": Waypoint})
	var header = ["Content-Type: application/json",headerstring]
	print(ShipType,Waypoint)
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/purchase
func purchaseCargo(Good, Amt, node):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", node, "_on_BUYrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",interfaceShip,"/purchase")
	var headerstring = str("Authorization: Bearer ", USERTOKEN)
	var data = JSON.print({"symbol": Good, "units": Amt})
	var header = ["Content-Type: application/json",headerstring]
	print(Good,Amt)
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/sell
func sellCargo(Good, Amt, node):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", node, "_on_SELLrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",interfaceShip,"/sell")
	var headerstring = str("Authorization: Bearer ", USERTOKEN)
	var data = JSON.print({"symbol": Good, "units": Amt})
	var header = ["Content-Type: application/json",headerstring]
	print(Good,Amt)
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	yield(HTTP,"request_completed")
	HTTP.queue_free()
