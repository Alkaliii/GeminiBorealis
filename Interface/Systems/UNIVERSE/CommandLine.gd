extends Control

enum cmds {HELP, FILTER, INVERSE_FILTER, FOCUS, BOOKMARK, UNBOOKMARK, LABELS, JUMP, WARP, EXIT}
# '@help' or 'help' / displays this menu, helpful.
# '@filter <condition>' (Int,Type,OFF) / filters which stars are displayed, additive.
# '@filter2 <condition>' (Int,Type,OFF) / like '@filter' but inverted, still additive.
# '@focus <systemSymbol>' (OFF) / moves the viewport to the system specified, nifty.
# '@bookmark <systemSymbol>' / saves a system for later in the bookmark (b) menu, handy.
# '@unmark <systemSymbol>' / removes a system that was saved for later, neat.
# '@labels <state>' (ON, OFF) / turns labels on or off, nice.
# '@jump <systemSymbol>' (Queried to select a ship or group)
# '@warp <waypointSymbol>' (Queried to select a ship or group) (waypoints can be gleamed from focus)
# '@exit' / exits the universe map, important.

export (NodePath) var Parent

onready var cmdline = $Line

var focused
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

func _on_Line_text_entered(new_text : String):
	new_text = new_text.lstrip(" ").rstrip(" ")
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
		value = new_text.substr(firstSPC + 1)
		value = value.lstrip(" ")
	
	if run_command(command, value) == "":
		memoryIdx = -1
		return
	cmdline.release_focus()
	cmdline.text = ""
	memoryIdx = -1

func run_command(command : String, value : String):
	match command.to_lower():
		"@help", "help":
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
			if value.is_valid_integer() or value in ["OFF","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL"]:
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
			if value.is_valid_integer() or value in ["OFF","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL"]:
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
			if get_node(Parent).genSys.has(value) or value in ["RANDOM","RAND","R","IDK","SOMETHING","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL","HOME","ZERO"]:
				get_node(Parent).focusStar(value)
				if value in ["RANDOM","RAND","R","IDK","SOMETHING","PLANET","GAS_GIANT","MOON","ORBITAL_STATION","JUMP_GATE","ASTEROID_FIELD","NEBULA","DEBRIS_FIELD","GRAVITY_WELL"]:
					goodMessage("!?")
				else:
					goodMessage(str("focusing on ",value))
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@bookmark":
			if get_node(Parent).genSys.has(value) or value in ["SHOW","CLEAR","LAST","RECENT","RANDOM","RAND","R","IDK","SOMETHING"]:
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
		"@unmark":
			if get_node(Parent).genSys.has(value):
				get_node(Parent).unmarkStar(value)
				goodMessage(str("unmarking ",value))
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		"@labels":
			if value in ["OFF","ON", "true", "false", "0", "1"]:
				match value:
					"true","1": value = "ON"
					"false","0": value = "OFF"
				get_node(Parent).labels(value)
				match value:
					"OFF": goodMessage("labels disabled")
					"ON": goodMessage("labels enabled (zoom must be below 2x)")
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
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
		if !memory.has(str(command," ",value)):
			memory.push_back(str(command," ",value))
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

func _on_Line_focus_entered():
	get_node(Parent).input = false
	focused = true

func _on_Line_focus_exited():
	get_node(Parent).input = true
	focused = false
