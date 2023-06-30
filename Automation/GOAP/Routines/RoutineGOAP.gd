extends Node
class_name RoutineGOAP

var assigned_Group = null
var groupData : Dictionary
var sharedData : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func startRoutine():
	pass

func pauseRoutine():
	for o in get_children():
		o.officer = o.has.PAUSED

func resumeRoutine():
	for o in get_children():
		o.officer = o.has.STARTED

func restartRoutine():
	for o in get_children():
		o.officer = o.has.PAUSED
		yield(get_tree(),"idle_frame")
		o.queue_free()
	print("restarting ", assigned_Group)
	startRoutine()

func endRoutine():
	for o in get_children():
		o.officer = o.has.PAUSED
	self.queue_free()
