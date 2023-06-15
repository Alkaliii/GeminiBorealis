extends CenterContainer

const Asteroid = preload("res://EXTERNAL/Planets/Asteroids/Asteroid.tscn")
const DryTerran = preload("res://EXTERNAL/Planets/DryTerran/DryTerran.tscn")
const GasPlanet = preload("res://EXTERNAL/Planets/GasPlanet/GasPlanet.tscn")
const RingGas = preload("res://EXTERNAL/Planets/GasPlanetLayers/GasPlanetLayers.tscn")
const IceWorld = preload("res://EXTERNAL/Planets/IceWorld/IceWorld.tscn")
const LandMass = preload("res://EXTERNAL/Planets/LandMasses/LandMasses.tscn")
const Lava = preload("res://EXTERNAL/Planets/LavaWorld/LavaWorld.gd")
const NoAtmo = preload("res://EXTERNAL/Planets/Asteroids/NoAtmosphere.tscn")
const River = preload("res://EXTERNAL/Planets/Rivers/Rivers.tscn")
const Star = preload("res://EXTERNAL/Planets/Star/Star.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func genStar(data,ints,intol,intlong):
	var star
	star = Star.instance()
	#star.set_pixels(200)
	star.set_seed(int(intlong))
	star.rect_scale = Vector2(4,4)
	match data["data"]["type"]:
		"NEUTRON_STAR": pass
		"RED_STAR": pass
		"ORANGE_STAR": pass
		"BLUE_STAR": pass
		"YOUNG_STAR": pass
		"WHITE_DWARF": pass
		"BLACK_HOLE": pass
		"HYPERGIANT": pass
		"NEBULA": pass
		"UNSTABLE": pass
	self.add_child(star)
	self.update()
