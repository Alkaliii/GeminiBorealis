extends Node2D

var _UNIDATA = {}
var genSys = PoolStringArray()
var loadPage = 1
var curVer

const circle = preload("res://Interface/CIRCLE.tscn")
const circleTEX = preload("res://Interface/CIRCLETEX.tscn")
const SCM = {
	"NEUTRON_STAR":
		{"text":"#f8fafc","bg":"#475569"},
	"RED_STAR":
		{"text":"#fef2f2","bg":"#b91c1c"},
	"ORANGE_STAR":
		{"text":"#431407","bg":"#fdba74"},
	"BLUE_STAR":
		{"text":"#083344","bg":"#22d3ee"},
	"YOUNG_STAR":
		{"text":"#022c22","bg":"#6ee7b7"},
	"WHITE_DWARF":
		{"text":"#030712","bg":"#f9fafb"},
	"BLACK_HOLE":
		{"text":"#f9fafb","bg":"#030712"},
	"HYPERGIANT":
		{"text":"#2e1065","bg":"#c4b5fd"},
	"NEBULA":
		{"text":"#fdf2f8","bg":"#db2777"},
	"UNSTABLE":
		{"text":"#eef2ff","bg":"#4f46e5"}
}


signal universe_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	API.connect("list_systems_complete",self,"loadUNIVERSE")
	API.connect("get_status_complete",self,"setUNIVERSE_VERSION")
	API.connect("get_jump_gate_complete",self,"drawJUMP")
	
	API.get_status(self)
	yield(API,"get_status_complete")
	
	getUNIVERSE()

func setUNIVERSE_VERSION(data):
	curVer = data["resetDate"]

func getUNIVERSE():
	if Save.universe["version"] == null: Save.loadUniverse()
	yield(get_tree(),"idle_frame")
	if (Save.universe["version"] == null) or (Time.get_unix_time_from_datetime_string(curVer) > Time.get_unix_time_from_datetime_string(Save.universe["version"])):
		API.list_systems(self)
	else:
		emit_signal("universe_loaded")
		_UNIDATA = Save.universe["data"]
		uselessSort()
		yield(get_tree(),"idle_frame")
		generateUNIVERSE()

func uselessSort():
	var temp = []
	var temp2 = {}
	for s in _UNIDATA:
		temp.push_back([s,_UNIDATA[s]])
	temp.sort_custom(self, "centerSort")
	yield(get_tree(),"idle_frame")
	for s in temp:
		temp2[s[0]] = s[1]
	_UNIDATA = temp2

static func centerSort (a,b):
	if Vector2(a[1]["x"],a[1]["y"]).distance_to(Vector2.ZERO) < Vector2(b[1]["x"],b[1]["y"]).distance_to(Vector2.ZERO):
		return true
	return false

func generateUNIVERSE():
	var fat = 0
	for s in _UNIDATA:
		if genSys.has(s): continue
		fat += 1
		
		var system = circleTEX.instance()
		#var twee = get_tree().create_tween()
		system.name = s
		system.setLabel(s)
		system.add_to_group("Stars")
		system.rect_global_position = Vector2(_UNIDATA[s]["x"],_UNIDATA[s]["y"])
		system.changeSize(3)
		system.modulate = Color(1,1,1,0.2)
		
		for w in _UNIDATA[s]["waypoints"]:
			if w["type"] == "JUMP_GATE":
				system.modulate = Color(1,1,1,1)
				system.setLabel(str("[b]",s))
				#system.setOutCol(Color(SCM[_UNIDATA[s]["type"]]["bg"]))
				#system.setLabel(str("[color=",SCM[_UNIDATA[s]["type"]]["bg"],"]",s))
				#system.growLabel()
				system.changeSize(getRad(_UNIDATA[s]["type"],_UNIDATA[s]["symbol"])) #8
				break
#		system.pos = Vector2.ZERO
#		system.rad = 5
#		system.col = Color(1,1,1,1)
#		system.fill = true
		$Stars.add_child(system)
