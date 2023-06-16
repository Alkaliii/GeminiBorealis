extends Node


signal agentFetched
const shipQuery = preload("res://Interface/Ships/SelectShipPopUp.tscn")
const waypointQuery = preload("res://Interface/Systems/SelectWaypointPopUp.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	OS.window_size.x = 1280
	OS.window_size.y = 600
	OS.set_window_position(OS.get_screen_position(OS.get_current_screen()) + OS.get_screen_size()*0.5 - OS.get_window_size()*0.5)
	
	$Back/ViewportContainer/Viewport.handle_input_locally = true
	
	$CanvasLayer.show()
	Agent.connect("login", self, "setStatus")
	Agent.connect("login", self, "_on_Systems_pressed")
	Agent.connect("login", self, "resetWindow")
	Agent.connect("chart", self, "showPanel")
	Agent.connect("mapHOME",self,"hidePanel")
	Agent.connect("AcceptContract", self, "updateStatus")
	Agent.connect("PurchaseShip",self,"updateStatus")
	Agent.connect("PurchaseShip",self,"_on_Ships_pressed")
	Agent.connect("PurchaseCargo",self,"updateStatus")
	
	Agent.connect("query_Ship",self,"queryShip")
	Agent.connect("query_Waypoint",self,"queryWaypoint")

func queryShip(Arr):
	var query = shipQuery.instance()
	query.setdat(Arr)
	$CanvasLayer.add_child(query)

func queryWaypoint(data, prompt = null):
	var query = waypointQuery.instance()
	query.setdat(data, prompt)
	$CanvasLayer.add_child(query)

func setStatus():
	#$Back/ViewportContainer/Viewport.handle_input_locally = true
	var details = $StatusBack/Details
	details.bbcode_text = str("[right][b][USER]:[/b] ",Agent.AgentSymbol," [color=#69696b]([b]",Agent.AgentFaction,"[/b])[/color]"," | [b][CREDITS]:[/b] ",Agent.AgentCredits)

func updateStatus():
	fetchAgent()
	yield(self,"agentFetched")
	var details = $StatusBack/Details
	details.bbcode_text = str("[right][b][USER]:[/b] ",Agent.AgentSymbol," [color=#69696b]([b]",Agent.AgentFaction,"[/b])[/color]"," | [b][CREDITS]:[/b] ",Agent.AgentCredits)

func resetWindow():
	$MainWindow.rect_position = Vector2(0,0)

func fetchAgent():
	var HTTP = HTTPRequest.new()
#	HTTP = HTTP.instance()
	self.add_child(HTTP)
	yield(get_tree(),"idle_frame")
	
	var url = "https://api.spacetraders.io/v2/my/agent"
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	HTTP.connect("request_completed", self, "_on_fetchAgentrequest_completed")
	HTTP.request(url, header)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_fetchAgentrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.AID = cleanbody["data"]["accountId"]
		Agent.AgentCredits = cleanbody["data"]["credits"]
		Agent.Headquaters = cleanbody["data"]["headquarters"]
		Agent.AgentFaction = cleanbody["data"]["startingFaction"]
		Agent.AgentSymbol = cleanbody["data"]["symbol"]
		Agent.cleanHQ()
		emit_signal("agentFetched")
	else:
		getfail()
	print(json.result)

func getfail():
	pass

func showPanel(data):
	#$Back/Panel.modulate = Color(1,1,1,0)
	$Back/Panel.show()
	var twee = get_tree().create_tween()
	twee.tween_property($Back/Panel,"modulate",Color(1,1,1,1),1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	yield(twee,"finished")

func hidePanel():
	var twee = get_tree().create_tween()
	twee.tween_property($Back/Panel,"modulate",Color(1,1,1,0),1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	yield(twee,"finished")
	$Back/Panel.hide()

func _on_Button_pressed():
	logout()

func logout():
	Agent.clear()
	var login = preload("res://Interface/Systems/LoginScreen.tscn")
	login.instance()
	$CanvasLayer.add_child(login.instance())


func _on_Agent_pressed():
	var Window = $MainWindow
	var SysArt = $Back/SystemArt
	var twee = get_tree().create_tween()
	twee.tween_property(Window, "rect_position", Vector2(-2560,0), 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	twee.parallel().tween_property(SysArt, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Systems, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Ships, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Agent, "modulate", Color(1,1,1,1),0.5)


func _on_Systems_pressed():
	var Window = $MainWindow
	var SysArt = $Back/SystemArt
	var twee = get_tree().create_tween()
	twee.tween_property(Window, "rect_position", Vector2(0,0), 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	twee.parallel().tween_property(SysArt, "modulate", Color(1,1,1,1),0.5)
	twee.parallel().tween_property($MainWindow/Systems, "modulate", Color(1,1,1,1),0.5)
	twee.parallel().tween_property($MainWindow/Ships, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Agent, "modulate", Color(1,1,1,0),0.5)


func _on_Ships_pressed():
	var Window = $MainWindow
	var SysArt = $Back/SystemArt
	var twee = get_tree().create_tween()
	twee.tween_property(Window, "rect_position", Vector2(-1280,0), 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	twee.parallel().tween_property(SysArt, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Systems, "modulate", Color(1,1,1,0),0.5)
	twee.parallel().tween_property($MainWindow/Ships, "modulate", Color(1,1,1,1),0.5)
	twee.parallel().tween_property($MainWindow/Agent, "modulate", Color(1,1,1,0),0.5)
	yield(twee,"finished")
	$MainWindow/Ships/ViewShips.show()
