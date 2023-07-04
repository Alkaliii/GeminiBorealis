tool
extends ReferenceRect

export (NodePath) var graph
export (bool) var resize setget resizeRect
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func resizeRect(new):
	resize = false
	if get_node_or_null(graph) == null: return
	self.rect_min_size = get_node(graph).rect_min_size
	self.rect_size = get_node(graph).rect_min_size
	$ColorRect.material.set("shader_param/columns",self.rect_min_size.x*0.1)
	$ColorRect.material.set("shader_param/rows",self.rect_min_size.y*0.1)
