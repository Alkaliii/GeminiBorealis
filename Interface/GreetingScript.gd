extends Control

const greetings = ["How are you?", "Working hard?","Hardly working?", "What's up?",
"Good Day!", "Hello!", "Ah yes!", "Hey!", "Long time no see", "No way it's", "Howdy",
"[wave]YOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO", "The one and only",
"All systems online! I think..."
]

func _ready():
	Agent.connect("updateAgent",self,"setdat")

func setdat():
	var text = $TextandName/text
	var A_name = $TextandName/name
	var credits = $TextandName/Overview/Credits/creditAMT
	var ships = $TextandName/Overview/Ships/shipAMT
	var officers = $TextandName/Overview/Officers/officerAMT
	
	var textrng = RandomNumberGenerator.new()
	textrng.randomize()
	var num = textrng.randi_range(0,greetings.size()-1)
	text.bbcode_text = greetings[num]
	
	A_name.bbcode_text = str("[b]",Agent.AgentSymbol)
	credits.bbcode_text = str("[center]",Agent.AgentCredits)
	var shipcount = Automation._FleetData.size()
	ships.bbcode_text = str("[center]",shipcount)
	var officercount = 0
	for c in Automation.get_children():
		if c is HTTPRequest: continue
		officercount += c.get_child_count()
	officers.bbcode_text = str("[center]~",officercount)
