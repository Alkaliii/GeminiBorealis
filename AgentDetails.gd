extends Node

export var AID : String
export var AgentCredits : String
export var Headquaters : String
export var CurrentSystem : String
export var AgentFaction : String
export var AgentSymbol : String
export var USERTOKEN : String

var systemData
var surveys : Dictionary = {}
var cooldowns : Dictionary

export var _FleetData : Dictionary
export var interfaceShip : String
export var focusShip : String

var menu

signal login
signal systemFetch(cleanbody)
signal systemWayFetch(cleanbody)
signal chart(cleanbody)
signal shipyard(cleanbody)
signal visitmarket(cleanbody)
signal closeShop
signal fleetUpdated
signal requestFleetUpdate
signal AcceptContract
signal PurchaseShip
signal PurchaseCargo
signal SellCargo
signal JettisonCargo

signal showFMAPbut

signal mapHOME
signal mapSEL(sym)
signal mapGenLine(one,two)

#SHIP ACTIONS
signal cooldownStarted
signal NavigationFinished
signal FocusMapNav
signal DockFinished
signal OrbitFinished
signal RefuelFinished

var QueryPrompt = null
signal query_Ship(shipArr)
signal interfaceShipSet

signal query_Waypoint(waypointArr)
signal selectedWaypoint(waypointSym)

signal query_Survey(symbol)
signal selectedSurvey(signature)

signal query_Group
signal selectedGroup(key)

signal query_Routine(GROUP)
signal selectedRoutine(data)

signal shipfocused(data)

signal error2disp(inst)
const error = preload("res://Interface/ErrorPanel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func dispError(data):
	var disp = error.instance()
	disp.setdat(data)
	emit_signal("error2disp",disp)

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

func queryWaypoint(system, prompt = null):
	QueryPrompt = null
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_SYSrequest_completed")
	var url = str("https://api.spacetraders.io/v2/systems/",system)
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	HTTP.request(url, header)
	
	if prompt != null:
		QueryPrompt = prompt

func _on_SYSrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		emit_signal("query_Waypoint",cleanbody,QueryPrompt)
	else:
		dispError(cleanbody)
#		getfail()
	print(json.result)

func setInterfaceShip(symbol):
	interfaceShip = symbol
	#print(symbol)
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

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/jettison
func jettisonCargo(Good, Amt, node):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", node, "_on_JETrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",focusShip,"/jettison")
	var headerstring = str("Authorization: Bearer ", USERTOKEN)
	var data = JSON.print({"symbol": Good, "units": Amt})
	var header = ["Content-Type: application/json",headerstring]
	print(Good,Amt)
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST, data)
	yield(HTTP,"request_completed")
	HTTP.queue_free()
