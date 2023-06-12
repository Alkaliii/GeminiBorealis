extends Button

export var ws : String
export var ss : String
export (int,"Market","Shipyard","JumpGate","Orbital") var wpt

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var cleanbody = json.result
	if cleanbody.has("data"):
		match wpt:
			1:
				Agent.emit_signal("shipyard",cleanbody)
			3:
				Agent.emit_signal("chart",cleanbody)
#		setdat(cleanbody, true)
#	else:
#		getfail()
	

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
