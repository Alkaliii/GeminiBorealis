extends Control


signal LoginPressed(to)

var token
var sym

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(TokenDict):
	var button = $VBoxContainer/HBoxContainer/LoginAs
	var dets = $VBoxContainer/Details
	
	button.text = TokenDict["symbol"]
	sym = TokenDict["symbol"]
	token = TokenDict["token"]
	
	dets.bbcode_text = str("[color=#949495]([b]",TokenDict["faction"],"[/b]) | ",Time.get_date_string_from_unix_time(TokenDict["date"]))

func _on_LoginAs_pressed():
	$VBoxContainer/HBoxContainer/LoginAs.disabled = true
	emit_signal("LoginPressed",token)
	yield(Agent,"login")
	$VBoxContainer/HBoxContainer/LoginAs.disabled = false


func _on_RemoveLogin_pressed():
	$VBoxContainer/HBoxContainer/LoginAs.disabled = true
	self.hide()
	Save.pastTokens.erase(sym)
	self.queue_free()
