extends Control

var swap = false

const prev = preload("res://Interface/Login/PreviousUser.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_Swap_pressed()
	#yield(Save,"loadClientComplete")
	for t in Save.pastTokens:
		var newprev = prev.instance()
		newprev.setdat(Save.pastTokens[t])
		newprev.connect("LoginPressed",$HBoxContainer/Login/Login,"_on_USERButton_pressed")
		$HBoxContainer/CenterContainer/PrevUserList/VBoxContainer.add_child(newprev)


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
