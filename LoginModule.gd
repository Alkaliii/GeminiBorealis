extends VBoxContainer

var token


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		login(cleanbody)
		setdat(cleanbody["data"]["symbol"], cleanbody["data"]["credits"], true)
	else:
		logfail()
	print(json.result)

func logfail():
	$Button.hide()
	$RichTextLabel.bbcode_text = "[shake][b][color=#EE4B2B]Login Failed"
	yield(get_tree().create_timer(3), "timeout")
	$RichTextLabel.percent_visible = 0
	$RichTextLabel.bbcode_text = "[b]Access Token"
	var tweeRTL = get_tree().create_tween()
	tweeRTL.tween_property($RichTextLabel, "percent_visible", 1, 1)
	yield(tweeRTL,"finished")
	$Button.show()

func login(data):
	Agent.USERTOKEN = token
	Agent.AID = data["data"]["accountId"]
	Agent.AgentCredits = data["data"]["credits"]
	Agent.Headquaters = data["data"]["headquarters"]
	Agent.AgentFaction = data["data"]["startingFaction"]
	Agent.AgentSymbol = data["data"]["symbol"]
	Agent.cleanHQ()
	Agent.emit_signal("login")

func setdat(symbol, credits, anim = false):
	if anim:
		var twee = get_tree().create_tween()
		twee.tween_property(self, "rect_position", Vector2(30,30),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	$RichTextLabel.bbcode_text = "Success!"
	$User.bbcode_text = str("[b][User]:[/b] ",symbol)
	$Credits.bbcode_text = str("[b][Credits]:[/b] ",credits)
	$Faction.bbcode_text = str("[b][Faction]:[/b] ", Agent.AgentFaction)
	$LineEdit.hide()
	$Button.hide()
	$User.show()
	$Credits.show()
	$Faction.show()
	
	
	yield(get_tree().create_timer(3), "timeout")
	$RichTextLabel.percent_visible = 0
	$RichTextLabel.bbcode_text = "Gemini Borealis"
	var tweeRTL = get_tree().create_tween()
	tweeRTL.tween_property($RichTextLabel, "percent_visible", 1, 1)

func _on_Button_pressed():
	token = $LineEdit.text
	if token == "token": token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoiR0VNSU5JX1RIUkVFIiwidmVyc2lvbiI6InYyIiwicmVzZXRfZGF0ZSI6IjIwMjMtMDYtMTAiLCJpYXQiOjE2ODY0NzA3NzAsInN1YiI6ImFnZW50LXRva2VuIn0.S9y4Ja9nBxhsaNrRBRayDHz9HZHR_pu8eFGMgeP9Ob4XK6Ns2qG3pG3UmDmnbGhuyh5iRDN1qGoaIj-_dX2ash97uyCvdZqutrWOdsCfhzi8V2FHNKjd0GgZ2PiLc_-PusiV4ZGKJzRnwCSA8kzZVKKxYdxGTQphk900o2798snIYHQrYdqq2OLHstQxjjeWrr4IgHthRvS_NiNNEAtxaLML5nTyS0vyvxgdRBM4sn3Qf7wSm498qwS8SKX3XuAbtBgT9xCv7ee-jEq17DlhKtAOgW9FoM_8KAgyL_iAjQ3AlbGHzmLyV058PL_bBMbmEpbFVJ1jwlisdCdweqHB5Q"
	var url = "https://api.spacetraders.io/v2/my/agent"
	var headerstring = str("Authorization: Bearer ", token)
	var header = [headerstring]
	$HTTPRequest.request(url, header)
