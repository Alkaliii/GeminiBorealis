extends HBoxContainer

var newShipyard
var shopws
var shopss
var shopdat
var reloadData
const pShip = preload("res://Interface/ShipyardMarket/ShipPurchaseModule.tscn")
const pGood = preload("res://Interface/ResourceMarket/MarketItemModule.tscn")
const iee = preload("res://Interface/ResourceMarket/importexportexchange.tscn")

var Purging = false 

#const infoline = preload("res://300linesmall.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("shipyard", self, "displayShipyard")
	Agent.connect("visitmarket",self,"displayMarket")
	Agent.connect("login",self,"hide")
	Agent.connect("chart", self, "updateVis")
	Agent.connect("PurchaseShip",self,"reloadShipyard")
	Agent.connect("PurchaseCargo",self,"reloadMarket")
	Agent.connect("SellCargo",self,"reloadMarket")
	Agent.connect("closeShop", self,"updateVis")
	Agent.connect("mapHOME",self,"fauxClose")
	
	$MarketButtons.hide()
	
	#$ScrollContainer.get_v_scrollbar().rect_position += Vector2($ScrollContainer.rect_min_size.x, 0)

func fauxClose():
	updateVis({"data":{"null":null}})

func updateVis(data):
	for r in $ScrollContainer/Items.get_children():
		yield(get_tree(),"idle_frame")
		r.queue_free()
	
	$MarketButtons.hide()
	
	if !data["data"].has("traits"): return
	hide()
	
	for t in data["data"]["traits"]:
		if t["symbol"] == "SHIPYARD" or t["symbol"] == "MARKETPLACE":
			show()

func displayShipyard(data, waypoint, system):
	shopws = waypoint
	shopss = system
	for r in $ScrollContainer/Items.get_children():
		r.queue_free()

	for s in data["data"]["ships"]:
		var purchase = pShip.instance()
		yield(get_tree(),"idle_frame")
		purchase.setdat(s)
		purchase.Waypoint = waypoint
		$ScrollContainer/Items.add_child(purchase)

func displayMarket(data, waypoint, system, YFFDQ = false): #Yield For Fleet, Don't Queue
	shopws = waypoint
	shopss = system
	shopdat = data
	for r in $ScrollContainer/Items.get_children():
		r.queue_free()
	
	if !YFFDQ:
		Agent.call_deferred("queryUser_Ship", waypoint)
		#Agent.queryUser_Ship(waypoint)
		yield(Agent,"interfaceShipSet")
	elif YFFDQ:
		#yield(Agent,"fleetUpdated")
		yield(get_tree(),"idle_frame")
	
	$MarketButtons.show()
	for s in Agent._FleetData["data"]:
		if s["symbol"] == Agent.interfaceShip and s["nav"]["status"] == "DOCKED":
			$MarketButtons/Dock.hide()
			break
		else:
			$MarketButtons/Dock.show()
	
	for g in data["data"]["tradeGoods"]:
		var trade = pGood.instance()
		trade.ws = data["data"]["symbol"]
		yield(get_tree(),"idle_frame")
		trade.setdat(g)
		$ScrollContainer/Items.add_child(trade)
	

func reloadShipyard():
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/systems/",shopss,"/waypoints/",shopws,"/shipyard")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Accept: application/json",headerstring,"Content-Type: application/json"]
	
	HTTP.request(url, header)
	yield(HTTP,"request_completed")
	HTTP.queue_free()
	displayShipyard(reloadData,shopws,shopss)

func reloadMarket(arg = null):
	if Purging: return
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_request_completed")
	var url = str("https://api.spacetraders.io/v2/systems/",shopss,"/waypoints/",shopws,"/market")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Accept: application/json",headerstring,"Content-Type: application/json"]
	
	HTTP.request(url, header)
	yield(HTTP,"request_completed")
	HTTP.queue_free()
	displayMarket(reloadData,shopws,shopss, true)

func _on_request_completed(result, response_code, headers, body):
	if result == 4:
		print("bad",result,response_code)
		return
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		reloadData = cleanbody
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass


func _on_Dock_pressed():
	$MarketButtons/Dock.hide()
	var HTTP = HTTPRequest.new()
	self.add_child(HTTP)
	HTTP.use_threads = true
	HTTP.connect("request_completed", self, "_on_DOCKrequest_completed")
	var url = str("https://api.spacetraders.io/v2/my/ships/",Agent.interfaceShip,"/dock")
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = ["Content-Type: application/json",headerstring,"Content-Length: 0"]
	
	HTTP.request(url, header, true, HTTPClient.METHOD_POST)
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_DOCKrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("DockFinished",cleanbody)
	else:
		Agent.dispError(cleanbody)
