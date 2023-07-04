extends Node2D

var _UNIDATA = {}
var _JUMPDATA = {}
var genSys = PoolStringArray()
var uncharSys = PoolStringArray()
var nodSys = {}
var jumNodCor = {}
var loadPage = 1
var curVer

var input = true
var lastFocus = null

var oneShot = true

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

var AS = AStar2D.new()
var aspoints = {}

var focusCirc

signal universe_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	input = false
	API.connect("list_systems_complete",self,"loadUNIVERSE")
	API.connect("get_status_complete",self,"setUNIVERSE_VERSION")
	API.connect("get_jump_gate_complete",self,"writeJUMPS")
	Automation.connect("ERROR",self,"writeJUMPS")
	
	Agent.connect("exitJumpgate",self,"exitUNI")
	
	API.get_status(self)
	yield(API,"get_status_complete")
	$Camera2D.zoom = Vector2(90,90)
	$Camera2D.position = Vector2.ZERO
	
	focusCirc = circle.instance()
	focusCirc.rect_global_position = Vector2.ZERO
	focusCirc.pos = Vector2.ZERO#pos+Vector2(500,500)
	focusCirc.rad = 2000
	focusCirc.col = Color(1,1,1,0.1)
	focusCirc.width = 0.3
	self.add_child(focusCirc)
	dispRange("OFF")
	
	#yield(get_tree().create_timer(10),"timeout")
	
	#getUNIVERSE()

func setUNIVERSE_VERSION(data):
	curVer = data["resetDate"]

