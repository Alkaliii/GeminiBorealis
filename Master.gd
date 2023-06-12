extends Node

export var symbol = "Gemini_Three"
export var faction = "COSMIC"
export var token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoiR0VNSU5JX1RIUkVFIiwidmVyc2lvbiI6InYyIiwicmVzZXRfZGF0ZSI6IjIwMjMtMDYtMTAiLCJpYXQiOjE2ODY0NzA3NzAsInN1YiI6ImFnZW50LXRva2VuIn0.S9y4Ja9nBxhsaNrRBRayDHz9HZHR_pu8eFGMgeP9Ob4XK6Ns2qG3pG3UmDmnbGhuyh5iRDN1qGoaIj-_dX2ash97uyCvdZqutrWOdsCfhzi8V2FHNKjd0GgZ2PiLc_-PusiV4ZGKJzRnwCSA8kzZVKKxYdxGTQphk900o2798snIYHQrYdqq2OLHstQxjjeWrr4IgHthRvS_NiNNEAtxaLML5nTyS0vyvxgdRBM4sn3Qf7wSm498qwS8SKX3XuAbtBgT9xCv7ee-jEq17DlhKtAOgW9FoM_8KAgyL_iAjQ3AlbGHzmLyV058PL_bBMbmEpbFVJ1jwlisdCdweqHB5Q"
#eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoiR0VNSU5JX1RIUkVFIiwidmVyc2lvbiI6InYyIiwicmVzZXRfZGF0ZSI6IjIwMjMtMDYtMTAiLCJpYXQiOjE2ODY0NzA3NzAsInN1YiI6ImFnZW50LXRva2VuIn0.S9y4Ja9nBxhsaNrRBRayDHz9HZHR_pu8eFGMgeP9Ob4XK6Ns2qG3pG3UmDmnbGhuyh5iRDN1qGoaIj-_dX2ash97uyCvdZqutrWOdsCfhzi8V2FHNKjd0GgZ2PiLc_-PusiV4ZGKJzRnwCSA8kzZVKKxYdxGTQphk900o2798snIYHQrYdqq2OLHstQxjjeWrr4IgHthRvS_NiNNEAtxaLML5nTyS0vyvxgdRBM4sn3Qf7wSm498qwS8SKX3XuAbtBgT9xCv7ee-jEq17DlhKtAOgW9FoM_8KAgyL_iAjQ3AlbGHzmLyV058PL_bBMbmEpbFVJ1jwlisdCdweqHB5Q

# Called when the node enters the scene tree for the first time.
func _ready():
	Agent.connect("shipyard", self, "moveCamera")
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	$Button.text = "view_system"

func moveCamera(data = null):
	var twee = get_tree().create_tween()
	twee.tween_property($Camera2D, "position", Vector2(1024,0),1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func moveCameraTo(pos):
	var twee = get_tree().create_tween()
	twee.tween_property($Camera2D, "position", pos,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

func _process(delta):
	pass

#Simply provide token in header str("Authorization: Bearer ", token)
#view agent: 'https://api.spacetraders.io/v2/my/agent'
#view system: 'https://api.spacetraders.io/v2/systems/X1-SS23/waypoints/X1-SS23-95750A' systems/systemsymbol and waypoints/waypointsymbol
#view contracts: 'https://api.spacetraders.io/v2/my/contracts'
#accept contact (POST): 'https://api.spacetraders.io/v2/my/contracts/clir55ij711lms60d6rm6pq1b/accept' contracts/contractsymbol

func _on_Button_pressed():
	var url = "https://api.spacetraders.io/v2/systems/X1-SS23/waypoints/X1-SS23-95750A"
	var headerstring = str("Authorization: Bearer ", token)
	var header = [headerstring]
	var data = JSON.print({"symbol": symbol, "faction": faction})
	$HTTPRequest.request(url, header)
	#$HTTPRequest.request(url, header, true, HTTPClient.METHOD_POST, data)



func _on_ShipyardExitButton_pressed():
	moveCameraTo(Vector2.ZERO)
