extends ColorRect

var mouse_start_pos
var rect_start_position

var dragging = false

export (NodePath) var camera

func _input(event):
	if event.is_action("Click"):
		if event.is_pressed():
			mouse_start_pos = event.position
			rect_start_position = event.position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging: pass
		#rect_position = ((zoom * (mouse_start_pos - event.position)) + screen_start_position)
