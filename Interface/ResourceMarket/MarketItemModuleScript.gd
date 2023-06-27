extends Control

var goodDat
var doubleConfirm = false
export var ws : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/HBoxContainer2/OptionButton.add_item("Buy")
	$VBoxContainer/HBoxContainer/HBoxContainer2/OptionButton.add_item("Sell")
	$VBoxContainer/HBoxContainer/HBoxContainer2/OptionButton.add_item("Sell All")

func setdat(data):
	goodDat = data
	var Supply = $VBoxContainer/HBoxContainer/VBoxContainer/Supply
	var Good = $VBoxContainer/HBoxContainer/VBoxContainer/TradeGood
	var Volume = $VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit
	var Report = $VBoxContainer/InventoryReport
	
	Supply.bbcode_text = str("[b]",data["supply"],"[/b] SELL:[$",data["sellPrice"],"]")
	Good.bbcode_text = str("[$[b][color=#40B5AD]",data["purchasePrice"],"[/color][/b]] ",data["symbol"])
	Volume.placeholder_text = str(data["tradeVolume"])
	
	var amountavalible = 0
	var total = 0
	for s in Agent._FleetData["data"]:
		var amt = 0
		var sym = data["symbol"]
		for c in s["cargo"]["inventory"]:
			if c["symbol"] == sym:
				amt = c["units"]
		if s["nav"]["waypointSymbol"] == ws:
			amountavalible += amt
		total += amt
	
	Report.bbcode_text = str("[right]You have [b]",amountavalible,"[/b] onhand,[b] ",total,"[/b] total.")

func returnbutton():
	yield(get_tree().create_timer(6),"timeout")
	if doubleConfirm:
		doubleConfirm = false
		$VBoxContainer/HBoxContainer/HBoxContainer2/Button.text = ""
		$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.show()
		var twee = get_tree().create_tween()
		twee.tween_property($VBoxContainer/HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(20,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		

func fastreturn():
	doubleConfirm = false
	$VBoxContainer/HBoxContainer/HBoxContainer2/Button.text = ""
	$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.show()
	var twee = get_tree().create_tween()
	twee.tween_property($VBoxContainer/HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(20,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

func _on_Button_pressed():
	if !doubleConfirm:
		doubleConfirm = true
		$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.hide()
		var twee = get_tree().create_tween()
		twee.tween_property($VBoxContainer/HBoxContainer/HBoxContainer2/Button,"rect_min_size",Vector2(160,20),0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		yield(twee,"finished")
		$VBoxContainer/HBoxContainer/HBoxContainer2/Button.text = "Are You Sure?"
		returnbutton()
	elif doubleConfirm:
		doubleConfirm = false
		match $VBoxContainer/HBoxContainer/HBoxContainer2/OptionButton.selected:
			0: #Buy
				#Entered Valid Data
				if !$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text.is_valid_integer():
					$VBoxContainer/InventoryReport.bbcode_text = "[right][shake]please enter a [b]number"
					fastreturn()
					return
				
				#Has Cargo Space
				var ais
				for s in Agent._FleetData["data"]:
					if s["symbol"] == Agent.interfaceShip:
						ais = s
				if int($VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text) > (ais["cargo"]["capacity"]-ais["cargo"]["units"]):
					$VBoxContainer/InventoryReport.bbcode_text = str("[right][shake]please enter a number [b]lower than ",(ais["cargo"]["capacity"]-ais["cargo"]["units"])+1)
					fastreturn()
					return
				
				#Has Cash
				if (goodDat["purchasePrice"]*int($VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text)) > int(Agent.AgentCredits):
					$VBoxContainer/InventoryReport.bbcode_text = str("[right][b]INSUFFICIENT FUNDS")
					fastreturn()
					return
				Agent.purchaseCargo(goodDat["symbol"],$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text,self)
			1,2: #Sell
				#Sell All
				if $VBoxContainer/HBoxContainer/HBoxContainer2/OptionButton.selected == 2:
					var unit
					var ais
					for s in Agent._FleetData["data"]:
						if s["symbol"] == Agent.interfaceShip:
							ais = s
					for g in ais["cargo"]["inventory"]:
						if g["symbol"] == goodDat["symbol"]:
							unit = g["units"]
					Agent.sellCargo(goodDat["symbol"],unit,self)
					return
				#Entered Valid Data
				if !$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text.is_valid_integer():
					$VBoxContainer/InventoryReport.bbcode_text = "[right][shake]please enter a [b]number"
					fastreturn()
					return
				
				#Has Cargo to Sell
				var ais
				for s in Agent._FleetData["data"]:
					if s["symbol"] == Agent.interfaceShip:
						ais = s
				if ais["cargo"]["units"] == 0:
					$VBoxContainer/InventoryReport.bbcode_text = "[right]you have [b]nothing[/b] to sell"
					fastreturn()
					return
				var cansell = false
				for g in ais["cargo"]["inventory"]:
					if g["symbol"] == goodDat["symbol"]: 
						cansell = true
						if g["units"] < int($VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text):
							$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text = str(g["units"])
				if !cansell:
					$VBoxContainer/InventoryReport.bbcode_text = "[right]you have [b]nothing[/b] to sell"
					fastreturn()
					return
				Agent.sellCargo(goodDat["symbol"],$VBoxContainer/HBoxContainer/HBoxContainer2/LineEdit.text,self)

func _on_BUYrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("PurchaseCargo",cleanbody)
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass

func _on_SELLrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Agent.emit_signal("SellCargo",cleanbody)
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)


func _on_OptionButton_item_selected(index):
	var Supply = $VBoxContainer/HBoxContainer/VBoxContainer/Supply
	var Good = $VBoxContainer/HBoxContainer/VBoxContainer/TradeGood
	match index:
		0: #Buy
			Supply.bbcode_text = str("[b]",goodDat["supply"],"[/b] SELL:[$",goodDat["sellPrice"],"]")
			Good.bbcode_text = str("[$[b][color=#40B5AD]",goodDat["purchasePrice"],"[/color][/b]] ",goodDat["symbol"])
		1: #Sell
			Supply.bbcode_text = str("[b]",goodDat["supply"],"[/b] BUY:[$",goodDat["purchasePrice"],"]")
			Good.bbcode_text = str("[$[b][color=#F33A6A]",goodDat["sellPrice"],"[/color][/b]] ",goodDat["symbol"])
		2: #Sell All
			Supply.bbcode_text = str("[b]",goodDat["supply"],"[/b] BUY:[$",goodDat["purchasePrice"],"]")
			Good.bbcode_text = str("[$[b][color=#F33A6A]",goodDat["sellPrice"],"[/color][/b]] ",goodDat["symbol"])
