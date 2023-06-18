extends Control

export (int, "IMPORT", "EXPORT", "EXCHANGE") var infoType

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(data):
	$VBoxContainer/HBoxContainer/importICON.hide()
	$VBoxContainer/HBoxContainer/exportICON.hide()
	$VBoxContainer/HBoxContainer/exchangeICON.hide()
	match infoType:
		0: #IMPORT
			$VBoxContainer/HBoxContainer/Label.bbcode_text = "[b][color=#949495]IMPORTS"
			$VBoxContainer/HBoxContainer/importICON.show()
		1: #EXPORT
			$VBoxContainer/HBoxContainer/Label.bbcode_text = "[b][color=#949495]EXPORTS"
			$VBoxContainer/HBoxContainer/exportICON.show()
		2: #EXCHANGE
			$VBoxContainer/HBoxContainer/Label.bbcode_text = "[b][color=#949495]EXCHANGE"
			$VBoxContainer/HBoxContainer/exchangeICON.show()
	
	var line : Array
	for s in data:
		var sym = s["symbol"]
		var added = false
		for ship in Agent._FleetData["data"]:
			for c in ship["cargo"]["inventory"]:
				if c["symbol"] == sym:
					line.push_back(str("[b][color=#BDB5D5]",sym,"[/color][/b]"))
					added = true
					break
		if !added: line.push_back(sym)
	
	$VBoxContainer/ieedata.bbcode_text = str(line)
