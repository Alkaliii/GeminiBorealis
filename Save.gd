extends Node


const savePath = "user://USER_SAVE%s.json"
const clientSavePath = "user://CLIENT_SAVE.json"
const universeSavePath = "user://universe.json"
const jumpSavePath = "user://jump.json"

var clientVer = "0.1.0"

#Client
var pastTokens : Dictionary
var universe = {
	"version": null,
	"data": null
}
var jump = {
	"version": null,
	"data": null
}

#User
var groups : Dictionary

var _file = File.new()

signal loadClientComplete
signal loadDataComplete
signal ShipAssigned

func _ready():
	loadClientSave()
	Agent.connect("login",self,"loadUserSave")

func loadClientSave():
	var error = _file.open(clientSavePath, File.READ)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [clientSavePath,error])
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
		#Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [clientSavePath,error])
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
		#Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		return
	
	var content = _file.get_as_text()
	_file.close()
	
	var data = JSON.parse(content).result
	Agent.surveys = data["surveys"]
	Agent.networth = data["networth"]
	Agent.sellgood = data["sellgood"]
	Agent.sellship = data["sellship"]
	
	emit_signal("loadDataComplete")

func writeUserSave():
	var error = _file.open(savePath % Agent.AgentSymbol, File.WRITE)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		return
	
	var data = {
		"client_version": clientVer,
		"surveys": Agent.surveys,
		"networth": Agent.networth,
		"sellgood": Agent.sellgood,
		"sellship": Agent.sellship
	}
	
	var JSONIFY = JSON.print(data)
	_file.store_string(JSONIFY)
	_file.close()
	
	print("saved user data to file")

func loadUniverse():
	var error = _file.open(universeSavePath, File.READ)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting load operation. err: %s" % [universeSavePath,error])
		return
	
	var content = _file.get_as_text()
	_file.close()
	
	var data = JSON.parse(content).result
	universe.version = data.version
	universe.data = data.data
	
	emit_signal("loadDataComplete")

func writeUniverse():
	var error = _file.open(universeSavePath, File.WRITE)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting save operation. err: %s" % [universeSavePath,error])
		return
	
	var data = universe
	
	var JSONIFY = JSON.print(data)
	_file.store_string(JSONIFY)
	_file.close()
	
	print("saved universe to file")

func loadJump():
	var error = _file.open(jumpSavePath, File.READ)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting load operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting load operation. err: %s" % [jumpSavePath,error])
		return
	
	var content = _file.get_as_text()
	_file.close()
	
	var data = JSON.parse(content).result
	jump.version = data.version
	jump.data = data.data
	#print("loaded JUMP")
	emit_signal("loadDataComplete")

func writeJump():
	var error = _file.open(jumpSavePath, File.WRITE)
	if error != OK:
		#Agent.dispError("Could not open %s. Aborting save operation. err: %s" % [savePath % Agent.AgentSymbol,error])
		printerr("Could not open %s. Aborting save operation. err: %s" % [jumpSavePath,error])
		return
	
	var data = jump
	
	var JSONIFY = JSON.print(data)
	_file.store_string(JSONIFY)
	_file.close()
	
	print("saved jumpdata to file")
