extends Control

var contractDat
var doubleConfirm = false
const line = preload("res://300line.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	API.connect("accept_contract_complete",self,"accepted")

#func _process(delta):
#	if Input.is_action_just_pressed("Key1"):
#		accept()

func _on_request_completed(result, response_code, headers, body):
	if result == 4:
		print("bad")
		yield(get_tree().create_timer(0.3),"timeout")
		#accept()
		return
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		contractDat = cleanbody["data"]["contract"]
		setdat(contractDat)
		fastreturn()
		Agent.emit_signal("AcceptContract")
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass

func setdat(data):
	contractDat = data
	var type = $VBoxContainer/Info/Type
	var faction = $VBoxContainer/Info/Faction
	var reward = $VBoxContainer/Info/Reward
	var del = $VBoxContainer/DeliverableList
	var dead = $VBoxContainer/Deadline
	var id = $VBoxContainer/ContractID
	
	for d in $VBoxContainer/DeliverableList.get_children():
		d.queue_free()
	del.add_child(HSeparator.new())
	
	id.bbcode_text = str("[color=#949495]Contract.",data["id"])
	
	var delcolor = ""
	var delcolorend = ""
	if data["accepted"]:
		$VBoxContainer/Accept.hide()
		$VBoxContainer/Deliver.show()
		$VBoxContainer/Fulfill.show()
		delcolor = "[color=#FFBF00]"
		delcolorend = "[/color]"
		reward.bbcode_text = str("[right]ACCEPTED")
	else:
		reward.bbcode_text = str("[right]$",(data["terms"]["payment"]["onAccepted"]+data["terms"]["payment"]["onFulfilled"]))
	
	type.bbcode_text = str("[b]",data["type"])
	faction.bbcode_text = str("[color=#949495]",data["factionSymbol"])
	for d in data["terms"]["deliver"]:
		var deliver = line.instance()
		deliver.bbcode_text = str("[color=#949495]",(d["unitsRequired"]-d["unitsFulfilled"]),"x[/color] [b]",delcolor,d["tradeSymbol"],delcolorend,"[/b]")
		del.add_child(deliver)
		self.rect_min_size += Vector2(0,18)
	del.add_child(HSeparator.new())
	
	var deadline
	var today = Time.get_unix_time_from_system()
	var difference
	if !data["accepted"]:
		deadline = str(data["deadlineToAccept"])
		deadline = Time.get_unix_time_from_datetime_string(deadline)
		difference = round((deadline-today)/3600)
		dead.bbcode_text = str("[color=#949495][right]Available for ",difference," hours.")
	else:
		deadline = str(data["terms"]["deadline"])
		deadline = Time.get_unix_time_from_datetime_string(deadline)
		difference = round((deadline-today)/3600)
		dead.bbcode_text = str("[color=#949495][right]Due in ",difference," hours.")

func returnbutton():
	yield(get_tree().create_timer(6),"timeout")
	if doubleConfirm:
		doubleConfirm = false
		$VBoxContainer/Accept.flat = false
		$VBoxContainer/Accept.text = "ACCEPT"

func fastreturn():
	$VBoxContainer/Accept.flat = false
	$VBoxContainer/Accept.text = "ACCEPT"

#https://api.spacetraders.io/v2/my/contracts/{contractId}/accept
func accepted(data):
	contractDat = data["data"]["contract"]
	setdat(contractDat)
	fastreturn()
#	Agent.acceptContract(contractDat["id"], self)
#	doubleConfirm = false
##	var url = str("https://api.spacetraders.io/v2/my/contracts/",contractDat["id"],"/accept")
##	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
##	var header = [headerstring]
##	$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST)
##	doubleConfirm = false

func _on_Accept_pressed():
	if !doubleConfirm:
		doubleConfirm = true
		$VBoxContainer/Accept.flat = true
		var twee = get_tree().create_tween().set_loops(6)
		#twee.tween_property($VBoxContainer/HBoxContainer/Button, "rect_min_size", Vector2(150,32),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		twee.tween_property($VBoxContainer/Accept,"modulate",Color(1,1,1,0),0.3)
		twee.tween_property($VBoxContainer/Accept,"modulate",Color(1,1,1,1),0.3)
		$VBoxContainer/Accept.text = "Are You Sure?"
		returnbutton()
	elif doubleConfirm:
		doubleConfirm = false
		API.accept_contract(self,contractDat["id"])
