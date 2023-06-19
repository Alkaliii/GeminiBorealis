extends Node
class_name Routine

var assigned_Group = null
var groupData : Dictionary
var sharedData : Dictionary
var officerFSM

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func startRoutine():
	pass

func endRoutine():
	for o in get_children():
		o.endFSM()
