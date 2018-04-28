modbeacon2.register_beacon("beacon2:purple",{
	description = modbeacon2.translate("Purple Beacon"),
	protected = true,
	light_height = 50,

	tiles_beacon = {"purplebeacon.png"},
	tiles_base = {"purplebase.png"},
	tiles_beam = {"purplebeam.png"},

	node_base = "beacon2:purplebase",
	node_beam = "beacon2:purplebeam",
	
	particle = "purpleparticle.png",
	dye_collor = "dye:violet",
	
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=64, b=255},

	alias = {modbeacon2.translate("beaconpurple"), "sinalizadorpurple"},
})
