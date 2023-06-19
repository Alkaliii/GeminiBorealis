extends Node
class_name STATEMACHINE

var state = null setget set_state
var previous_state = null
var STATES : Dictionary

export (int, "Running", "Error", "Finished") var OfficerStatus

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if state != null:
		state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func state_logic(delta):
	pass

func _get_transition(delta):
	return null

func _enter_state(new_state, old_state):
	pass 

func _exit_state(old_state, new_state):
	pass

func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state,new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func add_state(state_name : String):
	STATES[state_name] = STATES.size()

func endFSM():
	set_state(null)
	#remove all requests
