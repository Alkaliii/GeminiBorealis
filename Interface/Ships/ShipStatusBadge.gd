extends Control

export var sns : String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	setdat()

func setdat():
	var text
	var bg
	match sns:
		"IN_TRANSIT":
			text = "#edf4ff" 
			bg = "#c62b69"
		"IN_ORBIT":
			text = "#c6baac"
			bg = "#1e1c32"
		"DOCKED":
			text = "ff8e42"
			bg = "10368f"
	
	$Panel/Status.bbcode_text = str("[center][b]",sns)
	$Panel/Status.self_modulate = Color(text)
	$Panel.self_modulate = Color(bg)
