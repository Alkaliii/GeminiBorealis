extends Control

var CargoDat
var OwnerShip

var doubleConfirm = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/HBoxContainer2/OptionButton.add_item("JET")
	$HBoxContainer/HBoxContainer2/OptionButton.add_item("TSF")
	API.connect("jettison_cargo_complete",self,"_on_JETrequest_completed")
	API.connect("transfer_cargo_complete",self,"_on_TSFrequest_completed")
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
		yield(get_tree(),"idle_frame")
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
				#Agent.jettisonCargo(CargoDat["symbol"],$HBoxContainer/HBoxContainer2/LineEdit.text,self)
									#Author,Ship,Trade_Good,Units
				API.jettison_cargo(self,Agent.focusShip,CargoDat["symbol"],int($HBoxContainer/HBoxContainer2/LineEdit.text))
				waiting_jc = true
				get_tree().call_group("loading","startload")
			1: #TRANSFER
				#Valid Data
				if !$HBoxContainer/HBoxContainer2/LineEdit.text.is_valid_integer():
					$HBoxContainer/HBoxContainer2/Button.text = "[right][shake]please enter a [b]number"
					yield(get_tree().create_timer(1),"timeout")
					fastreturn()
					return
				#Too Much
				if int($HBoxContainer/HBoxContainer2/LineEdit.text) > CargoDat["units"]:
					$HBoxContainer/HBoxContainer2/LineEdit.text = CargoDat["units"]
				#Check for reciving ships
				var canTransfer = false
				var tsf_amt = int($HBoxContainer/HBoxContainer2/LineEdit.text)
				var tsf_wpt = Automation._FleetData[Agent.focusShip]["nav"]["waypointSymbol"]
				var tsf_status = Automation._FleetData[Agent.focusShip]["nav"]["status"]
				for s in Automation._FleetData:
					#self transfer is dumb
					if Automation._FleetData[s]["symbol"] == Agent.focusShip: continue
					#not enough cargo space
					if Automation._FleetData[s]["cargo"]["capacity"] - Automation._FleetData[s]["cargo"]["units"] < tsf_amt: continue
					#at waypoint, same status
					if Automation._FleetData[s]["nav"]["waypointSymbol"] == tsf_wpt and Automation._FleetData[s]["nav"]["status"] == tsf_status:
						canTransfer = true
				if !canTransfer:
					Agent.dispError("You cannot transfer cargo. {Are there other ships at this ships waypoint?,Is the other ship also %s?,Does the other ship have inventory space?}" % [tsf_status])
					return
				
				Agent.call_deferred("queryUser_Ship", tsf_wpt, "TRANSFER")
				yield(Agent,"interfaceShipSet")
				
				#Revalidate cargo space
				if Automation._FleetData[Agent.interfaceShip]["cargo"]["capacity"] - Automation._FleetData[Agent.interfaceShip]["cargo"]["units"] < tsf_amt:
					tsf_amt = int(Automation._FleetData[Agent.interfaceShip]["cargo"]["capacity"] - Automation._FleetData[Agent.interfaceShip]["cargo"]["units"])
				
				API.transfer_cargo(self,Agent.focusShip,CargoDat["symbol"],tsf_amt,Agent.interfaceShip)
				waiting_t = true
				get_tree().call_group("loading","startload")

var waiting_jc = false
func _on_JETrequest_completed(cleanbody):
	if !waiting_jc: return
	waiting_jc = false
	get_tree().call_group("loading","finishload")
#	var json = JSON.parse(body.get_string_from_utf8())
#	var cleanbody = json.result
	if cleanbody.has("data"):
		cleanbody["meta"] = Agent.focusShip
		Agent.emit_signal("JettisonCargo",cleanbody)
#	else:
#		Agent.dispError(cleanbody)
#		#getfail()
#	print(json.result)

var waiting_t = false
func _on_TSFrequest_completed(cleanbody):
	if !waiting_t: return
	waiting_t = false
	get_tree().call_group("loading","finishload")
	
	if cleanbody.has("data"):
		cleanbody["meta"] = Agent.focusShip
		Agent.emit_signal("TransferCargo",cleanbody)
		Agent.emit_signal("TransferTarget",Agent.interfaceShip)
