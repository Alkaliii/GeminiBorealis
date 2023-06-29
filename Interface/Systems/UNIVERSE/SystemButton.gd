extends Control

var sysDat
const SCM = {
	"NEUTRON_STAR":
		{"text":"#f8fafc","bg":"#475569"},
	"RED_STAR":
		{"text":"#fef2f2","bg":"#b91c1c"},
	"ORANGE_STAR":
		{"text":"#431407","bg":"#fdba74"},
	"BLUE_STAR":
		{"text":"#083344","bg":"#22d3ee"},
	"YOUNG_STAR":
		{"text":"#022c22","bg":"#6ee7b7"},
	"WHITE_DWARF":
		{"text":"#030712","bg":"#f9fafb"},
	"BLACK_HOLE":
		{"text":"#f9fafb","bg":"#030712"},
	"HYPERGIANT":
		{"text":"#2e1065","bg":"#c4b5fd"},
	"NEBULA":
		{"text":"#fdf2f8","bg":"#db2777"},
	"UNSTABLE":
		{"text":"#eef2ff","bg":"#4f46e5"}
}
signal focusME

var doubleClick = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data):
	sysDat = data
	
	var col = str("[color=",SCM[data["type"]]["text"],"]")
	$VBoxContainer/Details/Panel.color = SCM[data["type"]]["bg"]
	
	$VBoxContainer/Button.text = data["symbol"]
	$VBoxContainer/Details.bbcode_text = str(col,"[center][b]",data["type"])


func _on_Button_pressed():
	match doubleClick:
		false:
			doubleClick = true
			$VBoxContainer/Button.text = "COPIED"
			OS.set_clipboard(sysDat["symbol"])
			yield(get_tree().create_timer(1),"timeout")
			$VBoxContainer/Button.text = sysDat["symbol"]
		true:
			doubleClick = false
			emit_signal("focusME",sysDat["symbol"])
