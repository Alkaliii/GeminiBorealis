extends Control

var CargoDat
var OwnerShip

var doubleConfirm = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/HBoxContainer2/OptionButton.add_item("JET")
	$HBoxContainer/HBoxContainer2/OptionButton.add_item("TSF")
	pass # Replace with function body.

func setdat(data):
	CargoDat = data
	var symbol = $HBoxContainer/Name
	symbol.bbcode_text = str("[b]",data["symbol"],"[/b] x",data["units"])

func returnbutton():
	yield(get_tree().create_timer(6),"timeout")
	if doubleConfirm:
		doubleConfirm = false
		$HBoxContainer/HBoxContainer2/Button.text = ""
		$HBoxContainer/HBoxContainer2/LineEdit.show()
		var twee = get_tree().create_tween()
		twee.tween_property($HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(20,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

func fastreturn():
	doubleConfirm = false
	$HBoxContainer/HBoxContainer2/Button.text = ""
	$HBoxContainer/HBoxContainer2/LineEdit.show()
	var twee = get_tree().create_tween()
	twee.tween_property($HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(20,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

func _on_Button_pressed():
	if $HBoxContainer/HBoxContainer2/OptionButton.selected == 1: #transfer
		doubleConfirm = true
	if !doubleConfirm:
		doubleConfirm = true
		$HBoxContainer/HBoxContainer2/LineEdit.hide()
		var twee = get_tree().create_tween()
		twee.tween_property($HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(160,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")
		$HBoxContainer/HBoxContainer2/Button.text = "Are You Sure?"
		returnbutton()
	elif doubleConfirm:
		doubleConfirm = false
		match $HBoxContainer/HBoxContainer2/OptionButton.selected:
			0: #JETTISON
				#Valid Data
				if !$HBoxContainer/HBoxContainer2/LineEdit.text.is_valid_integer():
					$HBoxContainer/HBoxContainer2/Button.text = "[right][shake]please enter a [b]number"
					yield(get_tree().create_timer(1),"timeout")
					fastreturn()
					return
				#Too Much
				if int($HBoxContainer/HBoxContainer2/LineEdit.text) > CargoDat["units"]:
					$HBoxContainer/HBoxContainer2/LineEdit.text = CargoDat["units"]
				Agent.jettisonCargo(CargoDat["symbol"],$HBoxContainer/HBoxContainer2/LineEdit.text,self)
			1: #TRANSFER
				pass

func _on_JETrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("JettisonCargo",cleanbody)
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass
