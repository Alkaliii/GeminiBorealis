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

var printRID = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func outputRID(requestID : String):
	if printRID:
		print(requestID)
	else: return


#https://api.spacetraders.io/v2/
func get_status(node): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_status"
	req.API_ext = ""
	req.RID = str(node.name,"GET_STATUS",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_status_complete
func _on_get_status(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("status"):
		emit_signal("get_status_complete",PARSE)

#https://api.spacetraders.io/v2/my/agent
func get_agent(node): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_agent"
	req.API_ext = "my/agent"
	req.RID = str(node.name,"GET_AGENT",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_agent_complete
func _on_get_agent(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_agent_complete",PARSE)

#https://api.spacetraders.io/v2/my/contracts
func list_contracts(node, page = 1): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_list_contracts"
	req.API_ext = str("my/contracts?page=",page,"&limit=20")
	req.RID = str(node.name,"LIST_CONTRACTS",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal list_contracts_complete
func _on_list_contracts(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("list_contracts_complete",PARSE)

#https://api.spacetraders.io/v2/my/contracts/{contractId}
func get_contract(node,contractId : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_contract"
	req.API_ext = str("my/contracts/",contractId)
	req.RID = str(node.name,"GET_CONTRACT",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_contract_complete
func _on_get_contract(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_contract_complete",PARSE)

#https://api.spacetraders.io/v2/my/contracts/{contractId}/accept
func accept_contract(node,contractId : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_accept_contract"
	req.API_ext = str("my/contracts/",contractId,"/accept")
	req.RID = str(node.name,"ACCEPT_CONTRACT",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal accept_contract_complete
func _on_accept_contract(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("accept_contract_complete",PARSE)

#https://api.spacetraders.io/v2/my/contracts/{contractId}/deliver
func deliver_cargo(node,contractId : String,shipSymbol : String,tradeSymbol : String,units : int): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_deliver_cargo"
	req.API_ext = str("my/contracts/",contractId,"/deliver")
	req.data = {"shipSymbol":shipSymbol,"tradeSymbol":tradeSymbol,"units":units}
	req.RID = str(node.name,"DELIVER (",tradeSymbol,"x",units,") : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal deliver_cargo_complete
func _on_deliver_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("deliver_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/contracts/{contractId}/fulfill
func fulfill_contract(node,contractId : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_fulfill_contract"
	req.API_ext = str("my/contracts/",contractId,"/fulfill")
	req.RID = str(node.name,"FULFILL_CONTRACT",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal fulfill_contract_complete
func _on_fulfill_contract(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("fulfill_contract_complete",PARSE)

#https://api.spacetraders.io/v2/factions
func list_factions(node, page = 1): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_list_factions"
	req.API_ext = str("factions?page=",page,"&limit=20")
	req.RID = str(node.name,"LIST_FACTIONS",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal list_factions_complete
func _on_list_factions(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("list_factions_complete",PARSE)

#https://api.spacetraders.io/v2/factions/{factionSymbol}
func get_faction(node,factionSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_faction"
	req.API_ext = str("factions/",factionSymbol)
	req.RID = str(node.name,"GET_FACTION",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_faction_complete
func _on_get_faction(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_faction_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships
func list_ships(node, page = 1): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_list_ships"
	req.API_ext = str("my/ships?page=",page,"&limit=20")
	req.RID = str(node.name,"LIST_SHIPS",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal list_ships_complete
func _on_list_ships(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("list_ships_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships
func purchase_ship(node, shipType : String, waypointSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_purchase_ship"
	req.API_ext = "my/ships"
	req.data = {"shipType":shipType,"waypointSymbol":waypointSymbol}
	req.RID = str(node.name,"PURCHASE_SHIP ",shipType,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal purchase_ship_complete
func _on_purchase_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("purchase_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}
func get_ship(node, shipSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_ship"
	req.API_ext = str("my/ships/",shipSymbol)
	req.RID = str(node.name,"GET_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_ship_complete
func _on_get_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/cargo
func get_ship_cargo(node, shipSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_ship_cargo"
	req.API_ext = str("my/ships/",shipSymbol,"/cargo")
	req.RID = str(node.name,"GET_SHIP_CARGO"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_ship_cargo_complete
func _on_get_ship_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_ship_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/orbit
func orbit_ship(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_orbit_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/orbit")
	req.RID = str(node.name,"ORBIT_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal orbit_ship_complete
func _on_orbit_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("orbit_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/refine
func ship_refine(node, shipSymbol : String, produce : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_ship_refine"
	req.API_ext = str("my/ships/",shipSymbol,"/refine")
	req.data = {"produce":produce}
	req.RID = str(node.name,"SHIP_REFINE"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal ship_refine_complete
func _on_ship_refine(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("ship_refine_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/chart
func create_chart(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_create_chart"
	req.API_ext = str("my/ships/",shipSymbol,"/chart")
	req.RID = str(node.name,"CREATE_CHART"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal create_chart_complete
func _on_create_chart(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("create_chart_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/cooldown
func get_ship_cooldown(node, shipSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_ship_cooldown"
	req.API_ext = str("my/ships/",shipSymbol,"/cooldown")
	req.RID = str(node.name,"GET_SHIP_COOLDOWN"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_ship_cooldown_complete
func _on_get_ship_cooldown(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_ship_cooldown_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/dock
func dock_ship(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_dock_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/dock")
	req.RID = str(node.name,"DOCK_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal dock_ship_complete
func _on_dock_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("dock_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/survey
func create_survey(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_create_survey"
	req.API_ext = str("my/ships/",shipSymbol,"/survey")
	req.RID = str(node.name,"CREATE_SURVEY"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal create_survey_complete
func _on_create_survey(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("create_survey_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/extract
func extract_resources(node, shipSymbol : String, survey = null): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_extract_resources"
	req.API_ext = str("my/ships/",shipSymbol,"/extract")
	if survey != null: req.data = {"survey":survey}
	req.RID = str(node.name,"EXTRACT_RESOURCES"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal extract_resources_complete
func _on_extract_resources(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("extract_resources_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/jettison
func jettison_cargo(node, shipSymbol : String, symbol : String, units : int): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_jettison_cargo"
	req.API_ext = str("my/ships/",shipSymbol,"/jettison")
	req.data = {"symbol":symbol,"units":units}
	req.RID = str(node.name,"JETTISON (",symbol,"x",units,") : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal jettison_cargo_complete
func _on_jettison_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("jettison_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/jump
func jump_ship(node, shipSymbol : String, systemSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_jump_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/jump")
	req.data = {"systemSymbol":systemSymbol}
	req.RID = str(node.name,"JUMP_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal jump_ship_complete
func _on_jump_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("jump_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/navigate
func navigate_ship(node, shipSymbol : String, waypointSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_navigate_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/navigate")
	req.data = {"waypointSymbol":waypointSymbol}
	req.RID = str(node.name,"NAVIGATE_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal navigate_ship_complete
func _on_navigate_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("navigate_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/nav
func patch_ship_nav(node, shipSymbol : String, flightMode : String): #PATCH
	var req = _PATCH_REQUEST_OBj.duplicate()
	req.Callback = "_on_patch_ship_nav"
	req.API_ext = str("my/ships/",shipSymbol,"/nav")
	req.data = {"flightMode":flightMode}
	req.RID = str(node.name,"PATCH_SHIP_NAV"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal patch_ship_nav_complete
func _on_patch_ship_nav(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("patch_ship_nav_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/nav
func get_ship_nav(node, shipSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_ship_nav"
	req.API_ext = str("my/ships/",shipSymbol,"/nav")
	req.RID = str(node.name,"GET_SHIP_NAV"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_ship_nav_complete
func _on_get_ship_nav(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_ship_nav_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/warp
func warp_ship(node, shipSymbol : String, waypointSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_warp_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/warp")
	req.data = {"waypointSymbol":waypointSymbol}
	req.RID = str(node.name,"WARP_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal warp_ship_complete
func _on_warp_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("warp_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/sell
func sell_cargo(node, shipSymbol : String, symbol : String, units : int): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_sell_cargo"
	req.API_ext = str("my/ships/",shipSymbol,"/sell")
	req.data = {"symbol":symbol,"units":units}
	req.RID = str(node.name,"SELL (",symbol,"x",units,") : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal sell_cargo_complete
func _on_sell_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("sell_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/scan/systems
func scan_systems(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_scan_systems"
	req.API_ext = str("my/ships/",shipSymbol,"/scan/systems")
	req.RID = str(node.name,"SCAN_SYSTEMS"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal scan_systems_complete
func _on_scan_systems(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("scan_systems_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/scan/waypoints
func scan_waypoints(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_scan_waypoints"
	req.API_ext = str("my/ships/",shipSymbol,"/scan/waypoints")
	req.RID = str(node.name,"SCAN_WAYPOINTS"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal scan_waypoints_complete
func _on_scan_waypoints(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("scan_waypoints_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/scan/ships
func scan_ships(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_scan_ships"
	req.API_ext = str("my/ships/",shipSymbol,"/scan/ships")
	req.RID = str(node.name,"SCAN_SHIPS"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal scan_ships_complete
func _on_scan_ships(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("scan_ships_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/refuel
#TODO: Option to specify units
func refuel_ship(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_refuel_ship"
	req.API_ext = str("my/ships/",shipSymbol,"/refuel")
	req.RID = str(node.name,"REFUEL_SHIP"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal refuel_ship_complete
func _on_refuel_ship(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("refuel_ship_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/purchase
func purchase_cargo(node, shipSymbol : String, symbol : String, units : int): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_purchase_cargo"
	req.API_ext = str("my/ships/",shipSymbol,"/purchase")
	req.data = {"symbol":symbol,"units":units}
	req.RID = str(node.name,"PURCHASE (",symbol,"x",units,") : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal purchase_cargo_complete
func _on_purchase_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("purchase_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/transfer
func transfer_cargo(node, FROM_shipSymbol : String, tradeSymbol : String, units : int, TO_shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_transfer_cargo"
	req.API_ext = str("my/ships/",FROM_shipSymbol,"/transfer")
	req.data = {"tradeSymbol":tradeSymbol,"units":units,"shipSymbol":TO_shipSymbol}
	req.RID = str(node.name,"TRANSFER (",tradeSymbol,"x",units,") : ",FROM_shipSymbol,"->",TO_shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal transfer_cargo_complete
func _on_transfer_cargo(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("transfer_cargo_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/negotiate/contract
func negotiate_contract(node, shipSymbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_negotiate_contract"
	req.API_ext = str("my/ships/",shipSymbol,"/negotiate/contract")
	req.RID = str(node.name,"NEGOTIATE_CONTRACT"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal negotiate_contract_complete
func _on_negotiate_contract(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("negotiate_contract_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/mounts
func get_mounts(node, shipSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_mounts"
	req.API_ext = str("my/ships/",shipSymbol,"/mounts")
	req.RID = str(node.name,"GET_MOUNTS"," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_mounts_complete
func _on_get_mounts(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_mounts_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/mounts/install
func install_mount(node, shipSymbol : String, symbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_install_mount"
	req.API_ext = str("my/ships/",shipSymbol,"/mounts/install")
	req.data = {"symbol":symbol}
	req.RID = str(node.name,"INSTALL ",symbol," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal install_mount_complete
func _on_install_mount(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("install_mount_complete",PARSE)

#https://api.spacetraders.io/v2/my/ships/{shipSymbol}/mounts/remove
func remove_mount(node, shipSymbol : String, symbol : String): #POST
	var req = _POST_REQUEST_OBj.duplicate()
	req.Callback = "_on_remove_mount"
	req.API_ext = str("my/ships/",shipSymbol,"/mounts/remove")
	req.data = {"symbol":symbol}
	req.RID = str(node.name,"REMOVE ",symbol," : ",shipSymbol,Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal remove_mount_complete
func _on_remove_mount(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("remove_mount_complete",PARSE)

#https://api.spacetraders.io/v2/systems
func list_systems(node, page = 1): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_list_systems"
	req.API_ext = str("systems?page=",page,"&limit=20")
	req.RID = str(node.name,"LIST_SYSTEMS",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal list_systems_complete
func _on_list_systems(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("list_systems_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}
func get_system(node, systemSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_system"
	req.API_ext = str("systems/",systemSymbol)
	req.RID = str(node.name,"GET_SYSTEM",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_system_complete
func _on_get_system(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_system_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints
func list_waypoints_in_system(node, systemSymbol : String, page = 1): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_list_waypoints_in_system"
	req.API_ext = str("systems/",systemSymbol,"/waypoints?page=",page,"&limit=20")
	req.RID = str(node.name,"LIST_WAYPOINTS_IN_SYSTEM",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal list_waypoints_in_system_complete
func _on_list_waypoints_in_system(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("list_waypoints_in_system_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}
func get_waypoint(node, systemSymbol : String, waypointSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_waypoint"
	req.API_ext = str("systems/",systemSymbol,"/waypoints/",waypointSymbol)
	req.RID = str(node.name,"GET_WAYPOINT",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_waypoint_complete
func _on_get_waypoint(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_waypoint_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}/market
func get_market(node, systemSymbol : String, waypointSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_market"
	req.API_ext = str("systems/",systemSymbol,"/waypoints/",waypointSymbol,"/market")
	req.RID = str(node.name,"GET_MARKET",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_market_complete
func _on_get_market(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_market_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}/shipyard
func get_shipyard(node, systemSymbol : String, waypointSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_shipyard"
	req.API_ext = str("systems/",systemSymbol,"/waypoints/",waypointSymbol,"/shipyard")
	req.RID = str(node.name,"GET_SHIPYARD",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_shipyard_complete
func _on_get_shipyard(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_shipyard_complete",PARSE)

#https://api.spacetraders.io/v2/systems/{systemSymbol}/waypoints/{waypointSymbol}/jump-gate
func get_jump_gate(node, systemSymbol : String, waypointSymbol : String): #GET
	var req = _GET_REQUEST_OBj.duplicate()
	req.Callback = "_on_get_jump_gate"
	req.API_ext = str("systems/",systemSymbol,"/waypoints/",waypointSymbol,"/jump-gate")
	req.RID = str(node.name,"GET_JUMP_GATE",Time.get_unix_time_from_system())
	
	Automation.callQueue.push_back(req)
	outputRID(req.RID)

signal get_jump_gate_complete
func _on_get_jump_gate(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var PARSE = json.result
	if PARSE.has("data"):
		emit_signal("get_jump_gate_complete",PARSE)
