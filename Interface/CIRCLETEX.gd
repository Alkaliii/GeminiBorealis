extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func changeSize(size):
	size = float(clamp(size, 3.0,11.0))
	$TextureRect.rect_position = Vector2(-size/2,-size/2)
	$TextureRect.rect_size = Vector2(size,size)
	$TextureRect.rect_pivot_offset = Vector2(size/2,size/2)
	
	$Label.rect_position = Vector2(size/2,size/2)

#func setOutCol(color):
#	$Outline.modulate = color

func fadeLabel(pos):
	if self.rect_global_position.distance_to(pos) < 50:
		showLabel()
	else: hideLabel()

func setLabel(text):
	$Label.bbcode_text = text

func shrinkLabel():
	$Label.rect_scale = Vector2(0.5,0.5)

func growLabel():
	$Label.rect_scale = Vector2(1,1)

func hideLabel():
	$Label.hide()

func showLabel():
	$Label.show()
