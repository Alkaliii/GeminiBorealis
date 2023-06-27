extends Control

var pos = Vector2(0,0)
var rad = 1
var col = Color(1,1,1,1)
var width = 1
var fill = false
var multi = false

var posARR = PoolVector2Array()
var radARR = PoolRealArray()
var colARR = PoolColorArray()
var widthARR = PoolRealArray()
var fillARR = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
#	if multi:
#		for p in posARR.size():
#			if fillARR[p]: 
#				draw_circle(posARR[p],radARR[p],colARR[p])
#				continue
#			draw_arc(posARR[p],radARR[p],0, TAU, 360, colARR[p], widthARR[p])
#		return
	
	if fill: draw_circle(pos,rad,col)
	draw_arc(pos, rad, 0, TAU, 360, col, width)
	#self.set_process(false)
	#self.set_physics_process(false)
