extends VBoxContainer


const line = preload("res://300line.tscn")
const linesmall= preload("res://300linesmall.tscn")
const button = preload("res://ContractAccept.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	Agent.connect("login", self, "show")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func show():
	self.modulate = Color(1,1,1,0)
	self.visible = true
	var twee = get_tree().create_tween()
	twee.tween_property(self, "modulate", Color(1,1,1,1), 1)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		setdat(cleanbody, true)
	else:
		getfail()
	print(json.result)

func getfail():
	$Button.hide()
	$Label.bbcode_text = "[shake][b][color=#EE4B2B]Refresh Failed"
	yield(get_tree().create_timer(3), "timeout")
	$Label.percent_visible = 0
	$Label.bbcode_text = "Avalible Contracts"
	var tweeRTL = get_tree().create_tween()
	tweeRTL.tween_property($RichTextLabel, "percent_visible", 1, 1)
	yield(tweeRTL,"finished")
	$Button.show()

func setdat(data, anim = false):
	for r in $List.get_children():
		r.queue_free()
	for o in data["data"]:
		var acceptbutton = null
		var status = o["accepted"]
		if status == false: 
			status = "[Not Started]"
			acceptbutton = button.instance()
			acceptbutton.text = "[Accept]"
			acceptbutton.CID = o["id"]
		else: status = "[In Progress]"
		
		var title = line.instance()
		title.bbcode_text = str("[b]CONTACT ", (data["data"].find(o)+1),"[/b][color=#71797E] ", o["id"])
		var subtile = line.instance()
		subtile.bbcode_text = str(status,"[b]#[/b]",o["type"])
		var rewards = linesmall.instance()
		rewards.bbcode_text = str("[b]$",(o["terms"]["payment"]["onAccepted"]+o["terms"]["payment"]["onFulfilled"]),"[/b][color=#71797E] ", o["expiration"])
		
		$List.add_child(title)
		$List.add_child(rewards)
		$List.add_child(subtile)
		for d in o["terms"]["deliver"]:
			var newline = line.instance()
			newline.bbcode_text = str(d["tradeSymbol"]," x[b]",(d["unitsRequired"] - d["unitsFulfilled"]),"[/b]")
			$List.add_child(newline)
		if acceptbutton != null: $List.add_child(acceptbutton)

func _on_Button_pressed():
	var url = "https://api.spacetraders.io/v2/my/contracts"
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	$HTTPRequest.request(url, header)
