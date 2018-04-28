modbeacon2.register_beacon("beacon2:red",{
	description = modbeacon2.translate("Red Beacon"),
	protected = true,
	light_height = 50,

	tiles_beacon = {"redbeacon.png"},
	tiles_base = {"redbase.png"},
	tiles_beam = {"redbeam.png"},

	node_base = "beacon2:redbase",
	node_beam = "beacon2:redbeam",
	
	particle = "redparticle.png",
	dye_collor = "dye:red",

	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=0, b=0},
	
	alias = {modbeacon2.translate("beaconred"), "sinalizadorvermelho"},
})
