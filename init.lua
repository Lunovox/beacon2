local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/api.lua")

dofile(modpath.."/beacon_blue.lua")
dofile(modpath.."/beacon_green.lua")
dofile(modpath.."/beacon_purple.lua")
dofile(modpath.."/beacon_red.lua")

minetest.log('action',"["..modname:upper().."] Carregado!")
