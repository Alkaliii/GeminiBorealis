extends Control


var twee


# Called when the node enters the scene tree for the first time.
func _ready():
	Automation.connect("ERROR",self,"finishload")
	pass # Replace with function body.

#func _process(delta):
#	if Input.is_action_just_pressed("ui_up"):
#		startload()
#	if Input.is_action_just_pressed("ui_down"):
#		finishload()

func startload():
	self.modulate = Color(1,1,1,1)
	self.show()
	$ProgressBar.value = 0
	twee = get_tree().create_tween()
	twee.tween_property($ProgressBar,"value",100,20).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func finishload(arg = null):
	if twee is SceneTreeTween: twee.stop()
	twee = get_tree().create_tween()
	twee.tween_property($ProgressBar,"value",100,0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	twee.tween_property(self,"modulate",Color(1,1,1,0),0.1)
	yield(twee,"finished")
	self.hide()
