extends Control

const circle = preload("res://Interface/CIRCLE.tscn")
const WYPT = preload("res://Interface/Systems/WAYPOINT.tscn")

var testtoken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoiR0VNSU5JX1RIUkVFIiwidmVyc2lvbiI6InYyIiwicmVzZXRfZGF0ZSI6IjIwMjMtMDYtMTAiLCJpYXQiOjE2ODY0NzA3NzAsInN1YiI6ImFnZW50LXRva2VuIn0.S9y4Ja9nBxhsaNrRBRayDHz9HZHR_pu8eFGMgeP9Ob4XK6Ns2qG3pG3UmDmnbGhuyh5iRDN1qGoaIj-_dX2ash97uyCvdZqutrWOdsCfhzi8V2FHNKjd0GgZ2PiLc_-PusiV4ZGKJzRnwCSA8kzZVKKxYdxGTQphk900o2798snIYHQrYdqq2OLHstQxjjeWrr4IgHthRvS_NiNNEAtxaLML5nTyS0vyvxgdRBM4sn3Qf7wSm498qwS8SKX3XuAbtBgT9xCv7ee-jEq17DlhKtAOgW9FoM_8KAgyL_iAjQ3AlbGHzmLyV058PL_bBMbmEpbFVJ1jwlisdCdweqHB5Q"
var testsystem = "X1-SS23"

var orbitallist : Dictionary
var gendorb : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("systemFetch",self,"generateSYSTEM")
	Agent.connect("systemWayFetch",self,"generateORBITALLIST")
	Agent.connect("login",self,"clearAll")
	Agent.connect("chart",self,"tweenCam")
	self.hide()
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
	var twee = get_tree().create_tween()
	twee.tween_property($Camera2D,"position",(Vector2(500,500)+Vector2(data["data"]["x"],data["data"]["y"])),3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func clearAll():
	for r in self.get_children():
		if r is Camera2D: continue
		r.queue_free()

func generateORBITALLIST(data):
	for s in data["data"]:
		for o in s["orbitals"]:
			orbitallist[o["symbol"]] = Vector2(s["x"],s["y"])
			print(orbitallist.keys())

func generateSYSTEM(data):
	var star = circle.instance()
	star.pos = Vector2(500,500)
	star.rad = 6
	star.col = Color(1,1,1)
	star.fill = true
	self.add_child(star)
	
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
					waypoi.pos = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					self.add_child(waypoi)
					
					print(w["symbol"])
					var circ = circle.instance()
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,1)
					self.add_child(circ)
				else:
					genOrbitals(Vector2(w["x"],w["y"]))
			_:
				if !w["symbol"] in orbitallist.keys():
					var waypoi = circle.instance()
					waypoi.pos = Vector2(w["x"],w["y"]) + Vector2(500,500)
					waypoi.rad = 0.6
					waypoi.col = Color(1,1,1,1)
					waypoi.fill = true
					self.add_child(waypoi)
					
					var circ = circle.instance()
					circ.pos = Vector2(500,500)
					circ.rad = Vector2(w["x"],w["y"]).length()
					circ.col = Color(1,1,1,1)
					self.add_child(circ)
				else:
					genOrbitals(Vector2(w["x"],w["y"]))

func genOrbitals(pos):
	if pos in gendorb: return
	else: gendorb.push_back(pos)
	
	var onum = 2
	for o in orbitallist:
		if orbitallist[o] != pos: continue
		var circ = circle.instance()
		circ.pos = pos+Vector2(500,500)
		circ.rad = onum
		circ.col = Color(1,1,1,1)
		self.add_child(circ)
		onum += 2
