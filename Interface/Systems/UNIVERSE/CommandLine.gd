extends Control

enum cmds {FILTER, INVERSE_FILTER, FOCUS, BOOKMARK, UNBOOKMARK, LABELS, JUMP, WARP}
# @filter <condition> (Integer,Waypoint Type,OFF)
# @filter2 <condition> (Integer,Waypoint Type,OFF)
# @focus <symbol> (String, OFF)
# @bookmark <symbol> (String)
# @unmark <symbol> (String)
# @labels <bool>
# @jump <system> (Queried to select a ship or group)
# @warp <waypoint> (Queried to select a ship or group) (waypoints can be gleamed from focus)

export (NodePath) var Parent

onready var cmdline = $Line

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
		return
	cmdline.release_focus()
	cmdline.text = ""

func run_command(command : String, value : String):
	match command.to_lower():
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
			if value in ["OFF","ON"]:
				get_node(Parent).labels(value)
				match value:
					"OFF": goodMessage("labels disabled")
					"ON": goodMessage("labels enabled (zoom must be below 2x)")
			else:
				badMessage(str("'",value,"' is not a valid argument for '",command,"'"))
				command = ""
		_: 
			badMessage(str("'",command,"' was not recognized."))
			command = ""
	return command

func badMessage(msg : String, hold = 3.0):
	cmdline.text = msg
	yield(get_tree().create_timer(hold),"timeout")
	cmdline.text = ""

func goodMessage(msg : String, hold = 3.0):
	cmdline.placeholder_text = msg
	yield(get_tree().create_timer(hold),"timeout")
	cmdline.placeholder_text = "@command <value>"

func _on_Line_focus_entered():
	get_node(Parent).input = false

func _on_Line_focus_exited():
	get_node(Parent).input = true
