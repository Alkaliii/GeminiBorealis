extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setdat(error):
	var textbox = $Control/BG/Control/ErrorJson
	textbox.clear()
	var line = ""
	var indentlevel = 0
	
	for c in str(error):
		var cont = false
		match c:
			"{":
				cont = true
				line += "{\n[indent]"
			"}":
				cont = true
				line += "\n[/indent]}"
			",":
				cont = true
				line += ",\n"
		if cont:
			pass
		else:
			line += c
	textbox.set_bbcode(line)
	print(textbox.text)
	
	#$Control/BG/Control/ErrorJson.set_text(str(error)) 

func _on_COPY_pressed():
	#print("hi")
	OS.set_clipboard($Control/BG/Control/ErrorJson.text)

func _on_OKAY_pressed():
	self.queue_free()
