extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("login",self,"setdat")

func setdat():
	var xArr : Array
	var yArr : Array
	if !Agent.networth.has("net"): return
	for v in Agent.networth["net"]:
		var xpt = float(v.keys()[0])
		xArr.push_back(xpt)
		var ypt = int(v.values()[0])
		yArr.push_back(ypt)
