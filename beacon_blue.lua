modbeacon2.register_beacon("beacon2:blue",{
	description = modbeacon2.translate("Blue Beacon"),
	protected = true,
	light_height = 50,

	tiles_beacon = {"bluebeacon.png"},
	tiles_base = {"bluebase.png"},
	tiles_beam = {"bluebeam.png"},

	node_base = "beacon2:bluebase",
	node_beam = "beacon2:bluebeam",
	
	particle = "blueparticle.png",
	dye_collor = "dye:blue",
	
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=64, g=64, b=255},
	
	alias = {modbeacon2.translate("beaconblue"), "sinalizadorazul"},
})
