extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("login",self,"setdat")
	Agent.connect("updateAgent",self,"setdat")

func setdat():
	if !Agent.networth.has("net"): return
	$Graph.dataDict = Agent.networth["net"]
	$Graph.make_line_graph_from_dataDict()
