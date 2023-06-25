extends Node

export (Dictionary) var _POST_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_request_completed",
	"API_ext": "my/agent", #After "v2" in https://api.spacetraders.io/v2
	"data": null, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
	"RID": null, #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
	"TYPE": "POST"
}
export (Dictionary) var _GET_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_request_completed",
	"API_ext": "my/agent",
	"RID": null,
	"TYPE": "GET"
}
export (Dictionary) var _PATCH_REQUEST_OBj = {
	"Author": self,
	"Callback": "_on_request_completed",
	"API_ext": "my/agent",
	"data": null,
	"RID": null,
	"TYPE": "PATCH"
}

export var laxRateTime = 2
export var executiveRateTime = 1.2
export var aggressiveRateTime = 1.05

export (int, "lax", "executive", "aggressive") var SelectRateTime setget _setRate

var RateTime = executiveRateTime
var cooldown = 0.0

var callQueue : Array #add call requests here
var progressQueue : Dictionary #add in progress requests here, failed requests are added back into call

var active = false

var _FleetData : Dictionary
var _SystemsData : Dictionary
var _MarketData : Dictionary

signal OperationChanged
signal PushAPI

signal LISTSHIPS
signal GETSYSTEM
signal LISTSYSTEMWAYPOINTS
signal EXTRACTRESOURCES
signal GETMARKET

var Current_Request = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	#Agent.connect("login",self,"activateAu")
	self.connect("LISTSHIPS",self,"cacheSHIPS")
	self.connect("GETSYSTEM",self,"cacheSYSTEM")
	self.connect("LISTSYSTEMWAYPOINTS",self,"cacheSYSTEMWPT")
	self.connect("EXTRACTRESOURCES",self,"cacheEXTRACT")
	self.connect("GETMARKET",self,"cacheMARKET")
	
	Agent.connect("DockFinished",self,"cacheSHIPstatus")
	Agent.connect("OrbitFinished",self,"cacheSHIPstatus")
	Agent.connect("JettisonCargo",self,"cacheJETTISON")
	Agent.connect("PurchaseCargo",self,"cachePURCHASE")
	Agent.connect("SellCargo",self,"cacheSELL")
	Agent.connect("visitmarket",self,"cacheMARKET")
	
	_setRate(SelectRateTime)
#	for i in 25:
#		var r = _GET_REQUEST_OBj
#		r.Author = self
#		r.Callback = null
#		r.API_ext = ""
#		r.RID = str("TEST",i)
#		callQueue.push_back(r)

func activateAu():
	yield(get_tree().create_timer(10),"timeout")
	active = true
	print("AUTORUNNING",RateTime)
	var routine = AutoExtractRoutine.new()
	
	yield(Automation,"EXTRACTRESOURCES")
	for w in _FleetData:
		routine.groupData[_FleetData[w]["symbol"]] = _FleetData[w]
		break
	self.add_child(routine)
	routine.startRoutine()

func setRoutine(data):
	match data["state"]:
		"Stop":
			for c in self.get_children():
				if c.assigned_Group == data["group"]:
					c.endRoutine()
			return
	
	var routine
	match data["routine"]:
		"Auto-Extract":
			routine = AutoExtractRoutine.new()
		"Purge Cargo": pass
	
	routine.assigned_Group = data["group"]
	routine.groupData = Save.groups[data["group"]]["Ships"]
	self.add_child(routine)
	routine.startRoutine()

func _setRate(new):
	SelectRateTime = new
	match new:
		0: RateTime = laxRateTime
		1: RateTime = executiveRateTime
		2: RateTime = aggressiveRateTime

func _process(delta):
	cooldown += delta
	if cooldown >=  RateTime and active:
		pushAPI()
		emit_signal("PushAPI")
	if callQueue.size() > 0:
		active = true
	cleanProgressQ()

func cleanProgressQ():
	if progressQueue.size() > 0:
		for req in progressQueue:
			if progressQueue[req]["RCT"] < (Time.get_unix_time_from_system()-10):
				progressQueue.erase(req)

func pushAPI():
	cooldown = 0
	processQueue()
	yield(get_tree().create_timer(0.2),"timeout")
	processQueue()
	yield(get_tree().create_timer(0.2),"timeout")
	processQueue()

func processQueue(idx = 0):
	if callQueue.size() >= (idx+1):
		var r = callQueue.pop_front()
		match r["TYPE"]:
			"POST": executePOST(r)
			"GET": executeGET(r)
			"PATCH": executePATCH(r)
		Current_Request = r.RID
	else: 
		print("empty")
		active = false

func executePOST(request):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	if request["Callback"] != null:
		HTTP.connect("request_completed", request["Author"], request["Callback"])
	HTTP.connect("request_completed", self,"_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/", request["API_ext"])
	var header = ["Accept: application/json",str("Authorization: Bearer ", Agent.USERTOKEN),"Content-Type: application/json"]
	if request["data"] == null:
		header.push_back("Content-Length: 0")
		HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	else:
		HTTP.request(url, header, true, HTTPClient.METHOD_POST,JSON.print(request["data"]))
	yield(HTTP,"request_completed")
	HTTP.queue_free()
	request["RCT"] = Time.get_unix_time_from_system()
	progressQueue[request["RID"]] = request

