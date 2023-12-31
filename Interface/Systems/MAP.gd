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
var nearLine = null

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
	Agent.connect("FocusMapNav",self,"tweenCam")
	Agent.connect("mapGenLine",self,"genLine")
	Agent.connect("exitJumpgate",self,"focusHome")
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
	if $Camera2D.position == (Vector2(500,500)+Vector2(data["data"]["x"],data["data"]["y"])): return
	#485
	
	if $Camera2D.zoom < Vector2(0.1,0.1):	
		tweeC = get_tree().create_tween()
		tweeC.tween_property($Camera2D,"zoom",Vector2(0.1,0.1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tweeC.parallel().tween_property($Camera2D,"position",(Vector2(500,500)+Vector2(data["data"]["x"],data["data"]["y"])),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		yield(tweeC,"finished")
	else:
		tweeC = get_tree().create_tween()
		tweeC.tween_property($Camera2D,"position",(Vector2(500,500)+Vector2(data["data"]["x"],data["data"]["y"])),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		yield(tweeC,"finished")
	tweeC = get_tree().create_tween()
	tweeC.tween_property($Camera2D,"zoom",Vector2(0.05,0.05),3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func focusWPT(data):
	if !data["data"].has("symbol"): return
	resetWPTcol()
	yield(get_tree().create_timer(0.3),"timeout")
	PlanetNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"])
	if OrbitNdList.has(data["data"]["symbol"]):
		OrbitNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"]).lightened(0.7)
	else:
		SubOrbitNdList[data["data"]["symbol"]].modulate = Color(WPCM[data["data"]["type"]]["bg"]).lightened(0.7)

func focusHome():
	var mhtwee = get_tree().create_tween()
	mhtwee.tween_property($Camera2D,"zoom",Vector2(0.1,0.1),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	mhtwee.parallel().tween_property($Camera2D,"position",Vector2(500,500),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	resetWPTcol()
	nearLine = null
	for r in $Lines.get_children():
		r.queue_free()
	$CanvasLayer/VBoxContainer/DISTANCE.hide()
	Agent.emit_signal("mapHOME")

func _process(delta):
	if Agent.AgentCredits.is_valid_float():
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
		nearLine = null
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
				Agent.emit_signal("mapSEL",nearNodeName)
				
				var shipCount = 0
				for s in Agent._FleetData["data"]:
					if s["nav"]["waypointSymbol"] == nearNodeName and s["nav"]["status"] != "IN_TRANSIT":
						shipCount += 1
					elif Vector2(s["nav"]["route"]["destination"]["x"],s["nav"]["route"]["destination"]["y"]) == nearNode.rect_position-Vector2(500,500) and s["nav"]["status"] != "IN_TRANSIT":
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
			#Agent.emit_signal("mapSEL",nd)
			
	if nearTwee == SceneTreeTween:
		yield(nearTwee,"finished")
			
	if nearNode.rect_position.distance_to($Camera2D.position) < 8:
		nearTwee = get_tree().create_tween()
		nearTwee.tween_property(nearFocus,"rect_position",nearNode.rect_position,0.2)
	else:
		#nearFocus.rect_position = $Camera2D.position
		nearTwee = get_tree().create_tween()
		nearTwee.tween_property(nearFocus,"rect_position",$Camera2D.position,0.7).set_ease(Tween.EASE_OUT)
	
	if nearLine != null:
		for l in $Lines.get_children():
			if l.get_point_position(0).distance_to($Camera2D.position) < nearLine.get_point_position(0).distance_to($Camera2D.position) or l.get_point_position(1).distance_to($Camera2D.position) < nearLine.get_point_position(1).distance_to($Camera2D.position):
				nearLine = l
			if ((l.get_point_position(0)+l.get_point_position(1))/2).distance_to($Camera2D.position) < ((nearLine.get_point_position(0)+nearLine.get_point_position(1))/2).distance_to($Camera2D.position):
				nearLine = l
			if l != nearLine:
				l.width = 0.05
		if nearLine.get_point_position(0).distance_to($Camera2D.position) < 12 or nearLine.get_point_position(1).distance_to($Camera2D.position) < 12:
			$CanvasLayer/VBoxContainer/DISTANCE.show()
			$CanvasLayer/VBoxContainer/DISTANCE.bbcode_text = str("[color=#949495][b]D: ", nearLine.name)
		elif ((nearLine.get_point_position(0)+nearLine.get_point_position(1))/2.0).distance_to($Camera2D.position) < 12:
			$CanvasLayer/VBoxContainer/DISTANCE.show()
			$CanvasLayer/VBoxContainer/DISTANCE.bbcode_text = str("[color=#949495][b]D: ", nearLine.name)
			nearLine.width = 0.3
		else:
			$CanvasLayer/VBoxContainer/DISTANCE.hide()
			for l in $Lines.get_children():
				l.width = 0.05
			

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
	for r in $Lines.get_children():
		r.queue_free()
	for r in $Transit.get_children():
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
	
#	var star = circle.instance()
	var starnice = preload("res://EXTERNAL/Planets/Star/Star.tscn").instance()
	starnice.rect_global_position = Vector2(450,450)
	starnice.rect_pivot_offset = Vector2(50,50)
	starnice.rect_scale = Vector2(0.16,0.16)
	starnice.set_colors([Color("#eaeaea"),Color("#ffffff"),Color("#949495"),Color("#535355"),Color("#28282b"),Color("#a9a9aa"),Color("#28282b")])
	starnice.modulate = Color(1,1,1,0)
#	star.pos = Vector2(500,500)
#	star.rad = 6
#	star.col = Color(1,1,1)
#	star.fill = true
	#$Planets.add_child(star)
	$Planets.add_child(starnice)
	
	yield(Agent,"systemWayFetch")
	self.show()
	var twee = get_tree().create_tween()
	twee.tween_property(starnice,"modulate",Color(1,1,1,1),0.5)
	
	for w in data["data"]["waypoints"]:
#		var wpt
#		var ints : Array
#		for s in w["symbol"]:
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
		
		#print(w["symbol"],ints,total)
		var waypoi
		var circ
		match w["type"]:
			"PLANET": 
				if !w["symbol"] in orbitallist.keys():
					waypoi = circle.instance()
					waypoi.rect_global_position = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.pos = Vector2.ZERO#Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					$Planets.add_child(waypoi)
					PlanetNdList[w["symbol"]] = waypoi
					
					#print(w["symbol"])
					circ = circle.instance()
					#circ.rect_global_position = Vector2(500,500)
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,0.6)
					$Orbits.add_child(circ)
					OrbitNdList[w["symbol"]] = circ
				else:
					genOrbitals(Vector2(w["x"],w["y"]))
			_:
				if !w["symbol"] in orbitallist.keys():
					waypoi = circle.instance()
					waypoi.rect_global_position = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.pos = Vector2.ZERO#Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					$Planets.add_child(waypoi)
					PlanetNdList[w["symbol"]] = waypoi
					
					circ = circle.instance()
					#circ.rect_global_position = Vector2(500,500)
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,0.6)
					$Orbits.add_child(circ)
					OrbitNdList[w["symbol"]] = circ
				else:
					genOrbitals(Vector2(w["x"],w["y"]))
		if OrbitNdList.has(w["symbol"]):
			twee = get_tree().create_tween()
			PlanetNdList[w["symbol"]].modulate = Color(1,1,1,0)
			OrbitNdList[w["symbol"]].modulate = Color(1,1,1,0)
			twee.tween_property(PlanetNdList[w["symbol"]],"modulate",Color(1,1,1,1),0.2)
			twee.parallel().tween_property(OrbitNdList[w["symbol"]],"modulate",Color(1,1,1,1),0.2)
	nearNode = PlanetNdList[PlanetNdList.keys()[PlanetNdList.keys().size()-1]]
	calc_nearNode()

func genOrbitals(pos):
	if pos in gendorb: return
	else: gendorb.push_back(pos)
	
	var onum = 2
	var idx = 0
	var twee
	for o in orbitallist: #I have no idea how this works properly but it does so leave it
		if orbitallist[o] != pos: continue
		var circ = circle.instance()
		circ.rect_global_position = pos+Vector2(500,500)
		circ.pos = Vector2.ZERO#pos+Vector2(500,500)
		circ.rad = onum
		circ.col = Color(1,1,1,0.4)
		circ.width = 0.3
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
		
		twee = get_tree().create_tween()
		waypt.modulate = Color(1,1,1,0)
		circ.modulate = Color(1,1,1,0)
		twee.tween_property(waypt,"modulate",Color(1,1,1,1),0.2)
		twee.parallel().tween_property(circ,"modulate",Color(1,1,1,1),0.2)

func genLine(one,two, col = null, transit = false, arrival = null):
	if one == two: return
	
	for l in $Lines.get_children():
		if (l.get_point_position(0) == one+Vector2(500,500)) and (l.get_point_position(1) == two+Vector2(500,500)):
			return
		if (l.get_point_position(0) == two+Vector2(500,500)) and (l.get_point_position(1) == one+Vector2(500,500)):
			return
	
	for l in $Transit.get_children():
		#if !l is Line2D: continue
		if (l.get_point_position(0) == one+Vector2(500,500)) and (l.get_point_position(1) == two+Vector2(500,500)):
			return
		if (l.get_point_position(0) == two+Vector2(500,500)) and (l.get_point_position(1) == one+Vector2(500,500)):
			return
	
	var line = Line2D.new()
	line.width = 0.05
	if col != null:
		line.default_color = col
	else: line.default_color = Color(1,1,1)
	line.add_point((one+Vector2(500,500)),0)
	line.add_point((two+Vector2(500,500)),1)
	line.name = str(round((one-two).length()))
	for l in $Lines.get_children():
		if l.name == str(round((one-two).length())):
			line.name += "'"
	
	if transit:
		line.name = str(round((one-two).length()),"TRANSIT")
		
		for l in $Transit.get_children():
			if l.name == line.name:
				line.queue_free()
				return
		
		line.begin_cap_mode = Line2D.LINE_CAP_BOX
		line.end_cap_mode = Line2D.LINE_CAP_BOX
		$Transit.add_child(line)
		var transitTweeProg = get_tree().create_tween()
		transitTweeProg.bind_node(line)
		transitTweeProg.tween_method(self,"tweenTransitLine",one+Vector2(500,500),two+Vector2(500,500),(Time.get_unix_time_from_datetime_string(arrival) - Time.get_unix_time_from_system()),[line]).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(6)
		#transitTweeProg.tween_property(circ,"rect_position",two+Vector2(500.0,500.0),(Time.get_unix_time_from_datetime_string(arrival) - Time.get_unix_time_from_system())).set_ease(Tween.EASE_IN_OUT)
		
		var transitTwee = get_tree().create_tween()
		transitTwee.set_loops()
		transitTwee.bind_node(line)
		transitTwee.tween_property(line,"modulate",Color(1,1,1,1),1)
		transitTwee.tween_interval(0.2)
		transitTwee.tween_property(line,"modulate",Color(1,1,1,0.5),1)
		if arrival != null:
			var expiry = (Time.get_unix_time_from_datetime_string(arrival) - Time.get_unix_time_from_system())
			var terminate = get_tree().create_timer(expiry)
			terminate.connect("timeout",line,"queue_free")
			#line.add_child(terminate)
	else: $Lines.add_child(line)
	
	if $Lines.get_child_count() == 1:
		nearLine = line
	#print(line.global_position)

func tweenTransitLine(newEnd : Vector2,line : Line2D):
	line.call_deferred("set_point_position",0,newEnd)