func getUNIVERSE():
	if Save.universe["version"] == null: 
		Save.loadUniverse()
		Save.loadJump()
		yield(get_tree(),"idle_frame")
	if (Save.universe["version"] == null) or (Time.get_unix_time_from_datetime_string(curVer) > Time.get_unix_time_from_datetime_string(Save.universe["version"])):
		API.list_systems(self)
	else:
		emit_signal("universe_loaded")
		_UNIDATA = Save.universe["data"]
		if Save.jump["data"] != null:
			_JUMPDATA = Save.jump["data"]
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
#	$Camera2D.zoom = Vector2(90.1,90.1)
#	$Camera2D.position = Vector2.ZERO
#	if !nodSys.empty(): $Camera2D.position = nodSys[Agent.CurrentSystem].rect_position
	input = true
	for s in _UNIDATA:
		if genSys.has(s): continue
		#yield(get_tree(),"idle_frame")
		fat += 1
		
		var system = circleTEX.instance()
		system.name = s
		system.setLabel(s)
		system.hideLabel()
		system.add_to_group("Stars")
		system.rect_global_position = Vector2(_UNIDATA[s]["x"],_UNIDATA[s]["y"])
		system.changeSize(3)
		system.modulate = Color(1,1,1,0.2)
		
		for w in _UNIDATA[s]["waypoints"]:
			if w["type"] == "JUMP_GATE":
				system.modulate = Color(1,1,1,1)
				var newS = str(s).replace("-",str("-[color=",Color(SCM[_UNIDATA[s]["type"]]["bg"]),"]"))
				if s == Agent.HQSys: system.setLabel("[wave][b]HOME")
				else: system.setLabel(newS)
				#system.setLabel(str("[b]",s))
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
		var twee = get_tree().create_tween()
		twee.tween_property(system,"rect_scale",Vector2(100,100),0.1).set_ease(Tween.EASE_IN_OUT)
		twee.chain().tween_property(system,"rect_scale",Vector2(16,16),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
		
		genSys.push_back(s)
		nodSys[s] = system
		if fat > 50:
			fat = 0
			yield(get_tree(),"idle_frame")
			#yield(get_tree().create_timer(0.1),"timeout")
	
	print("finished generating")
	
	if oneShot:
		var camtwee = get_tree().create_tween()
		camtwee.tween_property($Camera2D,"zoom",Vector2(0.5,0.5),5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		if Agent.AgentCredits.is_valid_float(): camtwee.parallel().tween_property($Camera2D,"position",nodSys[Agent.CurrentSystem].rect_position,5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		camtwee.parallel().tween_property($CanvasLayer/Control,"modulate",Color(1,1,1,0),5)
		yield(camtwee,"finished")
		yield(get_tree(),"idle_frame")
		labels("ON")
		oneShot = false
	
	yield(get_tree(),"idle_frame")
	if jumNodCor.size() == 0:
		generateJUMPS()
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

func filterUNI(condition, invert = false):
	condition = str(condition)
	if condition == "OFF": unFilterUNI()
	if !condition.is_valid_integer() and !condition in ["PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]:
		return
	
	var count = 0
	if condition.is_valid_integer():
		match invert:
			true:
				for s in _UNIDATA:
					if _UNIDATA[s]["waypoints"].size() > int(condition): 
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
					else: count += 1
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter removed ",12000 - count," stars from total."),6)
			false:
				for s in _UNIDATA:
					if _UNIDATA[s]["waypoints"].size() < int(condition): 
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
					else: count += 1
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter removed ",12000 - count," stars from total."),6)
	elif condition in ["PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL"]:
		match invert:
			true:
				for s in _UNIDATA: for w in _UNIDATA[s]["waypoints"]: 
					if w["type"] == condition: 
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
					else: count += 1
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter left ",count," waypoints."),6)
			false:
				for s in _UNIDATA: 
					var keep = false
					for w in _UNIDATA[s]["waypoints"]: 
						if w["type"] == condition: 
							keep = true
							count += 1
					
					if !keep:
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter left ",count," waypoints."),6)
	elif condition in ["NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]:
		if condition == "NEBULAstar": condition = "NEBULA"
		match invert:
			true:
				for s in _UNIDATA: 
					if _UNIDATA[s]["type"] == condition: 
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
					else: count += 1
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter left ",count," waypoints."),6)
			false:
				for s in _UNIDATA: 
					var keep = false
					if _UNIDATA[s]["type"] == condition: 
						keep = true
						count += 1
					
					if !keep:
						nodSys[s].hide()
						if jumNodCor.has(s): for l in jumNodCor[s]:
							l.hide()
				get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter left ",count," waypoints."),6)
		get_tree().call_group("cmd","notify",str("[color=#FFBF00]@filter removed ",12000 - count," stars from total."),6)

func unFilterUNI():
	for s in _UNIDATA:
		nodSys[s].show()
		if jumNodCor.has(s): for l in jumNodCor[s]: l.show()

func labels(state):
	match state:
		"ON": 
			#get_tree().call_group("Stars","showLabel")
			var fat = 0
			for s in $Stars.get_children():
				fat += 1
				s.showLabel()
				if fat > 300:
					fat = 0
					yield(get_tree(),"idle_frame")
			focusCirc.modulate = Color(1,1,1,1)
		"OFF": 
			get_tree().call_group("Stars","hideLabel")
			focusCirc.modulate = Color(1,1,1,0)

func dispRange(state, starSym = Agent.HQSys, radius = 2000):
	match state:
		"ON":
			if starSym in ["LAST","RECENT"] and lastFocus != null:
				starSym = lastFocus
			elif starSym in ["LAST","RECENT"]: starSym = Agent.CurrentSystem
			
			if starSym in ["SELECTED","THAT"] and !rect_selected.empty():
				starSym = rect_selected[0]
			elif starSym in ["SELECTED","THAT"]: starSym = Agent.CurrentSystem
			
			if !_JUMPDATA.has(starSym): return
			var twee = get_tree().create_tween()
			var new_scale = Vector2((float(radius)/2000.0),(float(radius)/2000.0))
			focusCirc.rect_scale = Vector2(0.005,0.005)
			focusCirc.rect_pivot_offset = Vector2.ZERO#Vector2(focusCirc.rect_size.x/2.0,focusCirc.rect_size.y/2.0)
			twee.tween_property(focusCirc,"rect_position",nodSys[starSym].rect_position,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			twee.parallel().tween_property(focusCirc,"modulate",Color(1,1,1,1),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			twee.tween_property(focusCirc,"rect_scale",new_scale,0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		"OFF":
			var twee = get_tree().create_tween()
			twee.parallel().tween_property(focusCirc,"modulate",Color(1,1,1,0),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)

func focusStar(starSym):
	#if !nodSys.has(starSym): return
	if starSym in ["RANDOM","RAND","R","IDK","SOMETHING"]: #Random Focus
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,genSys.size()-1)
		starSym = genSys[new]
	if starSym in ["PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL"]: #Focus Random with Waypoint Type
		var temp = []
		for s in _UNIDATA: for w in _UNIDATA[s]["waypoints"]: if w["type"] == starSym: temp.push_back(s)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,(temp.size()-1))
		if temp.size() != 0: starSym = temp[new]
		else: 
			get_tree().call_group("cmd","notify",str("[color=#FFBF00]Could not focus. There are zero avalible stars with '",starSym,"'"),5)
			starSym = "HOME"
	if starSym in ["NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]: #Focus Random with System Type
		var temp = []
		if starSym == "NEBULAstar": starSym = "NEBULA"
		for s in _UNIDATA: if _UNIDATA[s]["type"] == starSym: temp.push_back(s)
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,(temp.size()-1))
		if temp.size() != 0: starSym = temp[new]
		else:
			get_tree().call_group("cmd","notify",str("[color=#FFBF00]Could not focus. There are zero avalible stars with '",starSym,"'"),5) 
			starSym = "HOME"
	if starSym in ["LAST","RECENT","SELECTED","THAT"]:
		match starSym:
			"LAST","RECENT": 
				if lastFocus != null: starSym = lastFocus 
				else: starSym = Agent.CurrentSystem
			"SELECTED","THAT":
				if !rect_selected.empty(): starSym = rect_selected[0]
				else: starSym = Agent.CurrentSystem
	if starSym in ["HOME","ZERO"]:
		match starSym:
			"ZERO":
				$CanvasLayer/SystemPopover.animateOUT()
				
				var twee = get_tree().create_tween()
				twee.tween_property($Camera2D,"position",Vector2(0,0),3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
				if $Camera2D.zoom.x > 2: twee.tween_property($Camera2D,"zoom",Vector2(1,1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
#				twee.parallel().tween_property(focusCirc,"rect_position",Vector2(0,0),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
#				twee.parallel().tween_property(focusCirc,"modulate",Color(1,1,1,1),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			"HOME":
				if _JUMPDATA.has(Agent.HQSys): $CanvasLayer/SystemPopover.setdat(_UNIDATA[Agent.HQSys],_JUMPDATA[Agent.HQSys]["connectedSystems"].size())
				else: $CanvasLayer/SystemPopover.setdat(_UNIDATA[Agent.HQSys],0)
				
				var twee = get_tree().create_tween()
				twee.tween_property($Camera2D,"position",nodSys[Agent.HQSys].rect_position,3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
				if $Camera2D.zoom.x > 2: twee.tween_property($Camera2D,"zoom",Vector2(1,1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
				dispRange("ON",Agent.HQSys,11)
#				twee.parallel().tween_property(focusCirc,"rect_position",nodSys[Agent.HQSys].rect_position,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
#				twee.parallel().tween_property(focusCirc,"modulate",Color(1,1,1,1),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
				lastFocus = Agent.HQSys
		return
	
	if _JUMPDATA.has(starSym): $CanvasLayer/SystemPopover.setdat(_UNIDATA[starSym],_JUMPDATA[starSym]["connectedSystems"].size())
	else: $CanvasLayer/SystemPopover.setdat(_UNIDATA[starSym],0)
	
	lastFocus = starSym
	var twee = get_tree().create_tween()
	twee.tween_property($Camera2D,"position",nodSys[starSym].rect_position,3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	if $Camera2D.zoom.x > 2: twee.tween_property($Camera2D,"zoom",Vector2(1,1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	dispRange("ON",starSym,11)
#	twee.parallel().tween_property(focusCirc,"rect_position",nodSys[starSym].rect_position,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
#	twee.parallel().tween_property(focusCirc,"modulate",Color(1,1,1,1),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)

func bookmarkStar(starSym):
	$CanvasLayer/Control2/Bookmarks.preview()
	if starSym == "SHOW": return
	if starSym == "CLEAR":
		$CanvasLayer/Control2/Bookmarks.clear()
		return
	if starSym in ["LAST","RECENT"]:
		if lastFocus == null: return
		$CanvasLayer/Control2/Bookmarks.addBookmark(_UNIDATA[lastFocus])
		return
	if starSym in ["SELECTED","THAT"]:
		if rect_selected.empty(): return
		for sym in rect_selected:
			$CanvasLayer/Control2/Bookmarks.addBookmark(_UNIDATA[sym])
		return
	if starSym in ["RANDOM","RAND","R","IDK","SOMETHING"]: #Random Bookmark
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,genSys.size()-1)
		starSym = genSys[new]
	$CanvasLayer/Control2/Bookmarks.addBookmark(_UNIDATA[starSym])

func unmarkStar(starSym):
	$CanvasLayer/Control2/Bookmarks.preview()
	if starSym in ["SELECTED","THAT"]:
		if rect_selected.empty(): return
		for sym in rect_selected:
			$CanvasLayer/Control2/Bookmarks.removeBookmark(_UNIDATA[sym])
		return
	$CanvasLayer/Control2/Bookmarks.removeBookmark(starSym)

var curSys
var waiting_j
signal JUMP_STORED
func generateJUMPS():
#	Save.call_deferred("loadJump")
#	yield(Save,"loadDataComplete")
	
	get_tree().call_group("loading","startload")
	if (Save.jump["version"] == null) or Time.get_unix_time_from_datetime_string(Save.jump["version"]) < Time.get_unix_time_from_datetime_string(curVer):
		var tempDATA = []
		for s in _UNIDATA:
			tempDATA.push_back([s,_UNIDATA[s]])
		
		#Get Jump Gates
		var jumpgates = []
		for s in tempDATA:
			for w in s[1]["waypoints"]: if w["type"] == "JUMP_GATE": jumpgates.push_back(s)
		
		#Create Jumpdata
		for a in jumpgates: 
			var aPos = Vector2(a[1]["x"],a[1]["y"])
			_JUMPDATA[a[0]] = {"connectedSystems":[]}
			var aDat = _JUMPDATA[a[0]]
			for b in jumpgates:
				if a[0] == b[0]: continue
				var bPos = Vector2(b[1]["x"],b[1]["y"])
				if bPos.distance_to(aPos) <= 2000:
					var newEntry = b[1].duplicate()
					newEntry.erase("waypoints")
					newEntry["distance"] = bPos.distance_to(aPos)
					aDat["connectedSystems"].push_back(newEntry)
		
		Save.jump["version"] = curVer
		Save.jump["data"] = _JUMPDATA
		Save.writeJump()
		print("finished loading")
		#yield(get_tree(),"idle_frame")
		
		tempDATA = []
		jumpgates = []
	
	#Draw Jumps
	var fat = 0
	for j in _JUMPDATA:
		fat += 1
		var idx = aspoints.size()
		drawJUMP(_UNIDATA[j],_JUMPDATA[j])
		AS.add_point(idx,Vector2(_UNIDATA[j]["x"],_UNIDATA[j]["y"]),1.0)
		#aspoints.push_back([j,Vector2(_UNIDATA[j]["x"],_UNIDATA[j]["y"])])
		aspoints[j] = [Vector2(_UNIDATA[j]["x"],_UNIDATA[j]["y"]),idx]
		if fat > 50:
			fat = 0
			yield(get_tree(),"idle_frame")
	
	#Finish AS setup
	for point in aspoints:
		var idx = aspoints[point][1]
		for j in _JUMPDATA[point]["connectedSystems"]:
			var cidx = aspoints[j["symbol"]][1]
			AS.connect_points(idx, cidx, false)
			#print(AS.are_points_connected(idx,cidx))
			#yield(get_tree(),"idle_frame")
			#print(idx," ",cidx)
	
	#print(AS.get_point_count())
	#print(AS.are_points_connected(aspoints["X1-UZ17"][1],aspoints["X1-NG51"][1]))
	#getPath(Agent.HQSys,"X1-YU85")
	
	get_tree().call_group("loading","finishload")

func getPath(fromSym,toSym,noRec = false,noAnim = false):
	#Clear oldpath
	if !noRec: for l in $DispPath.get_children():
		l.queue_free()
	
	if fromSym in ["RAND","R","IDK","SOMETHING"]:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,_JUMPDATA.size()-1)
		fromSym = _JUMPDATA.keys()[new]
	
	if toSym in ["RAND","R","IDK","SOMETHING"]:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var new = rng.randi_range(0,_JUMPDATA.size()-1)
		toSym = _JUMPDATA.keys()[new]
	
	if fromSym == toSym:
		get_tree().call_group("cmd","notify","[shake][color=#EE4B2B]Path failed, fromSym == toSym.",4)
	
	#Reweight points
	var aPos = Vector2(_UNIDATA[fromSym]["x"],_UNIDATA[fromSym]["y"])
	for point in aspoints:
		if point == fromSym: continue
		var bPos = Vector2(_UNIDATA[point]["x"],_UNIDATA[point]["y"])
		var dist = aPos.distance_to(bPos)
		var idx = aspoints[point][1]
		
		AS.set_point_weight_scale(idx, dist)
	
	#get path
	var path = AS.get_id_path(aspoints[fromSym][1],aspoints[toSym][1])
	var rerouting = false
	if path.empty() and !_JUMPDATA[toSym]["connectedSystems"].empty():
		rerouting = true
		var oldPos = Vector2(_UNIDATA[toSym]["x"],_UNIDATA[toSym]["y"])
		var newToSym
		var tested = []
		var possibleNear = []
		for t in _JUMPDATA[toSym]["connectedSystems"]:
			tested.push_back(t["symbol"])
		for j in _JUMPDATA:
			if j in tested and noRec: continue
			if j == fromSym: continue
			var dist = Vector2(_UNIDATA[j]["x"],_UNIDATA[j]["y"]).distance_to(oldPos)
			possibleNear.push_back([j,dist])
		possibleNear.sort_custom(self,"reRouteSort")
		#print(possibleNear)
		#yield(get_tree(),"idle_frame")
		while rerouting:
			if possibleNear.empty():
				noRec = true
				break
			newToSym = possibleNear.pop_back()[0]
			var newPath = AS.get_id_path(aspoints[fromSym][1],aspoints[newToSym][1])
			if newPath.empty():
				continue
			else:
				path = newPath
				if !noRec:
					getPath(toSym,fromSym, true)
				break
	elif path.empty():
		if !noRec:
			getPath(toSym,fromSym, true)
		noRec = true
	
	#drawPath
	var pidx1 = 0
	var pidx2 = 1
	
	if !noRec and !noAnim:
		var twee = get_tree().create_tween()
		var dur = clamp($Camera2D.position.distance_to(AS.get_point_position(path[pidx1])) * 0.0015,0.5,2)
		twee.tween_property($Camera2D,"position",AS.get_point_position(path[pidx1]),dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished") #@path X1-SR60 X1-NM49
	
	for c in path:
		var line = Line2D.new()
		line.width = clamp($Camera2D.zoom.x + 2,2,90)
		if rerouting:
			line.default_color = Color(1,117/255,24/255,1) #ORANGE
		else: line.default_color = Color(0.6,0,1,1) #(0.6,0,1) PURPLE
		line.add_point(AS.get_point_position(path[pidx1]))
		if !noRec and !noAnim:
			line.add_point(AS.get_point_position(path[pidx1])+Vector2(1,1))
		else: line.add_point(AS.get_point_position(path[pidx2]))
		$DispPath.add_child(line)
		if !noRec and !noAnim:
			var twee = get_tree().create_tween()
			var dur = clamp(AS.get_point_position(path[pidx1]).distance_to(AS.get_point_position(path[pidx2])) * 0.0005,0.1,1) + 0.5 - clamp($Camera2D.zoom.x /90,0,1)
			twee.tween_method(self,"tweenJUMP",AS.get_point_position(path[pidx1]),AS.get_point_position(path[pidx2]),dur,[line]).set_ease(Tween.EASE_OUT_IN)
			if pidx2 == path.size()-1:
				twee.parallel().tween_property($Camera2D,"position",AS.get_point_position(path[pidx2]),dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			else: twee.parallel().tween_property($Camera2D,"position",AS.get_point_position(path[pidx2]),dur)
			yield(twee,"finished") #@path X1-SR60 X1-NM49
		pidx1 += 1
		pidx2 += 1
		if pidx2 > path.size()-1: break
	print("finished Pathfinding ",fromSym,"->",toSym)

static func reRouteSort(a,b):
	if a[1] > b[1]: return true
	return false

func writeJUMPS(data):
	if !waiting_j: return
	waiting_j = false
	
	if _JUMPDATA.has("raw"):
		_JUMPDATA["raw"].push_back(data)
	else:
		_JUMPDATA["raw"] = []
		_JUMPDATA["raw"].push_back(data)
	
	emit_signal("JUMP_STORED")

func drawJUMP(sys,data):
	#var sys = curSys
	for s in data["connectedSystems"]:
		if s["distance"] > 500: continue #500
		var conpass = false
		for l in $Lines.get_children():
			if (l.points[0] == Vector2(sys["x"],sys["y"]) and l.points[1] == Vector2(s["x"],s["y"])) or (l.points[1] == Vector2(sys["x"],sys["y"]) and l.points[0] == Vector2(s["x"],s["y"])):
				conpass = true
				break
		if conpass: continue
				
		var line = Line2D.new()
		var ve = VisibilityEnabler2D.new()
		line.width = 3.0 - clamp(pow((float(s["distance"]) * 0.01),1.2), 0.1,2.5)
		line.default_color = Color(1,1,1,(1.0 - clamp(pow((float(s["distance"]) * 0.01),2), 0.01,0.95))) #(0.6,0,1) PURPLE
		line.add_point(Vector2(sys["x"],sys["y"]))
		line.add_point(Vector2(s["x"],s["y"]))
		$Lines.add_child(line)
		line.add_child(ve)
		
		if jumNodCor.has(sys["symbol"]):
			jumNodCor[sys["symbol"]].push_back(line)
		else: jumNodCor[sys["symbol"]] = [line]
		
		if jumNodCor.has(s["symbol"]):
			jumNodCor[s["symbol"]].push_back(line)
		else: jumNodCor[s["symbol"]] = [line]
		yield(get_tree(),"idle_frame")

func tweenJUMP(newEnd : Vector2,line : Line2D):
	line.call_deferred("set_point_position",1,newEnd)

func loadUNIVERSE(data):
	for s in data["data"]:
		_UNIDATA[s["symbol"]] = s
	
	var size = _UNIDATA.size()
	if data["meta"]["total"] > size:
		loadPage = data["meta"]["page"] + 1
		API.list_systems(self, loadPage)
		
		$CanvasLayer/UniverseLoad.show()
		$CanvasLayer/UniverseLoad/ProgressBar.value = (size/float(data["meta"]["total"]))*100
		$CanvasLayer/UniverseLoad/LoadProgress.bbcode_text = str("[center][color=#69696b]",size,"/",data["meta"]["total"])
		#print(size)
	else:
		$CanvasLayer/UniverseLoad.hide()
		emit_signal("universe_loaded")
		Save.universe["version"] = curVer
		Save.universe["data"] = _UNIDATA
		Save.writeUniverse()
		yield(get_tree(),"idle_frame")
		generateUNIVERSE()

var dragging = false  # Are we currently dragging?
var rect_selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = Polygon2D.new()  # Collision shape for drag box.

func selection():
	if Input.is_action_just_pressed("ClickRight") and $Camera2D.zoom.x <= 10:
		# We only want to start a drag if there's no selection.
		#if rect_selected.size() == 0:
			dragging = true
			drag_start = get_global_mouse_position()#get_global_mouse_position()#get_viewport().get_mouse_position()
	elif Input.is_action_just_pressed("ClickRight") and $Camera2D.zoom.x > 10:
		#$Camera2D.zoom = Vector2(10,10)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(10,10),0.2)
		get_tree().call_group("cmd","notify","[shake][color=#EE4B2B]Zoom must be [b]10[/b]x or less to batch select stars.",4)
	elif dragging and Input.is_action_just_released("ClickRight"):
		# Button released while dragging.
		dragging = false
		update()
		selectionEND(get_global_mouse_position())
	if Input.is_action_pressed("ClickRight") and dragging:
		update()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color(.5, .5, .5), false)

func selectionEND(drag_end):
	#select_rect.extents = (drag_start - drag_end) / 2
	rect_selected.clear()
	var v2 = Vector2(drag_start.x,drag_end.y)
	var v4 = Vector2(drag_end.x,drag_start.y)
	select_rect.polygon = PoolVector2Array([drag_start, v2, drag_end, v4])
	for s in nodSys:
		if Geometry.is_point_in_polygon(nodSys[s].rect_position,PoolVector2Array([drag_start, v2, drag_end, v4])) and nodSys[s].visible:
			rect_selected.push_back(s)
	if rect_selected.size() == 1:
		#get_tree().call_group("cmd","notify",str("[color=#FFBF00]Selected ",rect_selected.size()," system: ", str(rect_selected).substr(0,20)),13)
		if _JUMPDATA.has(rect_selected[0]): $CanvasLayer/SystemPopover.setdat(_UNIDATA[rect_selected[0]],_JUMPDATA[rect_selected[0]]["connectedSystems"].size())
		else: $CanvasLayer/SystemPopover.setdat(_UNIDATA[rect_selected[0]],0)
		
		var pos = get_viewport().get_mouse_position()
		pos.x = clamp(pos.x,(-get_viewport_rect().size.x) + 100,get_viewport_rect().size.x - 100)
		pos.y = clamp(pos.y,(-get_viewport_rect().size.y) + 100,get_viewport_rect().size.y - 100)
		$CanvasLayer/Control2/Quickmenu.rect_position = pos
		$CanvasLayer/Control2/Quickmenu.show()
		if !rect_selected[0] in [lastFocus,null] and _JUMPDATA.has(rect_selected[0]) and _JUMPDATA.has(lastFocus): $CanvasLayer/Control2/Quickmenu.single(rect_selected[0],true)
		else: $CanvasLayer/Control2/Quickmenu.single(rect_selected[0])
	else:
		$CanvasLayer/SystemPopover.animateOUT()
		get_tree().call_group("cmd","notify",str("[color=#FFBF00]Selected ",rect_selected.size()," systems, ", str(rect_selected).substr(0,65)),13)
		
		if rect_selected.size() > 0:
			var pos = get_viewport().get_mouse_position()
			pos.x = clamp(pos.x,(-get_viewport_rect().size.x) + 100,get_viewport_rect().size.x - 100)
			pos.y = clamp(pos.y,(-get_viewport_rect().size.y) + 100,get_viewport_rect().size.y - 100)
			$CanvasLayer/Control2/Quickmenu.rect_position = pos
			$CanvasLayer/Control2/Quickmenu.show()
			$CanvasLayer/Control2/Quickmenu.multi(rect_selected)
		else: $CanvasLayer/Control2/Quickmenu.hide()
	
	#print(drag_start," ",drag_end,"/",rect_selected)

func _process(delta):
	if input:
		mapZoom()
		mapTranslate()
		selection()
	cullStars()

func mapZoom():
	if Input.is_action_just_pressed("MAPzoom_out") or Input.is_action_just_released("MAPscroll_out"): #OUT
		var newZ = clamp(($Camera2D.zoom.x+(0.5*$Camera2D.zoom.x)),0.3,90)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
	if Input.is_action_just_pressed("MAPzoom_in") or Input.is_action_just_released("MAPscroll_in"): #IN
		var newZ = clamp(($Camera2D.zoom.x-(0.5*$Camera2D.zoom.x)),0.3,90)
		get_tree().create_tween().tween_property($Camera2D,"zoom",Vector2(newZ,newZ),0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		
var oldzoom = 0
func cullStars():
	if $Camera2D.zoom.x == oldzoom: return
	else: oldzoom = $Camera2D.zoom.x
	#print($Lines.get_child_count())
	if $Stars.get_child_count() < 50: return
	
	var newZoom = clamp($Camera2D.zoom.x * 0.3,1,20)
	var newWidth = clamp($Camera2D.zoom.x + 2,2,90)
	for s in $Stars.get_children():
		s.rect_scale = Vector2(newZoom,newZoom)
	$ColorRect.color = Color("#28282b").darkened(clamp($Camera2D.zoom.x * 0.01,0,1))
		#$ColorRect.color = Color("#000000").lightened(clamp($Camera2D.zoom.x * 0.01,0,0.2))
	for l in $DispPath.get_children():
		l.width = newWidth
	
	
	if $Camera2D.zoom.x > 2 and $Lines.visible:
		$Lines.hide()
		get_tree().call_group("Stars","hideLabel")
	elif !$Lines.visible and $Camera2D.zoom.x < 2: 
		$Lines.show()
		#get_tree().call_group("Stars","showLabel")
	
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
	$CanvasLayer/Control2/LastFocus.bbcode_text = str("[right][color=#69696b] recent. ",lastFocus)
	$Camera2D.position.x = clamp($Camera2D.position.x,-60000,60000)
	$Camera2D.position.y = clamp($Camera2D.position.y,-60000,60000)

func exitUNI():
	input = false
	var twee = get_tree().create_tween()
#	$Camera2D.zoom = Vector2(90.1,90.1)
#	$Camera2D.position = Vector2.ZERO
	#twee.tween_property($Camera2D,"position",nodSys[Agent.CurrentSystem].rect_position,1)
	
	#twee.tween_property(nodSys[Agent.CurrentSystem],"rect_scale",Vector2(30,30),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	twee.tween_property($Camera2D,"position",nodSys[Agent.CurrentSystem].rect_position,1)
	twee.parallel().tween_property($Camera2D,"zoom",Vector2(0.1,0.1),2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	yield(twee,"finished")
	labels("ON")
#	yield(get_tree().create_timer(2),"timeout")
#	$Camera2D.zoom = Vector2(90.1,90.1)
#	var newZoom = clamp($Camera2D.zoom.x * 0.3,1,20)
#	nodSys[Agent.CurrentSystem].rect_scale = Vector2(newZoom,newZoom)
