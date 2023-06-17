extends Control

var contractDat
var doubleConfirm = false
const line = preload("res://300line.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

#func _process(delta):
#	if Input.is_action_just_pressed("Key1"):
#		accept()

func _on_request_completed(result, response_code, headers, body):
	if result == 4:
		print("bad")
		yield(get_tree().create_timer(0.3),"timeout")
		accept()
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
	for d in $VBoxContainer/HBoxContainer/VBoxContainer/DeliverableList.get_children():
		d.queue_free()
	contractDat = data
	var type = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Type
	var faction = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Faction
	var reward = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Reward
	var del = $VBoxContainer/HBoxContainer/VBoxContainer/DeliverableList
	var dead = $VBoxContainer/Deadline
	
	var delcolor = ""
	var delcolorend = ""
	if data["accepted"]:
		$VBoxContainer/HBoxContainer/Button.hide()
		delcolor = "[color=#4169e1]"
		delcolorend = "[/color]"
		reward.bbcode_text = str("[right]ACCEPTED")
	else:
		reward.bbcode_text = str("[right]$",(data["terms"]["payment"]["onAccepted"]+data["terms"]["payment"]["onFulfilled"]))
	
	type.bbcode_text = str("[b]",data["type"])
	faction.bbcode_text = str("[color=#949495]",data["factionSymbol"])
	for d in data["terms"]["deliver"]:
		var deliver = line.instance()
		deliver.bbcode_text = str("[b]",delcolor,d["tradeSymbol"],delcolorend,"[/b][color=#949495] (",(d["unitsRequired"]-d["unitsFulfilled"]),")")
		del.add_child(deliver)
		self.rect_min_size += Vector2(0,18)
	var deadline = str(data["deadlineToAccept"])
	#print(deadline)
	var today = Time.get_unix_time_from_system()
	deadline = Time.get_unix_time_from_datetime_string(deadline)
	#print(deadline)
	var difference = round((deadline-today)/3600)
	dead.bbcode_text = str("[color=#949495][right]Due in ",difference," hours.")
	

func returnbutton():
	yield(get_tree().create_timer(6),"timeout")
	if doubleConfirm:
		doubleConfirm = false
		$VBoxContainer/HBoxContainer/Button.text = ""
		$VBoxContainer/HBoxContainer/Button.icon_align = Button.ALIGN_CENTER
		var twee = get_tree().create_tween()
		twee.tween_property($VBoxContainer/HBoxContainer/Button, "rect_min_size", Vector2(32,32),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")

func fastreturn():
	if $VBoxContainer/HBoxContainer/Button.icon_align == Button.ALIGN_LEFT:
		$VBoxContainer/HBoxContainer/Button.text = ""
		$VBoxContainer/HBoxContainer/Button.icon_align = Button.ALIGN_CENTER
		var twee = get_tree().create_tween()
		twee.tween_property($VBoxContainer/HBoxContainer/Button, "rect_min_size", Vector2(32,32),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")

func _on_Button_pressed():
	if !doubleConfirm:
		doubleConfirm = true
		$VBoxContainer/HBoxContainer/Button.icon_align = Button.ALIGN_LEFT
		var twee = get_tree().create_tween()
		twee.tween_property($VBoxContainer/HBoxContainer/Button, "rect_min_size", Vector2(150,32),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")
		$VBoxContainer/HBoxContainer/Button.text = "Are You Sure?"
		returnbutton()
	elif doubleConfirm:
		doubleConfirm = false
		accept()

#https://api.spacetraders.io/v2/my/contracts/{contractId}/accept
func accept():
	Agent.acceptContract(contractDat["id"], self)
	doubleConfirm = false
#	var url = str("https://api.spacetraders.io/v2/my/contracts/",contractDat["id"],"/accept")
#	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
#	var header = [headerstring]
#	$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST)
#	doubleConfirm = false
