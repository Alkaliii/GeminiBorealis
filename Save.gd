extends Node


const savePath = "user://USER_SAVE%s.json"
const clientSavePath = "user://CLIENT_SAVE.json"

var clientVer = "0.1.0"
var pastTokens : Dictionary

var groups : Dictionary

var _file = File.new()

signal loadClientComplete
signal ShipAssigned

func _ready():
	loadClientSave()
	Agent.connect("login",self,"loadUserSave")

func loadClientSave():
	var error = _file.open(clientSavePath, File.READ)
	if error != OK:
		Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [clientSavePath,error])
		printerr("Could not open %s. Aborting load operation. err: %s" % [clientSavePath,error])
		return
	
	var content = _file.get_as_text()
	_file.close()
	
	var data = JSON.parse(content).result
	pastTokens = data["past_tokens"]
	
	emit_signal("loadClientComplete")

func writeClientSave():
	var error = _file.open(clientSavePath, File.WRITE)
	if error != OK:
		Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [clientSavePath,error])
		printerr("Could not open %s. Aborting save operation. err: %s" % [clientSavePath,error])
		return
	
	var data = {
		"client_version": clientVer,
		"past_tokens": pastTokens
	}
	
	var JSONIFY = JSON.print(data)
	_file.store_string(JSONIFY)
	_file.close()
	
	print("saved")

func loadUserSave():
	var error = _file.open(savePath % Agent.AgentSymbol, File.READ)
	if error != OK:
		Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		return
	
	var content = _file.get_as_text()
	_file.close()
	
	var data = JSON.parse(content).result
	Agent.surveys = data["surveys"]

func writeUserSave():
	var error = _file.open(savePath % Agent.AgentSymbol, File.WRITE)
	if error != OK:
		Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		return
	
	var data = {
		"client_version": clientVer,
		"surveys": Agent.surveys
	}
	
	var JSONIFY = JSON.print(data)
	_file.store_string(JSONIFY)
	_file.close()
	
	print("saved")
