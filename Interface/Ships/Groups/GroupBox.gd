extends Control

const grouppanel = preload("res://Interface/Ships/Groups/GroupPanel.tscn")

var open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Save.connect("ShipAssigned",self,"refresh")

func refresh():
	for r in $ScrollContainer/VBoxContainer.get_children():
		r.queue_free()
	
	for g in Save.groups:
		var group = grouppanel.instance()
		group.GROUP = g
		group.setdat()
		$ScrollContainer/VBoxContainer.add_child(group)
	
	yield(get_tree().create_timer(0.4),"timeout")
	open = true
	changeVis()

func _process(delta):
	if Input.is_action_just_pressed("openGROUPS"):
		open = !open
		changeVis()

func changeVis():
	match open:
		true:
			show()
			Automation.RateTime = Automation.aggressiveRateTime
		false:
			hide()
			Automation.RateTime = Automation.laxRateTime
