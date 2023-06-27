extends Button

export var symbol : String
export var type : String
#export var trait : String
export var xpos : int
export var ypos : int


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func setXY(string):
	$"300line".bbcode_text = string

func setIcon(new):
	if new == null: return
	match new:
		"SHIPYARD":
			icon = preload("res://Interface/Systems/Icons/SHIPYARDWaypointButtonIcon.png")
		"MARKETPLACE":
			icon = preload("res://Interface/Systems/Icons/MARKETWaypointButtonIcon.tres")

#func _on_request_completed(result, response_code, headers, body):
#	var json = JSON.parse(body.get_string_from_utf8())
#	var cleanbody = json.result
#	if cleanbody.has("data"):
#		Agent.emit_signal("chart",cleanbody)
##	else:
##		getfail()
#	print(json.result)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}
func _on_WaypointButton_pressed():
	for w in Agent.systemData["data"]:
		if w["symbol"] == symbol:
			Agent.emit_signal("chart",{"data":w})
#	var url = str("https://api.spacetraders.io/v2/systems/",Agent.CurrentSystem,"/waypoints/",symbol)
#	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
#	var header = [headerstring]
#	$HTTPRequest.request(url, header)
