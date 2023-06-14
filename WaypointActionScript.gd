extends Button

export var ws : String
export var ss : String
export (int,"Market","Shipyard","JumpGate","Orbital") var wpt
var close = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("shipyard",self,"setClosed")
	Agent.connect("visitmarket",self,"setClosed")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func setClosed(_1,_2,_3):
	match wpt:
		0:
			self.text = "Open Market"
			close = false
		1:
			self.text = "Open Shipyard"
			close = false

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	#print(json.result)
	var cleanbody = json.result
	if cleanbody.has("data"):
		match wpt:
			0:
				if !close:
					Agent.emit_signal("visitmarket",cleanbody,ws,ss)
					self.text = "Close Market"
					close = true
				elif close:
					self.text = "Open Market"
					Agent.emit_signal("closeShop",cleanbody)
					close = false
			1:
				if !close:
					Agent.emit_signal("shipyard",cleanbody,ws,ss)
					self.text = "Close Shipyard"
					close = true
				elif close:
					self.text = "Open Shipyard"
					Agent.emit_signal("closeShop",cleanbody)
					close = false
			3:
				Agent.emit_signal("chart",cleanbody)
#		setdat(cleanbody, true)
#	else:
#		getfail()
	

func setOrbital():
	self.rect_min_size = Vector2(100,0)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}/shipyard
func _on_ContractAccept_pressed():
	var type
	match wpt:
		0: type = "/market"
		1: type = "/shipyard"
		2: type = "/jump-gate"
		3: type = ""
	var url = str("https://api.spacetraders.io/v2/systems/",ss,"/waypoints/",ws,type)
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Accept: application/json",headerstring,"Content-Type: application/json"]
	
	$HTTPRequest.request(url, header)
	#$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST)
