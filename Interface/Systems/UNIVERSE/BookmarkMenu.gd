extends Panel

const book = preload("res://Interface/Systems/UNIVERSE/SystemButton.tscn")
export (NodePath) var Parent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("bookmarkMenu") and get_node(Parent).input:
		self.visible = !self.visible
		if self.visible: get_tree().call_group("help", "hide")

func preview():
	if !self.visible:
		self.show()
		yield(get_tree().create_timer(2),"timeout")
		self.hide()

func addBookmark(data):
	var sys = book.instance()
	sys.setdat(data)
	sys.connect("focusME",get_node(Parent),"focusStar")
	$ScrollContainer2/List.add_child(sys)

func clear():
	for c in $ScrollContainer2/List.get_children():
		c.disconnect("focusME",get_node(Parent),"focusStar")
		c.queue_free()

func removeBookmark(data):
	for c in $ScrollContainer2/List.get_children():
		if c.sysDat["symbol"] == data:
			c.disconnect("focusME",get_node(Parent),"focusStar")
			c.queue_free()
