extends Control

var GROUP

# Called when the node enters the scene tree for the first time.
func _ready():
	var sDrop = $VBoxContainer/Double/StateOptionButton
	
	sDrop.add_item("Start")
	#sDrop.add_item("Pause")
	#sDrop.add_item("Restart")
	sDrop.add_item("Stop")
	
	var rDrop = $VBoxContainer/Double/RoutineOptionButton
	
	rDrop.add_item("MINER")
	rDrop.add_item("Auto-Extract")
	#rDrop.add_item("Purge Cargo")

func _on_CONFIRM_pressed():
	var sDrop = $VBoxContainer/Double/StateOptionButton
	var rDrop = $VBoxContainer/Double/RoutineOptionButton
	
	var selS = sDrop.get_item_text(sDrop.selected)
	var selR = rDrop.get_item_text(rDrop.selected)
	
	var data = {"state":selS,"routine":selR,"group":GROUP}
	
	Agent.emit_signal("selectedRoutine",data)
	
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()


func _on_CANCEL_pressed():
	var data = {"state":"CANCEL","routine":"CANCEL","group":"CANCEL"}
	
	Agent.emit_signal("selectedRoutine",data)
	
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()
