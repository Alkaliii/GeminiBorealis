extends VBoxContainer

var contractDat
const contractline = preload("res://Interface/Agent/ContractModule.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("login", self, "getContracts")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var cleanbody = json.result
	if cleanbody.has("data"):
		contractDat = cleanbody
	else:
		Agent.dispError(cleanbody)
		#getfail()
	print(json.result)

func getfail():
	pass

func getContracts():
	var url = "https://api.spacetraders.io/v2/my/contracts"
	var headerstring = str("Authorization: Bearer ", Agent.USERTOKEN)
	var header = [headerstring]
	$HTTPRequest.request(url, header)
	yield($HTTPRequest,"request_completed")
	
	for r in $ScrollContainer/List.get_children():
		r.queue_free()
	
	for c in contractDat["data"]:
		var contract = contractline.instance()
		contract.setdat(c)
		$ScrollContainer/List.add_child(contract)


func _on_Button_pressed():
	getContracts()
