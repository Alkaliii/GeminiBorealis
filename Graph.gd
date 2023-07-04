extends Control

export (int,"Line") var _chart_type
export (Color) var chart_color_A
var dataDict = [
	{"datalabel": 10}, #10 is data, 0 is x value "datalabel" can be an x value if it's not a string
	{"datalabel2": 2}, #2 is data, 1 is x value
	{"datalabel3": 40}, #40 is data, 2 is x value
	{"datalabel3": 0},
	{"datalabel3": 10},
	{"datalabel3": 90},
	{"datalabel3": 4},
	{"datalabel3": 3},
	{"datalabel3": 7},
	{"datalabel3": 13},
	{"datalabel3": 70},
	{"datalabel3": 3},
	{"datalabel3": 100}
]
export (String) var x_axis_unit = "s"
export (int,"Prefix","Suffix") var x_unit_affix
export (String) var y_axis_unit = "gV"
export (int,"Prefix","Suffix") var y_unit_affix
export (bool) var labels = true

var graphline

func _ready():
	graphline = Line2D.new()
	graphline.position = Vector2(self.rect_position.x,self.rect_min_size.y)
	graphline.default_color = chart_color_A
	graphline.show_behind_parent = true
	graphline.width = 1.5
	
	match labels:
		true:
			$"ReferenceRect/x min".show()
			$"ReferenceRect/x max".show()
			$"ReferenceRect/y min".show()
			$"ReferenceRect/y max".show()
		false:
			$"ReferenceRect/x min".hide()
			$"ReferenceRect/x max".hide()
			$"ReferenceRect/y min".hide()
			$"ReferenceRect/y max".hide()
	
#	$ReferenceRect.rect_min_size = self.rect_min_size
#	$ReferenceRect.rect_size = self.rect_min_size
	$ReferenceRect.resizeRect(true)
	
	#make_line_graph_from_dataDict()
#SAVE DATA AS: networth {client_version,net{"label":vector2(x,y)
func make_line_graph_from_dataDict():
	for e in $Elements.get_children():
		e.queue_free()
	
	graphline = Line2D.new()
	graphline.position = Vector2(self.rect_position.x,self.rect_min_size.y)
	graphline.default_color = chart_color_A
	graphline.show_behind_parent = true
	graphline.width = 1.5
	
	#define points
	var x_max = 0
	var y_max = 0
	var data_points = PoolVector2Array()
	
	var x_max_label = $"ReferenceRect/x max"
	var y_max_label = $"ReferenceRect/y max"
	
	for dp in dataDict:
		#print(dp,dp.values()[0] is String)
		if dp.values()[0] is String: if !dp.values()[0].is_valid_float(): continue
		if dp.values()[0] is String: if !dp.values()[0].is_valid_integer(): continue
		
		if float(dp.values()[0]) > y_max: y_max = float(dp.values()[0])
		#if dp.keys()[0].is_valid_float() and float(dp.keys()[0]) > x_max: x_max = float(dp.keys()[0])
		
#		if !dp.values()[0] is String and dp.keys()[0].is_valid_float():
#			data_points.push_back(Vector2(float(dp.keys()[0]),float(dp.values()[0])))
		#elif !dp.values()[0] is String and !dp.keys()[0].is_valid_float():
		data_points.push_back(Vector2(float(dataDict.find(dp)),float(dp.values()[0])))
		#print(Vector2(float(dataDict.find(dp)),float(dp.values()[0])))
	
	if x_max == 0: x_max = dataDict.size() - 1
	match x_unit_affix:
		0: x_max_label.bbcode_text = str("[right]",x_axis_unit,"",x_max)
		1: x_max_label.bbcode_text = str("[right]",x_max,"",x_axis_unit)
	match y_unit_affix:
		0: y_max_label.bbcode_text = str("[right]",y_axis_unit,"",y_max)
		1: y_max_label.bbcode_text = str("[right]",y_max,"",y_axis_unit)
	
	for p in data_points:
		plot(p,x_max,y_max)
	
	$Elements.add_child(graphline)
	
	var poly = Polygon2D.new()
	var polycol = chart_color_A
	polycol.a = 0.6
	poly.color = polycol
	poly.position = Vector2(self.rect_position.x,self.rect_min_size.y)
	var polypoint = PoolVector2Array([Vector2.ZERO]) #Vector2(self.rect_position.x,self.rect_min_size.y)
	polypoint.append_array(graphline.points)
	polypoint.push_back(Vector2(self.get_rect().end.x,0))
	poly.set_polygon(polypoint)
	$Elements.add_child(poly)

func plot(point,x_max,y_max):
	point.x = (float(point.x) / float(x_max)) * self.rect_min_size.x
	point.y = -(float(point.y) / float(y_max)) * (self.rect_min_size.y - (self.rect_min_size.y * 0.1))
	#print(point)
	graphline.add_point(point)
