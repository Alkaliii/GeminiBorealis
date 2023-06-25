extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false


func _input(event):
	if event.is_action("Click"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = ((zoom * (mouse_start_pos - event.position)) + screen_start_position)
		position.x = clamp(position.x,-65000,65000)
		position.y = clamp(position.y,-65000,65000)
		#(500+limit_bottom)
		#print(position)