#		twee.tween_property(system,"rect_scale",Vector2(100,100),0.2).set_ease(Tween.EASE_IN_OUT)
#		twee.chain().tween_property(system,"rect_scale",Vector2(16,16),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		genSys.push_back(s)
		if fat > 3000:
			fat = 0
			yield(get_tree().create_timer(0.1),"timeout")
	
	print("finished generating")
	
	generateJUMPS()
	yield(get_tree(),"idle_frame")
	var camtwee = get_tree().create_tween()
	camtwee.tween_property($Camera2D,"zoom",Vector2(1.5,1.5),10).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	camtwee.parallel().tween_property($CanvasLayer/Control,"modulate",Color(1,1,1,0),5)
#	camtwee.tween_property($Camera2D,"zoom",Vector2(12,12),2).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CIRC)
#	camtwee.chain().tween_property($Camera2D,"zoom",Vector2(24,24),2).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CIRC)
#	camtwee.chain().tween_property($Camera2D,"zoom",Vector2(48,48),2).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CIRC)
#	camtwee.chain().tween_property($Camera2D,"zoom",Vector2(90,90),6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
#	camtwee.chain().tween_property($Camera2D,"zoom",Vector2(2,2),1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	

func getRad(type, symbol):
	var lastint = 0
	var firstint = null
	for c in symbol:
		if c.is_valid_integer():
			if firstint == null:
				firstint = int(c)
				continue
			else: lastint = int(c)
	var mod = float(firstint-lastint)
	
	match type:
		"NEUTRON_STAR": return (4 + (mod/2))
		"RED_STAR": return (5 + (mod/2))
		"ORANGE_STAR": return (6 + (mod/2))
		"BLUE_STAR": return (9 + (mod/2))
		"YOUNG_STAR": return (5 + (mod/2))
		"WHITE_DWARF": return (4 + (mod/2))
		"BLACK_HOLE": return (10 + (mod/2))
		"HYPERGIANT": return (11 + (mod/2))
		"NEBULA": return (11 + (mod/2))
		"UNSTABLE": return (8 + (mod/2))

var curSys
func generateJUMPS():
	var tempDATA = []
	for s in _UNIDATA:
		tempDATA.push_back([s,_UNIDATA[s]])
	for a in tempDATA:
		yield(get_tree(),"idle_frame")
		for w in a[1]["waypoints"]:
			if w["type"] == "JUMP_GATE":
				curSys = a[1]
				API.get_jump_gate(self,a[1]["symbol"],w["symbol"])
				yield(API,"get_jump_gate_complete")
#		for b in tempDATA:
#			$Camera2D.position = Vector2(a[1]["x"],a[1]["y"])
#			if Vector2(b[1]["x"],b[1]["y"]).distance_to(Vector2(a[1]["x"],a[1]["y"])) <= 50:
#				yield(get_tree(),"idle_frame")
#				var line = Line2D.new()
#				line.width = 3
#				line.default_color = Color(1,1,1)
#				line.add_point(Vector2(a[1]["x"],a[1]["y"]))
#				line.add_point(Vector2(b[1]["x"],b[1]["y"]))
#				$Lines.add_child(line)
#				continue
#			elif Vector2(b[1]["x"],b[1]["y"]).distance_to(Vector2(a[1]["x"],a[1]["y"])) <= 100:
#				yield(get_tree(),"idle_frame")
#				var line = Line2D.new()
#				line.width = 1
#				line.default_color = Color(1,1,1,0.5)
#				line.add_point(Vector2(a[1]["x"],a[1]["y"]))
#				line.add_point(Vector2(b[1]["x"],b[1]["y"]))
#				$Lines.add_child(line)
#		tempDATA.erase(a)
	print("finished generating")

func drawJUMP(data):
	var sys = curSys
	for s in data["data"]["connectedSystems"]:
		if s["distance"] > 500: continue
		var conpass = false
		for l in $Lines.get_children():
			if (l.points[0] == Vector2(sys["x"],sys["y"]) and l.points[1] == Vector2(s["x"],s["y"])) or (l.points[1] == Vector2(sys["x"],sys["y"]) and l.points[0] == Vector2(s["x"],s["y"])):
				conpass = true
				break
		if conpass: continue
				
		var line = Line2D.new()
		var ve = VisibilityEnabler2D.new()
		line.width = 3.0 - clamp(pow((float(s["distance"]) * 0.01),1.2), 0.1,2.5)
		line.default_color = Color(0.6,0,1,(1.0 - clamp(pow((float(s["distance"]) * 0.01),2), 0.01,0.95)))
		line.add_point(Vector2(sys["x"],sys["y"]))
		line.add_point(Vector2(s["x"],s["y"]))
		$Lines.add_child(line)
		line.add_child(ve)

