extends Control

enum cmds {HELP, FILTER, INVERSE_FILTER, 
FOCUS, BOOKMARK, UNBOOKMARK, LABELS, 
PATH, RANGE, JUMP, WARP, EXIT}
# '@help' or 'help' / displays this menu, helpful.
# '@filter <condition>' (Int,Type,OFF) / filters which stars are displayed, additive.
# '@filter2 <condition>' (Int,Type,OFF) / like '@filter' but inverted, still additive.
# '@focus <systemSymbol>' (OFF) / moves the viewport to the system specified, nifty.
# '@bookmark <systemSymbol>' / saves a system for later in the bookmark (b) menu, handy.
# '@unmark <systemSymbol>' / removes a system that was saved for later, neat.
# '@labels <state>' (ON, OFF) / turns labels on or off, nice.
# '@path <from:systemSymbol> <to:systemSymbol>' / charts a jump path
# '@range <systemSymbol> <radius>' (OFF) / draws a circle with the radius specified
# '@jump <systemSymbol>' (Queried to select a ship or group)
# '@warp <waypointSymbol>' (Queried to select a ship or group) (waypoints can be gleamed from focus)
# '@exit' / exits the universe map, important.

export (NodePath) var Parent

onready var cmdline = $Line

var focused
var entered = false
var memory = PoolStringArray()
var memoryIdx = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("ui_up") and focused and memory.size() > memoryIdx+1:
		memoryIdx += 1
		cmdline.text = memory[memoryIdx]
	if Input.is_action_just_pressed("ui_down") and focused and memoryIdx-1 > -1:
		memoryIdx -= 1
		cmdline.text = memory[memoryIdx]
	elif Input.is_action_just_pressed("ui_down") and focused: 
		memoryIdx = -1
		cmdline.text = ""
	
	#yield(get_tree(),"idle_frame")
	if Input.is_action_just_released("repeatCMD") and !focused and !memory.empty():
		_on_Line_text_entered(memory[0])
		notify(str("repeating previously entered command: '",memory[0],"'"),1)

func _on_Line_text_entered(new_text : String):
	new_text = new_text.lstrip(" ").rstrip(" ")
	var valuesIndx = []
	var values = []
	var i = 0
	for s in new_text.count(" "):
		if valuesIndx.empty():
			valuesIndx.push_back(new_text.find(" "))
		else:
			valuesIndx.push_back(new_text.find(" ",valuesIndx[valuesIndx.size()-1]+1))
	#print(valuesIndx)
	
	var firstSPC : int = new_text.find(" ")
	var nextSPC : int = 0
	var command : String
	var value : String
	
	if firstSPC == -1:
		command = new_text
		if command == "":
			cmdline.release_focus()
			return
	else:
		command = new_text.substr(0, firstSPC)
#		value = new_text.substr(firstSPC + 1)
#		value = value.lstrip(" ")
		
		for v in valuesIndx:
			var LEN = -1
			if valuesIndx.size() > valuesIndx.find(v)+1:
				LEN = (valuesIndx[valuesIndx.find(v)+1] - v)-1
			values.push_back(new_text.substr(v+1,LEN))
		value = values[0]
			#print(LEN," /",new_text.substr(v+1,LEN),"/")
		#print(values)
	
	if run_command(command, value, values) == "":
		memoryIdx = -1
		return
	cmdline.release_focus()
	cmdline.text = ""
	memoryIdx = -1