#		getfail()
	print(json.result)


func _on_Info_pressed():
	var _import = null
	var _export = null
	var _exchan = null
	
	for c in $ScrollContainer/Items.get_children():
		if c.name in ["IMPORT","EXPORT","EXCHANGE"]:
			match c.name:
				"IMPORT": _import = c
				"EXPORT": _export = c
				"EXCHANGE": _exchan = c
	
	if _import == null:
		_import = iee.instance()
		_import.name = "IMPORT"
		_import.infoType = 0
		_import.setdat(shopdat["data"]["imports"])
		$ScrollContainer/Items.add_child(_import)
	else: _import.setdat(shopdat["data"]["imports"])
	
	if _export == null:
		_export = iee.instance()
		_export.name = "EXPORT"
		_export.infoType = 1
		_export.setdat(shopdat["data"]["exports"])
		$ScrollContainer/Items.add_child(_export)
	else: _export.setdat(shopdat["data"]["exports"])
	
	if _exchan == null:
		_exchan = iee.instance()
		_exchan.name = "EXCHANGE"
		_exchan.infoType = 2
		_exchan.setdat(shopdat["data"]["exchange"])
		$ScrollContainer/Items.add_child(_exchan)
	else: _exchan.setdat(shopdat["data"]["exchange"])
	
	var twee = get_tree().create_tween()
	twee.tween_property($ScrollContainer,"scroll_vertical",int($ScrollContainer.get_v_scrollbar().max_value),0.3).set_ease(Tween.EASE_IN_OUT)


func _on_Purge_pressed():
	$MarketButtons/Purge.disabled = true
	Purging = true
	var purgeReq : Array
	var ship
	var itemspurged = 0
	
	for s in Agent._FleetData["data"]:
		if s["symbol"] == Agent.interfaceShip:
			ship = s
			break
	
	if ship["nav"]["status"] != "DOCKED":
		self.call_deferred("_on_Dock_pressed")
		yield(Agent,"DockFinished")
	
	var purgelist : Array
	for c in ship["cargo"]["inventory"]:
		for g in shopdat["data"]["tradeGoods"]:
			if c["symbol"] == g["symbol"]:
				purgelist.push_back({"sym":g["symbol"],"amt":c["units"]})
	
	print(purgelist)
	for purgable in purgelist:
		#Agent.sellCargo(purgable["sym"],purgable["amt"],self)
		
		var PURGE_POST_REQUEST_OBj = {
			"Author": self,
			"Callback": "_on_SELLrequest_completed",
			"API_ext": str("my/ships/",Agent.interfaceShip,"/sell"), #After "v2" in https://api.spacetraders.io/v2
			"data": {"symbol": purgable["sym"], "units": purgable["amt"]}, #JSON.print'd dictionary, if it remains null an additional header will be added "Content-Length: 0"
			"RID": str(ship["symbol"],"SELL",purgable["sym"],Time.get_unix_time_from_system()), #Request ID, which will be used to identify it, different nodes should create different IDs utilizing time, the node name and maybe other relevant data
			"TYPE": "POST"
		}
		
		Automation.callQueue.push_back(PURGE_POST_REQUEST_OBj)
		purgeReq.push_back(PURGE_POST_REQUEST_OBj.RID)
		#yield(Agent,"SellCargo")
		itemspurged += 1
		#$MarketButtons/Purge.text = "wait"
		#yield(get_tree().create_timer(1),"timeout")
		#$MarketButtons/Purge.text = str(itemspurged)
		#if itemspurged == 10: yield(get_tree().create_timer(5),"timeout")
		#else: yield(get_tree().create_timer(1),"timeout")
	for i in purgeReq:
		Automation.progressQueue.erase(i)
		$MarketButtons/Purge.text = str(itemspurged)
		itemspurged -= 1
	$MarketButtons/Purge.text = "Purge"
	$MarketButtons/Purge.disabled = false
	Purging = false
	yield(get_tree(),"idle_frame")
	self.call_deferred("reloadMarket")

func _on_SELLrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("SellCargo",cleanbody)
	else:
		Agent.dispError(cleanbody)
		#getfail()
		print(json.result)
