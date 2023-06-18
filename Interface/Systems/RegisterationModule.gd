extends VBoxContainer

export var control : NodePath
export var anim: NodePath

var factions : Dictionary

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	getFactions()

func getFactions():
	var HTTP = HTTPRequest.new()
	HTTP.use_threads = true
	HTTP.connect("request_completed",self,"_on_FACrequest_completed")
	self.add_child(HTTP)
	var url = str("https://api.spacetraders.io/v2/factions?limit=20")
	#var headerstring = str("Authorization: Bearer ", testtoken)
	var header = []#headerstring]
	HTTP.request(url, header)
	
	yield(HTTP,"request_completed")
	HTTP.queue_free()

func _on_FACrequest_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		for f in cleanbody["data"]:
			factions[f["name"]] = f["symbol"]
			$OptionButton.add_item(f["name"])

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		Register(cleanbody)
	else:
		logfail(cleanbody)
	print(json.result)

func logfail(data):
	$Button.hide()
	if data["error"]["data"].has("symbol"):
		$RichTextLabel.bbcode_text = str("[shake][b][color=#EE4B2B]ERROR:[/color][/b] ", data["error"]["data"]["symbol"])
	elif data["error"]["data"].has("faction"):
		$RichTextLabel.bbcode_text = str("[shake][b][color=#EE4B2B]ERROR:[/color][/b] ", data["error"]["data"]["faction"])
	yield(get_tree().create_timer(3), "timeout")
	$RichTextLabel.percent_visible = 0
	$RichTextLabel.bbcode_text = "[b]REGISTRATION"
	var tweeRTL = get_tree().create_tween()
	tweeRTL.tween_property($RichTextLabel, "percent_visible", 1, 1)
	yield(tweeRTL,"finished")
	$Button.show()

func Register(data):
	$Button.hide()
	$RichTextLabel.bbcode_text = "[b][center]TOKEN COPIED TO CLIPBOARD"
	yield(get_tree().create_timer(2),"timeout")
	$RichTextLabel.bbcode_text = "[b][center]KEEP IT SAFE!"
	OS.set_clipboard(data["data"]["token"])
	yield(get_tree().create_timer(1),"timeout")
	
	Agent.USERTOKEN = data["data"]["token"]
	Agent.AID = data["data"]["agent"]["accountId"]
	Agent.AgentCredits = data["data"]["agent"]["credits"]
	Agent.Headquaters = data["data"]["agent"]["headquarters"]
	Agent.AgentFaction = data["data"]["agent"]["startingFaction"]
	Agent.AgentSymbol = data["data"]["agent"]["symbol"]
	Agent.cleanHQ()
	Agent.emit_signal("login")
	
	Save.pastTokens[Agent.AgentSymbol] = {"token": Agent.USERTOKEN,"symbol": Agent.AgentSymbol,"faction": Agent.AgentFaction,"date": Time.get_unix_time_from_system()}
	Save.writeClientSave()
	
	var twee = get_tree().create_tween()
	get_node(anim).play("Out")
	twee.tween_property(get_node(control), "rect_scale", Vector2(2,2),1).set_trans(Tween.TRANS_EXPO)
	yield(twee,"finished")
	get_node(control).queue_free()



func _on_Button_pressed():
	var symbol = $Symbol.text
	var faction = factions[$OptionButton.get_item_text($OptionButton.selected)]
	var url = "https://api.spacetraders.io/v2/register"
	var header = ["Accept: application/json","Content-Type: application/json"]
	var data = JSON.print({"symbol": symbol, "faction": faction})
	$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST, data)
