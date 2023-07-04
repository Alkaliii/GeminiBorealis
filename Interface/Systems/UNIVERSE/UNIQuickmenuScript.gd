extends Control

export (NodePath) var Parent

var selection = null
var focusIDX = 0

func _ready():
	self.hide()

func single(sel, AllowPath = false):
	#grab_focus()
	selection = sel
	$HBoxContainer/Copy.show()
	if AllowPath: $HBoxContainer/Path.show()
	else: $HBoxContainer/Path.hide()

func multi(sel):
	#grab_focus()
	focusIDX = 0
	selection = sel
	$HBoxContainer/Copy.hide()
	$HBoxContainer/Path.hide()


func _on_Bookmark_pressed():
	if !selection is Array and selection != null:
		get_node(Parent).bookmarkStar(selection)
	elif focusIDX == -1: for s in selection: get_node(Parent).bookmarkStar(s)
	else: get_node(Parent).bookmarkStar(selection[clamp(focusIDX - 1,0,selection.size() - 1)])

func _on_Copy_pressed():
	OS.set_clipboard(selection)
	get_tree().call_group("cmd","notify",str("[color=#FFBF00]Copied '",selection,"'"),1)

func _on_Focus_pressed():
	$HBoxContainer/Path.hide()
	if !selection is Array and selection != null:
		get_node(Parent).focusStar(selection)
	elif selection is Array: 
		get_node(Parent).focusStar(selection[focusIDX])
		var new_idx = (focusIDX + 1) % selection.size()
		focusIDX = new_idx
		#print(focusIDX)

func _on_Path_pressed():
	get_node(Parent).getPath(selection,get_node(Parent).lastFocus)

var twee
func _process(delta):
	if self.get_rect().has_point(get_viewport().get_mouse_position()) and self.modulate == Color(1,1,1,0.1):
		twee = get_tree().create_tween()
		twee.tween_property(self,"modulate",Color(1,1,1,1),0.2)
	elif !self.get_rect().has_point(get_viewport().get_mouse_position()) and self.modulate == Color(1,1,1,1):
		twee = get_tree().create_tween()
		twee.tween_property(self,"modulate",Color(1,1,1,0.1),0.2)
