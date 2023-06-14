extends Control

var swap = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_Swap_pressed()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Swap_pressed():
	swap = !swap
	#True: ONLOGIN
	#False:ONREGISTER
	if swap:
		$MenuBack/Swap.text = "REGISTER"
		$HBoxContainer/Login/Login.show()
		$HBoxContainer/Login/Register.hide()
	else:
		$MenuBack/Swap.text = "LOGIN"
		$HBoxContainer/Login/Register.show()
		$HBoxContainer/Login/Login.hide()
