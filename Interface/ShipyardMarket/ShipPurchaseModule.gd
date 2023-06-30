extends Control

const addline = preload("res://300linesmall.tscn")
var ShipDat
var Waypoint
var details = false
var doubleConfirm = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setdat(ShipData):
	var ShipName = $HBoxContainer/Main/Details/Name
	var ShipType = $HBoxContainer/Main/Details/Type
	var ShipPrice = $HBoxContainer/Main/HBoxContainer/Buy
	var ShipFrame = $HBoxContainer/SimpleDetails/Frame
	var ShipReactor = $HBoxContainer/SimpleDetails/Reactor
	var ShipEngine = $HBoxContainer/SimpleDetails/Engine
	var Additional = $HBoxContainer/SimpleDetails/AdditionalDetails
	ShipDat = ShipData
	
	ShipName.bbcode_text = str("[b]",ShipData["name"])
	ShipType.bbcode_text = str(">",ShipData["type"]," [color=#949495]Speed: [",ShipData["engine"]["speed"],"]")
	ShipPrice.text = str("$",ShipData["purchasePrice"])
	ShipFrame.bbcode_text = str("[right]F:[b]",ShipData["frame"]["symbol"].replace("FRAME","").replace("_"," "))
	ShipReactor.bbcode_text = str("[right]R:[b]",ShipData["reactor"]["symbol"].replace("REACTOR","").replace("_"," "))
	ShipEngine.bbcode_text = str("[right]E:[b]",ShipData["engine"]["symbol"].replace("ENGINE","").replace("_"," "))
	
	var modules = []
	for m in ShipData["modules"]:
		modules.push_back(m["symbol"].replace("MODULE_","").replace("PROCESSOR_","PROC_").replace("PASSENGER","PASS_").replace("REFINERY","REF_").replace("SCIENCE_","SCI_").replace("GENERATOR_","GEN_"))
	self.hint_tooltip = str(modules)
	
	if ShipData["purchasePrice"] > float(Agent.AgentCredits): ShipPrice.disabled = true

func _on_Details_pressed():
	for r in $HBoxContainer/SimpleDetails/AdditionalDetails.get_children():
		r.queue_free()
	for r in $HBoxContainer/Main/Additionals.get_children():
		r.queue_free()
	details = !details
	if details:
		self.rect_min_size = Vector2(462,80)
		var modSlo = addline.instance()
		modSlo.bbcode_text = str("[right]Module Slots: [b][",ShipDat["frame"]["moduleSlots"],"]")
		$HBoxContainer/SimpleDetails/AdditionalDetails.add_child(modSlo)
		
		var mouPoi = addline.instance()
		mouPoi.bbcode_text = str("[right]Mounting Points: [b][",ShipDat["frame"]["mountingPoints"],"]")
		$HBoxContainer/SimpleDetails/AdditionalDetails.add_child(mouPoi)
		
		var fuelCap = addline.instance()
		fuelCap.bbcode_text = str("[right]Fuel Capacity: [b][",ShipDat["frame"]["fuelCapacity"],"]")
		$HBoxContainer/SimpleDetails/AdditionalDetails.add_child(fuelCap)
		
		var modules = addline.instance()
		modules.bbcode_text = self.hint_tooltip
		$HBoxContainer/Main/Additionals.add_child(modules)
	else: self.rect_min_size = Vector2(462,40)

func returnbutton():
	yield(get_tree().create_timer(6),"timeout")
	if doubleConfirm:
		doubleConfirm = false
		$HBoxContainer/Main/HBoxContainer/Buy.text = str("$",ShipDat["purchasePrice"])
		$HBoxContainer/Main/Details/Type.bbcode_text = str(">",ShipDat["type"]," [color=#949495]Speed: [",ShipDat["engine"]["speed"],"]")
		$HBoxContainer/Main/HBoxContainer/Buy.icon_align = Button.ALIGN_RIGHT
		$HBoxContainer/Main/HBoxContainer/Buy.align = Button.ALIGN_RIGHT
		var twee = get_tree().create_tween()
		twee.tween_property($HBoxContainer/Main/HBoxContainer/Buy, "rect_min_size", Vector2(215,12),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")

func fastreturn():
	if $HBoxContainer/Main/HBoxContainer/Buy.icon_align == Button.ALIGN_LEFT:
		$HBoxContainer/Main/HBoxContainer/Buy.text = str("$",ShipDat["purchasePrice"])
		$HBoxContainer/Main/Details/Type.bbcode_text = str(">",ShipDat["type"]," [color=#949495]Speed: [",ShipDat["engine"]["speed"],"]")
		$HBoxContainer/Main/HBoxContainer/Buy.icon_align = Button.ALIGN_RIGHT
		$HBoxContainer/Main/HBoxContainer/Buy.align = Button.ALIGN_RIGHT
		var twee = get_tree().create_tween()
		twee.tween_property($HBoxContainer/Main/HBoxContainer/Buy, "rect_min_size", Vector2(215,12),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")

func _on_Buy_pressed():
	if (float(Agent.AgentCredits)-float(ShipDat["purchasePrice"])) < 0:
		$HBoxContainer/Main/HBoxContainer/Buy.text = "INSUFFICIENT FUNDS"
		yield(get_tree().create_timer(1),"timeout")
		$HBoxContainer/Main/HBoxContainer/Buy.text = str("$",ShipDat["purchasePrice"])
	elif !doubleConfirm:
		doubleConfirm = true
		$HBoxContainer/Main/HBoxContainer/Buy.icon_align = Button.ALIGN_LEFT
		$HBoxContainer/Main/HBoxContainer/Buy.align = Button.ALIGN_LEFT
		var twee = get_tree().create_tween()
		twee.tween_property($HBoxContainer/Main/HBoxContainer/Buy, "rect_min_size", Vector2(350,12),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")
		$HBoxContainer/Main/HBoxContainer/Buy.text = "Are You Sure?"
		$HBoxContainer/Main/Details/Type.bbcode_text = str(Agent.AgentCredits," - [color=#F33A6A]",ShipDat["purchasePrice"],"[/color] = ",(float(Agent.AgentCredits)-float(ShipDat["purchasePrice"])))
		returnbutton()
	elif doubleConfirm:
		doubleConfirm = false
		Agent.purchaseShip(ShipDat["type"],Waypoint,self)

func _on_request_completed(result, response_code, headers, body):
	if result == 4:
		print("bad",result,response_code)
		return
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("PurchaseShip")
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass


func _on_ShipPurchase_mouse_entered():
	print("hi",ShipDat["name"])


func _on_ShipPurchase_mouse_exited():
	pass # Replace with function body.
