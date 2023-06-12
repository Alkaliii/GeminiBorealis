extends Button

export var CID : String
var doubleConfirm = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
#	if cleanbody.has("data"):
#		setdat(cleanbody, true)
#	else:
#		getfail()
	print(json.result)

func _on_ContractAccept_pressed():
	if doubleConfirm == false:
		doubleConfirm = true
		self.text = "[Confirm]"
		$AnimationPlayer.play("Flicker")
	elif doubleConfirm:
		var url = str("https://api.spacetraders.io/v2/my/contracts/",CID,"/accept")
		var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
		var header = ["Accept: application/json",headerstring,"Content-Type: application/json"]
		$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST)
