extends Control

const SCM = {
	"NEUTRON_STAR":
		{"text":"#f8fafc","bg":"#475569"},
	"RED_STAR":
		{"text":"#fef2f2","bg":"#b91c1c"},
	"ORANGE_STAR":
		{"text":"#431407","bg":"#fdba74"},
	"BLUE_STAR":
		{"text":"#083344","bg":"#22d3ee"},
	"YOUNG_STAR":
		{"text":"#022c22","bg":"#6ee7b7"},
	"WHITE_DWARF":
		{"text":"#030712","bg":"#f9fafb"},
	"BLACK_HOLE":
		{"text":"#f9fafb","bg":"#030712"},
	"HYPERGIANT":
		{"text":"#2e1065","bg":"#c4b5fd"},
	"NEBULA":
		{"text":"#fdf2f8","bg":"#db2777"},
	"UNSTABLE":
		{"text":"#eef2ff","bg":"#4f46e5"}
}

func setdat(data,rcont):
	animateOUT()
	var Type = $Focus/Type
	var Symbol = $Focus/Info/Symbol
	var RSS = $Focus/Info/rangesystemships
	var coords = $Focus/Info/Coords 
	
	Type.self_modulate = Color(SCM[data["type"]]["bg"])
	var nosector = str(data["symbol"]).replace(data["sectorSymbol"],"").replace("-","")
	var faction = ""
	if !data["factions"].empty(): faction = str(" [wave][color=#69696b](",data["factions"][0]["symbol"],")")
	Symbol.bbcode_text = str(data["sectorSymbol"],"-[b]",nosector,"[/b]",faction)
	
	var RANGE = str("[",rcont," sys]")
	var SYSTEM = str("[",data["waypoints"].size()," wpts]")
	var scont = 0
	for s in Automation._FleetData: if Automation._FleetData[s]["nav"]["systemSymbol"] == data["symbol"]:
		scont += 1
	var SHIPS = ""
	match scont:
		0: SHIPS = str("[",scont," ships]")
		1: SHIPS = str("[",scont," ship]")
		_: SHIPS = str("[",scont," ships]")
	RSS.bbcode_text = str(RANGE,"/",SYSTEM,"/",SHIPS)
	
	coords.bbcode_text = str("[color=#69696b]position. x:[b]",data["x"],"[/b]/y:[b]",data["y"])
	animateIN()

func animateIN():
	var Type = $Focus/Type #fade in?
	var Symbol = $Focus/Info/Symbol #type in
	var RSS = $Focus/Info/rangesystemships #type in
	var coords = $Focus/Info/Coords #type in
	var twee = get_tree().create_tween()
	Type.modulate = Color(1,1,1,0)
	Symbol.percent_visible = 0
	RSS.percent_visible = 0
	coords.percent_visible = 0
	
	twee.tween_property(Type,"modulate",Color(1,1,1,1),1)
	twee.parallel().tween_property(Symbol,"percent_visible",1,0.5)
	twee.parallel().tween_property(RSS,"percent_visible",1,0.5).set_delay(0.2)
	twee.parallel().tween_property(coords,"percent_visible",1,0.5).set_delay(0.2)
	
func animateOUT():
	var Type = $Focus/Type #fade in?
	var Symbol = $Focus/Info/Symbol #type in
	var RSS = $Focus/Info/rangesystemships #type in
	var coords = $Focus/Info/Coords #type in
	var twee = get_tree().create_tween()
#	Type.modulate = Color(1,1,1,0)
#	Symbol.percent_visible = 0
#	RSS.percent_visible = 0
#	coords.percent_visible = 0
	
	twee.tween_property(Type,"modulate",Color(1,1,1,0),0.2)
	twee.parallel().tween_property(Symbol,"percent_visible",0,0.2)
	twee.parallel().tween_property(RSS,"percent_visible",0,0.2)
	twee.parallel().tween_property(coords,"percent_visible",0,0.2)
	
	
