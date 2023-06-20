extends Control

var GROUP
var srDat
const shipstatg = preload("res://Interface/Ships/Groups/ShipStatus_Group.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var options = [
		"Rename",
		"Set Routine",
		"Delete"
	]
	
	for o in options: 
		$BG/VBoxContainer/bTAB/HBoxContainer/OptionButton.add_item(o)
	Agent.connect("selectedRoutine",self,"prepSet_Routine")

func setdat():
	var data = Save.groups[GROUP]
	
	$BG/VBoxContainer/bTAB/HBoxContainer/GroupName.bbcode_text = str("[b]",data["Name"].capitalize())
	
	for r in $BG/VBoxContainer/ScrollContainer/HBoxContainer.get_children():
		r.queue_free()
	
	for s in data["Ships"]:
		var ship = shipstatg.instance()
		ship.setdat(data["Ships"][s])
		$BG/VBoxContainer/ScrollContainer/HBoxContainer.add_child(ship)

func prepSet_Routine(data):
	srDat = data

func _on_Button_pressed():
	var dropdown = $BG/VBoxContainer/bTAB/HBoxContainer/OptionButton
	match dropdown.get_item_text(dropdown.selected):
		"Rename": pass
		"Set Routine":
			Agent.emit_signal("query_Routine",GROUP)
			yield(Agent,"selectedRoutine")
			
			if srDat["group"] != GROUP: return
			Automation.setRoutine(srDat)
		"Delete":
			Save.groups.erase(GROUP)
			self.queue_free()
