extends Control

var symbols : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data, prompt = null):
	for s in data["data"]["waypoints"]:
		var shiphereindi = ""
		var mylocal = false
		for ship in Agent._FleetData["data"]:
			if ship["nav"]["waypointSymbol"] == s["symbol"] and ship["nav"]["status"] != "IN_TRANSIT":
				if ship["symbol"] == Agent.focusShip:
					mylocal = true
				shiphereindi = "[*] "
				break
		if mylocal:
			continue
		$VBoxContainer/OptionButton.add_item(str(shiphereindi,s["type"]," ",s["symbol"]))
		symbols.push_back(s["symbol"])
	
	if prompt != null:
		$VBoxContainer/Label.bbcode_text = prompt

func _on_CONFIRM_pressed():
	Agent.emit_signal("selectedWaypoint", symbols[$VBoxContainer/OptionButton.selected])
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()

func _on_CANCEL_pressed():
	Agent.emit_signal("selectedWaypoint", "CANCEL")
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()
