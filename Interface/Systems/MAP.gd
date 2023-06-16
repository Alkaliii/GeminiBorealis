extends Control

const circle = preload("res://Interface/CIRCLE.tscn")
const WYPT = preload("res://Interface/Systems/WAYPOINT.tscn")

var testtoken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoiR0VNSU5JX1RIUkVFIiwidmVyc2lvbiI6InYyIiwicmVzZXRfZGF0ZSI6IjIwMjMtMDYtMTAiLCJpYXQiOjE2ODY0NzA3NzAsInN1YiI6ImFnZW50LXRva2VuIn0.S9y4Ja9nBxhsaNrRBRayDHz9HZHR_pu8eFGMgeP9Ob4XK6Ns2qG3pG3UmDmnbGhuyh5iRDN1qGoaIj-_dX2ash97uyCvdZqutrWOdsCfhzi8V2FHNKjd0GgZ2PiLc_-PusiV4ZGKJzRnwCSA8kzZVKKxYdxGTQphk900o2798snIYHQrYdqq2OLHstQxjjeWrr4IgHthRvS_NiNNEAtxaLML5nTyS0vyvxgdRBM4sn3Qf7wSm498qwS8SKX3XuAbtBgT9xCv7ee-jEq17DlhKtAOgW9FoM_8KAgyL_iAjQ3AlbGHzmLyV058PL_bBMbmEpbFVJ1jwlisdCdweqHB5Q"
var testsystem = "X1-SS23"

var orbitallist : Dictionary
var gendorb : Array

var PlanetNdList : Dictionary
var OrbitNdList : Dictionary
var SubOrbitNdList : Dictionary

var nearNode
var nearNodeName
var nearFocus
var nearTwee

var olddata = null
var tweeC

var quickChart = false

