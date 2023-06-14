extends Control

var symbols : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data):
	for s in data:
		$VBoxContainer/OptionButton.add_item(str(s["registration"]["role"],"/",s["symbol"]," [",(s["cargo"]["capacity"]-s["cargo"]["units"]),"]"))
		symbols.push_back(s["symbol"])

func _on_Button_pressed():
	Agent.setInterfaceShip(symbols[$VBoxContainer/OptionButton.selected])
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()
	
