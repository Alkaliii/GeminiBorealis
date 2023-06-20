extends Control

var symbols : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data):
	for s in data:
		$VBoxContainer/OptionButton.add_item(s)
		symbols.push_back(s)
	$VBoxContainer/OptionButton.add_item("New Group")
	symbols.push_back("NEW")


func _on_CANCEL_pressed():
	Agent.emit_signal("selectedGroup", "CANCEL")
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()


func _on_CONFIRM_pressed():
	Agent.emit_signal("selectedGroup", symbols[$VBoxContainer/OptionButton.selected])
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()
