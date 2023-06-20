extends Control

const grouppanel = preload("res://Interface/Ships/Groups/GroupPanel.tscn")

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