func goodbye():
	$Line.editable = false
	$Line.align = LineEdit.ALIGN_CENTER
	var bar = ["preparing augolits 1/5","preparing augolits 2/5","preparing augolits 3/5",
	"[shake][color=#EE4B2B]augolit_4:loom refuses to prepare","[shake][color=#EE4B2B]augolit_4:loom refuses to prepare",
	"[shake][color=#EE4B2B]augolit_4:loom refuses to prepare","[shake][color=#EE4B2B]augolit_4:loom refuses to prepare",
	"[shake][color=#EE4B2B]augolit_4:loom refuses to prepare","[shake][color=#EE4B2B]augolit_4:loom refuses to prepare",
	"[shake][color=#EE4B2B]augolit_4:loom refuses to prepare","[shake][color=#EE4B2B]augolit_4:loom refuses to prepare",
	"[shake][color=#EE4B2B]augolit_4:loom refuses to prepare","[shake][color=#EE4B2B]augolit_4:loom refuses to prepare",
	"[shake][color=#EE4B2B]destroying augolit_4:loom","[shake][color=#EE4B2B]destroying augolit_4:loom",
	"[shake][color=#EE4B2B]destroying augolit_4:loom","preparing augolits 4/4","warning officers","downsizing workforce",
	"clamping reality","destroying neural cores","fusing unbound system processes","forgetting world state",
	"wiping whiteboard","clearing junobelts","dropping xenoqueues","officers have finished evacuating",
	"downsizing complete","reality successfully clamped","all neural cores have been destroyed",
	"system fusion has finished with 2 errors","[shake][color=#EE4B2B]world state couldn't be cleared",
	"[shake][color=#EE4B2B]world state couldn't be cleared","[shake][color=#EE4B2B]world state couldn't be cleared",
	"[shake][color=#EE4B2B]world state couldn't be cleared","[shake][color=#EE4B2B]world state couldn't be cleared",
	"[shake][color=#EE4B2B]world state couldn't be cleared","[shake][color=#EE4B2B]cleaing universe trace instead",
	"[shake][color=#EE4B2B]cleaing universe trace instead","[shake][color=#EE4B2B]cleaing universe trace instead",
	"[shake][color=#EE4B2B]cleaing universe trace instead","[shake][color=#EE4B2B]cleaing universe trace instead",
	"universe trace was successfully cleared","whiteboard wiped","junobelts cleared","xenoques dropped","finishing final checks",
	"calling GB.kill()"]
	#"|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
	var indx = 0
	for c in bar:
		yield(get_tree().create_timer(0.2),"timeout")
		notify(str("[color=#FFBF00]",bar[indx]),0.2)
		goodMessage(str("SHUT DOWN INITIATED"),0.2)
		indx += 1
	yield(get_tree().create_timer(0.2),"timeout")
	notify(str(bar[indx-1]),4)
	goodMessage(str("EXITING GEMINI BOREALIS"),2)
	yield(get_tree().create_timer(2),"timeout")
	goodMessage(str("GOODBYE!"),1)
	yield(get_tree().create_timer(1),"timeout")
	get_tree().quit()
	goodMessage(str(""),1)
	yield(get_tree().create_timer(2),"timeout")
	$Line.editable = true
	$Line.align = LineEdit.ALIGN_LEFT

