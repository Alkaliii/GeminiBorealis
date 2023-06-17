extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setdat(error):
	$Control/BG/Control/ErrorJson.set_text(str(error)) 

func _on_COPY_pressed():
	#print("hi")
	OS.set_clipboard($Control/BG/Control/ErrorJson.text)

func _on_OKAY_pressed():
	self.queue_free()
