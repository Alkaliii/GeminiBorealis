extends Control

export var wpt : String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	setdat()

func setdat():
	var text
	var bg
	match wpt:
		"MOON":
			text = "#f8fafc"
			bg = "#64748b"
		"GAS_GIANT":
			text = "#fff7ed"
			bg = "#ea580c"
		"NEBULA":
			text = "#422006"
			bg = "#fde047"
		"ASTEROID_FIELD":
			text = "#1a2e05"
			bg = "#bef264"
		"PLANET":
			text = "#ecfdf5"
			bg = "#059669"
		"DEBRIS_FIELD":
			text = "#083344"
			bg = "#67e8f9"
		"ORBITAL_STATION":
			text = "#fdf4ff"
			bg = "#c026d3"
		"JUMP_GATE":
			text = "#030712"
			bg = "#f9fafb"
		"GRAVITY_WELL":
			text = "#f9fafb"
			bg = "#030712"
	
	$Panel/Waypoint.bbcode_text = str("[center][b]",wpt)
	$Panel/Waypoint.self_modulate = Color(text)
	$Panel.self_modulate = Color(bg)
