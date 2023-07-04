extends Routine
class_name AutoExtractRoutine


# Called when the node enters the scene tree for the first time.
func _ready():
	#officerFSM = preload("res://Automation/AutoExtract.gd")
	pass # Replace with function body.

func startRoutine():
	for ship in groupData:
		var officer = AutoExtractFSM.new()
		officer.shipSymbol = groupData[ship]["symbol"]
		officer.shipData = groupData[ship]
		officer.focusList.push_back(officer.possibleFocus[0])
		officer.focusList.push_back(officer.possibleFocus[21])
		officer.focusList.push_back(officer.possibleFocus[22])
		officer.name = str(officer.shipSymbol," ","OFFICER")
		self.add_child(officer)
		yield(get_tree(),"idle_frame")
		officer.set_state(officer.STATES["Extract"])
		#yield(get_tree().create_timer(0.2),"timeout")

func pauseRoutine(): pass
