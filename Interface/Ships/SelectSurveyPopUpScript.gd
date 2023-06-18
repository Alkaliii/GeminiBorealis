extends Control

var surveylistkeys : Array


func _ready():
	pass # Replace with function body.

func setdat(sym):
	var surdic = Agent.surveys
	for s in surdic:
		if surdic[s]["symbol"] == sym:
			var string = str(surdic[s]["size"]," ")
			for d in surdic[s]["deposits"]:
				string += str("/",d["symbol"])
			$VBoxContainer/OptionButton.add_item(string)
			surveylistkeys.push_back(s)
	$VBoxContainer/OptionButton.add_item("None")
	surveylistkeys.push_back("CANCEL")
	
	if surveylistkeys.size() == 1:
		self.hide()
		Agent.emit_signal("selectedSurvey","CANCEL")
		self.queue_free()
	
	self.show()

func _on_Button_pressed():
	Agent.emit_signal("selectedSurvey",surveylistkeys[$VBoxContainer/OptionButton.selected])
	var twee = get_tree().create_tween()
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.5)
	yield(twee,"finished")
	self.queue_free()