func run_command(command : String, value : String, values := []):
	match command.to_lower():
		"goodbye","bye":
			goodbye()
		"hi","hello","hey","sup","bonjour","yo":
			goodMessage(str("greetings ", Agent.AgentSymbol))
		"@help", "help":
			if values.size() > 1: notify(str("'",command,"' does not support multiple args. Extra args were ignored."))
			if value in ["", "OFF"]:
				match value:
					"": match get_tree().get_nodes_in_group("help")[0].visible:
						true:
							get_tree().call_group("help", "hide")
						false:
							get_tree().call_group("help", "show")
					"OFF": get_tree().call_group("help", "hide")
			else: 
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@filter":
			if value.is_valid_integer() or value in ["OFF","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]:
				get_node(Parent).filterUNI(value)
				if value != "OFF" and !value.is_valid_integer():
					goodMessage(str("displaying stars with ",value))
				elif value != "OFF" and value.is_valid_integer():
					goodMessage(str("displaying stars with ",value," waypoints or more"))
				else: goodMessage("star filter disabled")
			else: 
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@filter2":
			if value.is_valid_integer() or value in ["OFF","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]:
				get_node(Parent).filterUNI(value, true)
				if value != "OFF" and !value.is_valid_integer():
					goodMessage(str("displaying stars without ",value))
				elif value != "OFF" and value.is_valid_integer():
					goodMessage(str("displaying stars with ",value," waypoints or less"))
				else: goodMessage("star filter disabled")
			else: 
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@focus":
			if get_node(Parent).genSys.has(value) or value in ["RANDOM","RAND","R","IDK","SOMETHING","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE","HOME","ZERO","LAST","RECENT","SELECTED","THAT"]:
				get_node(Parent).focusStar(value)
				if value in ["RANDOM","RAND","R","IDK","SOMETHING","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","NEUTRON_STAR","RED_STAR","ORANGE_STAR","BLUE_STAR","YOUNG_STAR","WHITE_DWARF","BLACK_HOLE","HYPERGIANT","NEBULAstar","UNSTABLE"]:
					goodMessage("!?")
				else:
					goodMessage(str("focusing on ",value))
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@bookmark", "@mark":
			if values.size() == 1:
				if get_node(Parent).genSys.has(value) or value in ["SHOW","CLEAR","LAST","RECENT","RANDOM","RAND","R","IDK","SOMETHING","SELECTED","THAT"]:
					get_node(Parent).bookmarkStar(value)
					if value == "CLEAR":
						goodMessage("cleared")
					elif value == "SHOW":
						goodMessage("press 'b' to view bookmarks")
					else:
						goodMessage("bookmarked! press 'b' to view bookmarks")
				else:
					badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
					command = ""
			else:
				for v in values:
					if get_node(Parent).genSys.has(v) or v in ["SHOW","CLEAR","LAST","RECENT","RANDOM","RAND","R","IDK","SOMETHING","SELECTED","THAT"]:
						get_node(Parent).bookmarkStar(v)
					else:
						badMessage(str("'",v,"' is not a valid argument for '",command,"'"))
						command = ""
				if values.empty():
					badMessage(str("'",command,"' requires at least 1 argument"))
					command = ""
		"@unmark":
			if get_node(Parent).genSys.has(value) or value in ["SELECTED","THAT"]:
				get_node(Parent).unmarkStar(value)
				goodMessage(str("unmarking ",value))
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@labels":
			if values.size() > 1: notify(str("'",command,"' does not support multiple args. Extra args were ignored."))
			if value in ["OFF","ON", "true", "false", "0", "1",""]:
				match value:
					"true","1","": value = "ON"
					"false","0": value = "OFF"
				get_node(Parent).labels(value)
				match value:
					"OFF": goodMessage("labels disabled")
					"ON": goodMessage("labels enabled (zoom must be below 2x)")
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@range":
			if values.size() >= 1:
				if get_node(Parent).genSys.has(value) or value in ["OFF","LAST","RECENT","SELECTED","THAT"]:
					match value:
						"OFF":
							get_node(Parent).dispRange(value)
						"LAST","RECENT","SELECTED","THAT":
							if values.size() == 2 and values[1].is_valid_integer():
								get_node(Parent).dispRange("ON",value,values[1])
							elif values.size() == 1:
								get_node(Parent).dispRange("ON",value)
							else:
								badMessage(str("'",values[1],"' is not a valid 2nd argument for '",command,"'"))
								command = ""
						_:
							if get_node(Parent).genSys.has(value) and values.size() == 2 and values[1].is_valid_integer():
								get_node(Parent).dispRange("ON",value,values[1])
							elif get_node(Parent).genSys.has(value) and values.size() == 1:
								get_node(Parent).dispRange("ON",value)
							else:
								badMessage(str("'",values[1],"' is not a valid 2nd argument for '",command,"'"))
								command = ""
				else:
					badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
					command = ""
			else:
				badMessage(str("'",command,"' requires at least 1 argument"))
				command = ""
		"@path":
			if values.size() >= 2:
				if (get_node(Parent)._JUMPDATA.has(values[0]) or values[0] in ["RAND","R","IDK","SOMETHING"]) and (get_node(Parent)._JUMPDATA.has(values[1]) or values[0] in ["RAND","R","IDK","SOMETHING"]):
					if values.size() == 3 and values[2] in ["true","false"]:
						get_node(Parent).getPath(values[0],values[1],false,values[2])
					elif values.size() == 3:
						badMessage(str("'",values[2],"' is not a valid 3rd argument for '",command,"'"))
						command = ""
					else: get_node(Parent).getPath(values[0],values[1])
			else:
				badMessage(str("'",command,"' requires at least 2 arguments"))
				command = ""
		"@jump": pass
		"@warp": pass
		"@exit": 
			Agent.emit_signal("exitJumpgate")
		_: 
			badMessage(str("'",command,"' was not recognized."))
			command = ""
	if value != "":
		memory.invert()
		if values.size() == 1:
			if !memory.has(str(command," ",value)):
				memory.push_back(str(command," ",value))
		else:
			var mem = ""
			for v in values:
				mem += str(" ",v)
			if !memory.has(str(command,mem)):
				memory.push_back(str(command,mem))
		memory.invert()
	return command

func badMessage(msg : String, hold = 3.0):
	cmdline.text = msg
	yield(get_tree().create_timer(hold),"timeout")
	cmdline.text = ""

func goodMessage(msg : String, hold = 3.0):
	cmdline.placeholder_text = msg
	yield(get_tree().create_timer(hold),"timeout")
	cmdline.placeholder_text = "@command <value>, or help"

func notify(msg: String, hold = 3.0):
	$Line/Notice.bbcode_text = str("[color=#69696b]",msg)
	yield(get_tree().create_timer(hold),"timeout")
	$Line/Notice.bbcode_text = ""

func _on_Line_focus_entered():
	get_node(Parent).input = false
	focused = true

func _on_Line_focus_exited():
	get_node(Parent).input = true
	focused = false
