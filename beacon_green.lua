modbeacon2.register_beacon("beacon2:green",{
	description = modbeacon2.translate("Green Beacon"),
	protected = true,
	light_height = 50,

	tiles_beacon = {"greenbeacon.png"},
	tiles_base = {"greenbase.png"},
	tiles_beam = {"greenbeam.png"},

	node_base = "beacon2:greenbase",
	node_beam = "beacon2:greenbeam",
	
	particle = "greenparticle.png",
	dye_collor = "dye:green",
	
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=64, g=255, b=64},

	alias = {modbeacon2.translate("beacongreen"), "sinalizadorverde"},
})
