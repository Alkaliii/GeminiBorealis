extends Control

var pos = Vector2(0,0)
var rad = 1
var col = Color(1,1,1,1)
var fill = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	if fill: draw_circle(pos,rad,col)
	draw_arc(pos, rad, 0, TAU, 360, col)