func tweenJUMP(newEnd : Vector2,line : Line2D):
	line.call_deferred("set_point_position",0,newEnd)

func loadUNIVERSE(data):
	for s in data["data"]:
		_UNIDATA[s["symbol"]] = s
	
	var size = _UNIDATA.size()
	if data["meta"]["total"] > size:
		loadPage = data["meta"]["page"] + 1
		API.list_systems(self, loadPage)
		print(size)
	else:
		emit_signal("universe_loaded")
		Save.universe["version"] = curVer
		Save.universe["data"] = _UNIDATA
		Save.writeUniverse()
		yield(get_tree(),"idle_frame")
		generateUNIVERSE()


func _process(delta):
	mapZoom()
	mapTranslate()
	cullStars()

func mapZoom():
	if Input.is_action_just_pressed("MAPzoom_out"): #OUT
		var newZ = clamp(($Camera2D.zoom.x+(0.5*$Camera2D.zoom.x)),0.3,90)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		
	if Input.is_action_just_pressed("MAPzoom_in"): #IN
		var newZ = clamp(($Camera2D.zoom.x-(0.5*$Camera2D.zoom.x)),0.3,90)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		
var oldzoom
func cullStars():
	if $Camera2D.zoom.x == oldzoom: return
	else: oldzoom = $Camera2D.zoom.x
	#print($Lines.get_child_count())
	if $Stars.get_child_count() < 50: return
	
	for s in $Stars.get_children():
		var newZoom = clamp($Camera2D.zoom.x * 0.17,1,15)
		s.rect_scale = Vector2(newZoom,newZoom)
		$ColorRect.color = Color("#28282b").darkened(clamp($Camera2D.zoom.x * 0.01,0,1))
		#$ColorRect.color = Color("#000000").lightened(clamp($Camera2D.zoom.x * 0.01,0,0.2))
	
	if $Camera2D.zoom.x > 2 and $Lines.visible:
		$Lines.hide()
		get_tree().call_group("Stars","hideLabel")
	elif !$Lines.visible and $Camera2D.zoom.x < 2: 
		$Lines.show()
		get_tree().call_group("Stars","showLabel")
	
#	var zooms = [0,10,20,30,40,50,60,70,80,90,100]
#	zooms.push_back($Camera2D.zoom.x)
#	zooms.sort()
#	match zooms.find($Camera2D.zoom.x):
#		0:
#			for s in $Stars.get_children():
#				if !s is Control: continue
#				s.rect_scale = Vector2(1,1)
#		1:
#			for s in $Stars.get_children():
#				if !s is Control: continue
#				s.rect_scale = Vector2(1,1)
#		2:
#			for s in $Stars.get_children():
#				if !s is Control: continue
#				s.rect_scale = Vector2(40,40)
#		3:
#			for s in $Stars.get_children():
#				if !s is Control: continue
#				s.rect_scale = Vector2(40,40)
#		4:
#			for s in $Stars.get_children():
#				if !s is Control: continue
#				s.rect_scale = Vector2(50,50)
#		_:
#			for s in $Stars.get_children():
#				if s is Camera2D: continue
#				s.rect_scale = Vector2(60,60)
		

func mapTranslate():
	if Input.is_action_pressed("MAPleft"):
		$Camera2D.position.x -= $Camera2D.zoom.x * 10
	if Input.is_action_pressed("MAPright"):
		$Camera2D.position.x += $Camera2D.zoom.x * 10
	if Input.is_action_pressed("MAPup"):
		$Camera2D.position.y -= $Camera2D.zoom.y * 10
	if Input.is_action_pressed("MAPdown"):
		$Camera2D.position.y += $Camera2D.zoom.y * 10
	$CanvasLayer/Control2/Coords.bbcode_text = str("[color=#69696b][b]x.[/b]",round($Camera2D.position.x),", [b]y.[/b]",round($Camera2D.position.y)," / (",round($Camera2D.zoom.x),"x)")
	$Camera2D.position.x = clamp($Camera2D.position.x,-60000,60000)
	$Camera2D.position.y = clamp($Camera2D.position.y,-60000,60000)
