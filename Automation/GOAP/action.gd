extends Node

class_name goapACTION

var _action_name : String
var symbol : String
var officer : String
var officerOBj
var cost = 999

var printRID = false

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

func set_action_name(action_name):
	_action_name = action_name

func get_action_name():
	return _action_name

#Can the action be performed?
#Checked while planning and before performing
func is_valid() -> bool:
	return true
	#during perform false = abort plan?

#Important when multiple actions create the same effect
#Can vary dynamically by passing in important information (whiteboard)
func get_cost(_whiteboard) -> int:
	return cost

func set_cost(new):
	cost = new

#{"requirement": true}
func get_requirements() -> Dictionary:
	return {}

#{"effect": true}
func get_effects() -> Dictionary:
	return {}

#One nodes requirment can be anothers effect, the only difference is what it is to said node

func execute(_required_data, _delta) -> bool:
	return false
	#return true on complete

func outputRID(requestID : String):
	if printRID:
		print(requestID)
	else: return
