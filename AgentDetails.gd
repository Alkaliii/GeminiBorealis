extends Node

export var AID : String
export var AgentCredits : String
export var Headquaters : String
export var CurrentSystem : String
export var AgentFaction : String
export var AgentSymbol : String
export var USERTOKEN : String

signal login
signal chart(cleanbody)
signal shipyard(cleanbody)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func cleanHQ():
	var delete = true
	var HQ = Headquaters
	while delete:
		if HQ[(HQ.length()-1)] == "-":
			HQ.erase(HQ.length()-1, 1)
			delete = false
			break
		else: HQ.erase(HQ.length()-1, 1)
	CurrentSystem = HQ