const WPCM = {
		"MOON":
			{"text":"#f8fafc","bg":"#64748b"},
		"GAS_GIANT":
			{"text":"#fff7ed","bg":"#ea580c"},
		"NEBULA":
			{"text":"#422006","bg":"#fde047"},
		"ASTEROID_FIELD":
			{"text":"#1a2e05","bg":"#bef264"},
		"PLANET":
			{"text":"#ecfdf5","bg":"#059669"},
		"DEBRIS_FIELD":
			{"text":"#083344","bg":"#67e8f9"},
		"ORBITAL_STATION":
			{"text":"#fdf4ff","bg":"#c026d3"},
		"JUMP_GATE":
			{"text":"#030712","bg":"#f9fafb"},
		"GRAVITY_WELL":
			{"text":"#f9fafb","bg":"#030712"}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("systemFetch",self,"generateSYSTEM")
	Agent.connect("systemWayFetch",self,"generateORBITALLIST")
	Agent.connect("login",self,"clearAll")
	Agent.connect("chart",self,"tweenCam")
	Agent.connect("mapGenLine",self,"genLine")
	self.hide()
	
	var circ = circle.instance()
	circ.rect_global_position = Vector2(500,500)
	circ.pos = Vector2.ZERO
	circ.rad = 1
	circ.col = Color(1,1,1,0.5)
	circ.width = 1.05
	self.add_child(circ)
	nearFocus = circ
	
	
	#fetchtestSysWay()
	#yield(get_tree(),"idle_frame")
	#fetchtestSys()
	pass # Replace with function body.

func fetchtestSys():
	var HTTP = HTTPRequest.new()
	HTTP.use_threads = true
	HTTP.connect("request_completed",self,"_on_request_completed")
	self.add_child(HTTP)
	var url = str("https://api.spacetraders.io/v2/systems/",testsystem)
	var headerstring = str("Authorization: Bearer ", testtoken)
	var header = [headerstring]
	HTTP.request(url, header)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		generateSYSTEM(cleanbody)
#		var ints : Array
#		for s in cleanbody["data"]["symbol"]:
#			if s.is_valid_integer():
#				ints.push_back(s)
#
#		var total = 0
#		for i in ints:
#			total += int(i)
#
#		var long = ""
#		for i in ints:
#			long += str(i)
#		var star = WYPT.instance()
#		star.genStar(cleanbody,ints,total,long)
		#star.rect_position = Vector2(0,0)
#		self.add_child(star)
#	else:
#		getfail()
	#print(json.result)

func fetchtestSysWay():
	var HTTP = HTTPRequest.new()
	HTTP.use_threads = true
	HTTP.connect("request_completed",self,"_on_WAYrequest_completed")
	self.add_child(HTTP)
	var url = str("https://api.spacetraders.io/v2/systems/",testsystem,"/waypoints")
	var headerstring = str("Authorization: Bearer ", testtoken)
	var header = [headerstring]
	HTTP.request(url, header)

func _on_WAYrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		for s in cleanbody["data"]:
			for o in s["orbitals"]:
				orbitallist[o["symbol"]] = Vector2(s["x"],s["y"])
				print(orbitallist.keys())
				#orbitallist.push_back([o,Vector2(o["x"],o["y"])])
#	else:
#		getfail()
	#print(json.result)

func tweenCam(data):
	focusWPT(data)
	
	if quickChart: 
		quickChart = false
		return
	if $Camera2D.position == (Vector2(485,500)+Vector2(data["data"]["x"],data["data"]["y"])): return
	
	tweeC = get_tree().create_tween()
	tweeC.tween_property($Camera2D,"zoom",Vector2(0.1,0.1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tweeC.parallel().tween_property($Camera2D,"position",(Vector2(485,500)+Vector2(data["data"]["x"],data["data"]["y"])),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	yield(tweeC,"finished")
	tweeC = get_tree().create_tween()
	tweeC.tween_property($Camera2D,"zoom",Vector2(0.05,0.05),3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func focusWPT(data):
	resetWPTcol()
	yield(get_tree().create_timer(0.3),"timeout")
	PlanetNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"])
	if OrbitNdList.has(data["data"]["symbol"]):
		OrbitNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"]).lightened(0.7)
	else:
		SubOrbitNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"]).lightened(0.7)

func _process(delta):
	mapZoom()
	mapTranslate()
	mapHome()
	if Input.is_action_just_pressed("MAPconfirm"):
		for w in Agent.systemData["data"]:
			if w["symbol"] == nearNodeName:
				quickChart = true
				Agent.emit_signal("chart",{"data":w})


func mapHome():
	if Input.is_action_just_pressed("MAPhome"):
		var mhtwee = get_tree().create_tween()
		mhtwee.tween_property($Camera2D,"zoom",Vector2(0.1,0.1),4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		mhtwee.parallel().tween_property($Camera2D,"position",Vector2(500,500),1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		resetWPTcol()
		for r in $Lines.get_children():
			r.queue_free()
		$CanvasLayer/VBoxContainer/DISTANCE.hide()
		Agent.emit_signal("mapHOME")

func mapTranslate():
	if Input.is_action_pressed("MAPleft"):
		$Camera2D.position.x -= $Camera2D.zoom.x * 10
	if Input.is_action_pressed("MAPright"):
		$Camera2D.position.x += $Camera2D.zoom.x * 10
	if Input.is_action_pressed("MAPup"):
		$Camera2D.position.y -= $Camera2D.zoom.y * 10
	if Input.is_action_pressed("MAPdown"):
		$Camera2D.position.y += $Camera2D.zoom.y * 10
	$Camera2D.position.x = clamp($Camera2D.position.x,300,700)
	$Camera2D.position.y = clamp($Camera2D.position.y,300,700)
	if PlanetNdList.size() != 0:
		calc_nearNode()


func calc_nearNode():
	if PlanetNdList.size() == 0: return
	if Agent.systemData == null: return
#	if nearTwee == SceneTreeTween:
#		nearTwee.kill()
	
	if nearNode.rect_position.distance_to($Camera2D.position) < 8:
		for w in Agent.systemData["data"]:
			if w["symbol"] == nearNodeName:
				$CanvasLayer/VBoxContainer/WAYPOINT.show()
				$CanvasLayer/VBoxContainer/WAYPOINT.bbcode_text = str("[color=#949495]",w["type"])
				
				var shipCount = 0
				for s in Agent._FleetData["data"]:
					if s["nav"]["waypointSymbol"] == nearNodeName and s["nav"]["status"] != "IN_TRANSIT":
						shipCount += 1
					elif Vector2(s["nav"]["route"]["destination"]["x"],s["nav"]["route"]["destination"]["y"]) == nearNode.rect_position-Vector2(500,500):
						shipCount += 1
				
				if shipCount > 0:
					var ss = ""
					if shipCount > 1: ss = "S"
					$CanvasLayer/VBoxContainer/SHIPS.show()
					$CanvasLayer/VBoxContainer/SHIPS.bbcode_text = str("[color=#949495][b]",shipCount,"[/b] SHIP",ss)
	else:
		$CanvasLayer/VBoxContainer/WAYPOINT.hide()
		$CanvasLayer/VBoxContainer/SHIPS.hide()
	
	
	for nd in PlanetNdList:
		if PlanetNdList[nd].rect_position.distance_to($Camera2D.position) < nearNode.rect_position.distance_to($Camera2D.position):
			nearNode = PlanetNdList[nd]
			nearNodeName = nd
			
			
			#print(nd)
			Agent.emit_signal("mapSEL",nd)
			
			
			if nearTwee == SceneTreeTween:
				yield(nearTwee,"finished")
			
			nearTwee = get_tree().create_tween()
			nearTwee.tween_property(nearFocus,"rect_position",PlanetNdList[nd].rect_position,0.2)
	
	for l in $Lines.get_children():
		if l.get_point_count() == 2:
			if l.get_point_position(0).distance_to($Camera2D.position) < 12 or l.get_point_position(1).distance_to($Camera2D.position) < 12:
				$CanvasLayer/VBoxContainer/DISTANCE.show()
				$CanvasLayer/VBoxContainer/DISTANCE.bbcode_text = str("[color=#949495][b]D: ", l.name)
				break
			else:
				$CanvasLayer/VBoxContainer/DISTANCE.hide()

func mapZoom():
	if Input.is_action_just_pressed("MAPzoom_out"): #OUT
		var newZ = clamp(($Camera2D.zoom.x+0.1),0.01,0.5)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	if Input.is_action_just_pressed("MAPzoom_in"): #IN
		var newZ = clamp(($Camera2D.zoom.x-0.05),0.01,0.5)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func clearAll():
	PlanetNdList.clear()
	OrbitNdList.clear()
	SubOrbitNdList.clear()
	for r in $Orbits.get_children():
		r.queue_free()
	for r in $Planets.get_children():
		r.queue_free()

func resetWPTcol():
	var fwptTwee #focus waypoint tween
	for nd in PlanetNdList:
		fwptTwee = get_tree().create_tween()
		fwptTwee.tween_property(PlanetNdList[nd],"modulate",Color(1,1,1),0.2).set_trans(Tween.TRANS_BACK)
		#PlanetNdList[nd].modulate = Color(1,1,1)
	for nd in OrbitNdList:
		fwptTwee = get_tree().create_tween()
		fwptTwee.tween_property(OrbitNdList[nd],"modulate",Color(1,1,1),0.2).set_trans(Tween.TRANS_BACK)
		#OrbitNdList[nd].modulate = Color(1,1,1)
	for nd in SubOrbitNdList:
		fwptTwee = get_tree().create_tween()
		fwptTwee.tween_property(SubOrbitNdList[nd],"modulate",Color(1,1,1),0.2).set_trans(Tween.TRANS_BACK)
		#SubOrbitNdList[nd].modulate = Color(1,1,1)

func generateORBITALLIST(data):
	for s in data["data"]:
		for o in s["orbitals"]:
			orbitallist[o["symbol"]] = Vector2(s["x"],s["y"])
			#print(orbitallist.keys())

func generateSYSTEM(data):
	#Agent.systemData = data
	
	var star = circle.instance()
	var starnice = preload("res://EXTERNAL/Planets/Star/Star.tscn").instance()
	starnice.rect_global_position = Vector2(450,450)
	starnice.rect_pivot_offset = Vector2(50,50)
	starnice.rect_scale = Vector2(0.16,0.16)
	starnice.set_colors([Color("#eaeaea"),Color("#ffffff"),Color("#949495"),Color("#535355"),Color("#28282b"),Color("#a9a9aa"),Color("#28282b")])
	star.pos = Vector2(500,500)
	star.rad = 6
	star.col = Color(1,1,1)
	star.fill = true
	self.add_child(star)
	self.add_child(starnice)
	
	yield(Agent,"systemWayFetch")
	self.show()
	
	for w in data["data"]["waypoints"]:
		var wpt
		var ints : Array
		for s in w["symbol"]:
			if s.is_valid_integer():
				ints.push_back(s)
		
		var total = 0
		for i in ints:
			total += int(i)
		
		var long = ""
		for i in ints:
			long += str(i)
		
		#print(w["symbol"],ints,total)
		match w["type"]:
			"PLANET": 
				if !w["symbol"] in orbitallist.keys():
					var waypoi = circle.instance()
					waypoi.rect_global_position = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.pos = Vector2.ZERO#Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					$Planets.add_child(waypoi)
					PlanetNdList[w["symbol"]] = waypoi
					
					print(w["symbol"])
					var circ = circle.instance()
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,0.6)
					$Orbits.add_child(circ)
					OrbitNdList[w["symbol"]] = circ
				else:
					genOrbitals(Vector2(w["x"],w["y"]))
			_:
				if !w["symbol"] in orbitallist.keys():
					var waypoi = circle.instance()
					waypoi.rect_global_position = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.pos = Vector2.ZERO#Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					$Planets.add_child(waypoi)
					PlanetNdList[w["symbol"]] = waypoi
					
					var circ = circle.instance()
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,0.6)
					$Orbits.add_child(circ)
					OrbitNdList[w["symbol"]] = circ
				else:
					genOrbitals(Vector2(w["x"],w["y"]))
	nearNode = PlanetNdList[PlanetNdList.keys()[0]]
	calc_nearNode()

func genOrbitals(pos):
	if pos in gendorb: return
	else: gendorb.push_back(pos)
	
	var onum = 2
	var idx = 0
	for o in orbitallist:
		if orbitallist[o] != pos: continue
		var circ = circle.instance()
		circ.pos = pos+Vector2(500,500)
		circ.rad = onum
		circ.col = Color(1,1,1,0.4)
		$Orbits.add_child(circ)
		SubOrbitNdList[o] = circ
		
		var waypt = circle.instance()
		waypt.pos = (pos+Vector2(500,500))+Vector2(-onum,0)
		waypt.rad = 0.1
		waypt.col = Color(1,1,1,1)
		waypt.fill = true
		$Planets.add_child(waypt)
		PlanetNdList[o] = waypt
		
		onum += 1.3
		idx += 1

func genLine(one,two):
	for l in $Lines.get_children():
		if (l.get_point_position(0) == one+Vector2(500,500)) and (l.get_point_position(1) == two+Vector2(500,500)):
			return
		if (l.get_point_position(0) == two+Vector2(500,500)) and (l.get_point_position(1) == one+Vector2(500,500)):
			return
	
	var line = Line2D.new()
	line.width = 0.05
	line.default_color = Color(1,1,1)
	line.add_point((one+Vector2(500,500)),0)
	line.add_point((two+Vector2(500,500)),1)
	line.name = str(round((one-two).length()))
	$Lines.add_child(line)
	print(line.global_position)
