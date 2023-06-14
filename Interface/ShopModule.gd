extends HBoxContainer

var newShipyard
var shopws
var shopss
var reloadData
const pShip = preload("res://Interface/ShipyardMarket/ShipPurchaseModule.tscn")
const pGood = preload("res://Interface/ResourceMarket/MarketItemModule.tscn")

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
	
	#$ScrollContainer.get_v_scrollbar().rect_position += Vector2($ScrollContainer.rect_min_size.x, 0)

func updateVis(data):
	for r in $ScrollContainer/Items.get_children():
		yield(get_tree(),"idle_frame")
		r.queue_free()
	
	
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
	for r in $ScrollContainer/Items.get_children():
		r.queue_free()
	
	if !YFFDQ:
		Agent.call_deferred("queryUser_Ship", waypoint)
		#Agent.queryUser_Ship(waypoint)
		yield(Agent,"interfaceShipSet")
	elif YFFDQ:
		yield(Agent,"fleetUpdated")
		yield(get_tree(),"idle_frame")
	
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

func reloadMarket():
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
		getfail()
	print(json.result)

func getfail():
	pass