func executePATCH(request):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	if request["Callback"] != null:
		HTTP.connect("request_completed", request["Author"], request["Callback"])
	HTTP.connect("request_completed", self,"_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/", request["API_ext"])
	var header = ["Accept: application/json",str("Authorization: Bearer ", Agent.USERTOKEN),"Content-Type: application/json"]
	if request["data"] == null:
		header.push_back("Content-Length: 0")
		HTTP.request(url, header, true, HTTPClient.METHOD_PATCH)
	else:
		HTTP.request(url, header, true, HTTPClient.METHOD_PATCH,JSON.print(request["data"]))
	yield(HTTP,"request_completed")
	HTTP.queue_free()
	request["RCT"] = Time.get_unix_time_from_system()
	progressQueue[request["RID"]] = request

func executeGET(request):
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	if request["Callback"] != null:
		HTTP.connect("request_completed", request["Author"], request["Callback"])
	HTTP.connect("request_completed", self,"_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/", request["API_ext"])
	var header = ["Accept: application/json",str("Authorization: Bearer ", Agent.USERTOKEN),"Content-Type: application/json"]
	HTTP.request(url, header)
	yield(HTTP,"request_completed")
	HTTP.queue_free()
	request["RCT"] = Time.get_unix_time_from_system()
	progressQueue[request["RID"]] = request

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody is Dictionary and cleanbody.has("error"):
		Agent.dispError(cleanbody)
		for req in progressQueue:
			callQueue.push_back(progressQueue[req])
			progressQueue.erase(req)
	else:
		progressQueue.erase(Current_Request)

func cacheSHIPS(data):
	for ship in data["data"]:
		_FleetData[ship["symbol"]] = ship

func cacheSYSTEM(data):
	var edata = data.duplicate(true)
	_SystemsData[edata["data"]["symbol"]] = edata["data"]
	if edata["data"]["waypoints"] is Array:
		var temp : Dictionary
		for wpt in edata["data"]["waypoints"]:
			temp[wpt["symbol"]] = wpt
		_SystemsData[edata["data"]["symbol"]]["waypoints"] = temp 

func cacheSYSTEMWPT(data):
	var edata = data.duplicate(true)
	for waypoint in edata["data"]:
		_SystemsData[waypoint["systemSymbol"]]["waypoints"][waypoint["symbol"]] = waypoint

func cacheEXTRACT(data):
	_FleetData[data["data"]["extraction"]["shipSymbol"]]["cargo"] = data["data"]["cargo"]

func cacheJETTISON(data):
	_FleetData[data["meta"]]["cargo"] = data["data"]["cargo"]

func cachePURCHASE(data):
	_FleetData[data["data"]["transaction"]["shipSymbol"]]["cargo"] = data["data"]["cargo"]

func cacheSELL(data):
	_FleetData[data["data"]["transaction"]["shipSymbol"]]["cargo"] = data["data"]["cargo"]
	
	if Agent.sellgood.has(data["data"]["transaction"]["tradeSymbol"]):
		var TotalSold = Agent.sellgood[data["data"]["transaction"]["tradeSymbol"]]["TotalSold"]
		var NewTotalSold = TotalSold[TotalSold.size()-1].values()[0] + data["data"]["transaction"]["units"]
		TotalSold.push_back({str(Time.get_unix_time_from_system()):NewTotalSold})
		
		var TotalRevenue = Agent.sellgood[data["data"]["transaction"]["tradeSymbol"]]["TotalRevenue"]
		var NewTotalRevenue = TotalRevenue[TotalRevenue.size()-1].values()[0] + data["data"]["transaction"]["totalPrice"]
		TotalRevenue.push_back({str(Time.get_unix_time_from_system()):NewTotalRevenue})
	else:
		var FirstTotalSold = {str(Time.get_unix_time_from_system()):data["data"]["transaction"]["units"]}
		var FirstTotalRevenue = {str(Time.get_unix_time_from_system()):data["data"]["transaction"]["totalPrice"]}
		Agent.sellgood[data["data"]["transaction"]["tradeSymbol"]] = {
			"symbol": data["data"]["transaction"]["tradeSymbol"],
			"TotalSold": [FirstTotalSold],
			"TotalRevenue": [FirstTotalRevenue]
		}
	
	if Agent.sellship.has(data["data"]["transaction"]["shipSymbol"]):
		var TotalRevenue = Agent.sellship[data["data"]["transaction"]["shipSymbol"]]["TotalRevenue"]
		var NewTotalRevenue = TotalRevenue[TotalRevenue.size()-1].values()[0] + data["data"]["transaction"]["totalPrice"]
		TotalRevenue.push_back({str(Time.get_unix_time_from_system()):NewTotalRevenue})
	else:
		var FirstTotalRevenue = {str(Time.get_unix_time_from_system()):data["data"]["transaction"]["totalPrice"]}
		Agent.sellship[data["data"]["transaction"]["shipSymbol"]] = {
			"shipSymbol": data["data"]["transaction"]["shipSymbol"],
			"TotalRevenue": [FirstTotalRevenue]
		}

func cacheSHIPstatus(data):
	_FleetData[data["meta"]]["nav"] = data["data"]["nav"]

func cacheMARKET(data,ws = null,ss = null,_4 = null):
	_MarketData[data["data"]["symbol"]] = data["data"]
