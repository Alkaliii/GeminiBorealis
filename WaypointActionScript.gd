extends Button

export var ws : String
export var ss : String
export (int,"Market","Shipyard","JumpGate","Orbital") var wpt
var close = false

var waiting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("shipyard",self,"setClosed")
	Agent.connect("visitmarket",self,"setClosed")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	API.connect("get_market_complete",self,"_on_request_completed")
	API.connect("get_shipyard_complete",self,"_on_request_completed")
	API.connect("get_jump_gate_complete",self,"_on_request_completed")
	API.connect("get_waypoint_complete",self,"_on_request_completed")

func setClosed(_1,_2,_3):
	match wpt:
		0:
			self.text = "Open Market"
			close = false
		1:
			self.text = "Open Shipyard"
			close = false

func _on_request_completed(cleanbody): #result, response_code, headers, body
#	var json = JSON.parse(body.get_string_from_utf8())
#	#print(json.result)
#	var cleanbody = json.result
	if !waiting: return
	waiting = false
	get_tree().call_group("loading","finishload")
	
	if cleanbody.has("data"):
		match wpt:
			0: #MARKET
				if !close:
					Agent.emit_signal("visitmarket",cleanbody,ws,ss)
					self.text = "Close Market"
					close = true
				elif close:
					self.text = "Open Market"
					Agent.emit_signal("closeShop",cleanbody)
					close = false
			1: #SHIPYARD
				if !close:
					Agent.emit_signal("shipyard",cleanbody,ws,ss)
					self.text = "Close Shipyard"
					close = true
				elif close:
					self.text = "Open Shipyard"
					Agent.emit_signal("closeShop",cleanbody)
					close = false
			2: #JUMP_GATE
				if !close:
					Agent.emit_signal("jumpgate")
			3: #ORBITAL
				Agent.emit_signal("chart",cleanbody)
#		setdat(cleanbody, true)
#	else:
#		getfail()
	

func setOrbital():
	self.rect_min_size = Vector2(100,0)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}/shipyard
func _on_ContractAccept_pressed():
#	var type
	if close:
		Agent.emit_signal("mapHOME")
		close = false
		return
	
	match wpt:
		0: API.get_market(self,ss,ws)#type = "/market"
		1: API.get_shipyard(self,ss,ws)#type = "/shipyard"
		2: 
			Agent.emit_signal("jumpgate")
			#API.get_jump_gate(self,ss,ws)#type = "/jump-gate"
		3: 
			for w in Agent.systemData["data"]:
				if w["symbol"] == ws:
					Agent.emit_signal("chart",{"data":w})
			#API.get_waypoint(self,ss,ws)#type = ""
	if wpt in [2,3]: return
	waiting = true
	get_tree().call_group("loading","startload")
#	var url = str("https://api.spacetraders.io/v2/systems/",ss,"/waypoints/",ws,type)
#	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
#	var header = ["Accept: application/json",headerstring,"Content-Type: application/json"]
#
#	$HTTPRequest.request(url, header)
	#$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST)
