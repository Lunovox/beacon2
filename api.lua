modbeacon2 = {}
modbeacon2.beacon_atual = {}
modbeacon2.max_height = 50

if minetest.get_modpath("intllib") then
	modbeacon2.translate = intllib.Getter()
else
	modbeacon2.translate = function(txt) return (txt or "") end
end

minetest.register_node("beacon2:empty", {
	description = modbeacon2.translate("Unactivated Beacon"),
	tiles = {"emptybeacon.png"},
	light_source = 3,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon2:empty",
})

minetest.register_craft({
	output = 'beacon2:empty',
	recipe = {
		{'default:steel_ingot'				, 'default:glass'		, 'default:steel_ingot'},
		{'default:mese_crystal_fragment'	, 'default:torch'		, 'default:mese_crystal_fragment'},
		{'default:obsidian'					, 'default:obsidian'	, 'default:obsidian'},
	}
})

modbeacon2.can_interact = function(pos, playername)
	--minetest.log('error',dump(playername))	
	if type(playername)=="string" and playername~="" then
		local meta = minetest.get_meta(pos);
		local ownername = meta:get_string("owner") 
		if ownername=="" or playername == ownername 
			or minetest.get_player_privs(playername).server
			or (
				minetest.get_modpath("landrush")
				and landrush~=nil 
				and landrush.get_owner(pos)~=nil 
				and landrush.can_interact(pos, playername)
			)
		then
			return true
		end
	end
	return false
end

modbeacon2.getFormspec = function(playername, nameBeaconPos)
	local charBeacons = modsavevars.getCharValue(playername, "beacons")
	if type(charBeacons)=="table" then
		if type(charBeacons[nameBeaconPos])=="table"  then
			if type(charBeacons[nameBeaconPos].name)=="string" then
				return "size[8,1.5]"..
				--"bgcolor[#FFFFFFBB;false]"..
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				--"label[0,0;Nome do Farol]"..
				"field[0.5,0.5;7.5,1;txtName;"..modbeacon2.translate("Beacon Name")..";"..minetest.formspec_escape(charBeacons[nameBeaconPos].name or "").."]"..
				"button_exit[3.0,1.0;2,1;btnRename;"..modbeacon2.translate("RENAME").."]"..
				default.get_hotbar_bg(0, 4.25)
			else
				minetest.chat_send_all("type(charBeacons[nameBeaconPos].name)="..type(charBeacons[nameBeaconPos].name))
			end
		else
			minetest.chat_send_all("type(charBeacons[nameBeaconPos])="..type(charBeacons[nameBeaconPos]))
		end
	end
end

modbeacon2.register_beacon = function(nodename, def)
	minetest.register_node(nodename, {
		description = def.description,
		tiles = def.tiles_beacon,
		light_source = 13,
		groups = {cracky=3,oddly_breakable_by_hand=3},
		drop = nodename,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local playername = placer:get_player_name()
			local meta = minetest.get_meta(pos);
			meta:set_string("owner", playername)
			meta:set_string("infotext",  def.description.." of '"..playername.."'")		
			if minetest.get_modpath("lib_savevars") then
				local posAbove = pointed_thing.above --acima
				local posUnder = pointed_thing.under --abaixo
				local nameBeaconPos = "x"..posUnder.x..",y"..posUnder.y..",z"..posUnder.z
				meta:set_string("beacon_namepos",  nameBeaconPos)
				local charBeacons = modsavevars.getCharValue(playername, "beacons")
				
				if type(charBeacons)~="table" then charBeacons={} end
				
				charBeacons[nameBeaconPos]={}
				charBeacons[nameBeaconPos].pos = posUnder
				charBeacons[nameBeaconPos].color = def.post_effect_color
				charBeacons[nameBeaconPos].name = nameBeaconPos

				modsavevars.setCharValue(playername, "beacons", charBeacons)
				modbeacon2.huds.add_waypoints(placer)
			end
		end,
		on_destruct = function(pos) --remove the beam above a source when source is removed
			for i=1,(def.light_height or modbeacon2.max_height) do
				local node = minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z})
				if node and node.name==def.node_base or node.name==def.node_beam then
					minetest.remove_node({x=pos.x, y=pos.y+i, z=pos.z}) --thanks Morn76 for this bit of code!
				end
			end
			if minetest.get_modpath("lib_savevars") then
				local meta = minetest.get_meta(pos);
				local ownername = meta:get_string("owner")
				local ownerplayer = minetest.get_player_by_name(ownername)
				local nameBeaconPos = meta:get_string("beacon_namepos")
				local charBeacons = modsavevars.getCharValue(ownername, "beacons")
				if type(charBeacons)=="table" and type(charBeacons[nameBeaconPos])=="table" then
					charBeacons[nameBeaconPos] = nil
					if ownerplayer~= nil and ownerplayer:is_player() then
						ownerplayer:hud_remove(modbeacon2.huds.waypoints[ownername][nameBeaconPos])
					end
				end
				modsavevars.setCharValue(ownername, "beacons", charBeacons)
			end
		end,
		can_dig = function(pos, player)
			if def.protected or false then
				return modbeacon2.can_interact(pos, player:get_player_name())
			end
			return true
		end,
		on_rightclick = function(pos, node, clicker)
			local meta = minetest.get_meta(pos)
			local playername = clicker:get_player_name()
			local ownername = meta:get_string("owner")
			local nameBeaconPos = meta:get_string("beacon_namepos")
			
			if playername == ownername then 
				modbeacon2.beacon_atual[playername] = nameBeaconPos
				minetest.show_formspec(
					playername,
					"beacon_"..playername,
					modbeacon2.getFormspec(playername, nameBeaconPos)
				)
			end
		end,
	})
	
	minetest.register_craft({
		output = nodename,
		recipe = {
			{''					, def.dye_collor	, ''},
			{def.dye_collor	, "beacon2:empty"	, def.dye_collor},
			{''					, def.dye_collor	, ''},
		}
	})
	
	minetest.register_craft({
		output = "beacon2:empty",
		recipe = {
			{''				, "dye:white"	, ''},
			{"dye:white"	, nodename		, "dye:white"},
			{''				, "dye:white"	, ''},
		}
	})
	
	if def.alias and #def.alias >=1 then
		for i=1,#def.alias do
			minetest.register_alias(def.alias[i] ,nodename)
		end
	end
	
	--Blue Beam
	minetest.register_node(def.node_base, {
		visual_scale = 1.0,
		drawtype = "plantlike",
		tiles = def.tiles_base,
		paramtype = "light",
		walkable = false,
		diggable = false,
		pointable = false,
		buildable_to = true,	
		light_source = 50, --padrao = 13
		damage_per_second = def.damage_per_second or 0,
		post_effect_color = def.post_effect_color,
		groups = {not_in_creative_inventory=1},
	})

	minetest.register_node(def.node_beam, {
		visual_scale = 1.0,
		drawtype = "plantlike",
		tiles = def.tiles_beam,
		paramtype = "light",
		walkable = false,
		diggable = false,
		pointable = false,
		buildable_to = true,
		light_source = 50,
		damage_per_second = def.damage_per_second or 0,
		post_effect_color = def.post_effect_color,
		groups = {not_in_creative_inventory=1},
	})

	minetest.register_abm({
		nodenames = {nodename, def.node_base, def.node_beam},
		interval = 5,
		chance = 1,
		action = function(pos)
			if minetest.get_node(pos).name==nodename then
				pos.y = pos.y + 1 --Sobe um bloco
				if minetest.get_node(pos).name=="ignore" or minetest.get_node(pos).name=="air" then
					minetest.add_node(pos, {name=def.node_base})
					for i=1,(def.light_height or modbeacon2.max_height) do
						if minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z}).name=="ignore" or minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z}).name=="air" then
							minetest.add_node({x=pos.x, y=pos.y+i, z=pos.z}, {name=def.node_beam})
						else
							break
						end
					end
				end
			elseif minetest.get_node(pos).name==def.node_base or minetest.get_node(pos).name==def.node_beam then
				pos.y = pos.y - 1 --Desce um bloco
				for i=0,(def.light_height or modbeacon2.max_height) do
					if minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z}).name~=nodename 
						and minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z}).name~=def.node_beam 
						and minetest.get_node({x=pos.x, y=pos.y+i, z=pos.z}).name~=def.node_base 
					then
						minetest.remove_node({x=pos.x, y=pos.y+i+1, z=pos.z}) --thanks Morn76 for this bit of code!
					else
						break
					end
				end
			end
		end,
	})
	
	if type(def.particle)=="string" and def.particle~="" then
		minetest.register_abm({
			nodenames = {def.node_base}, --makes small particles emanate from the beginning of a beam
			interval = 1,
			chance = 2,
			action = function(pos, node)
				minetest.add_particlespawner({
					amount = 32,
					time = 4,
					minpos = {x=pos.x-0.25, y=pos.y-0.25, z=pos.z-0.25},
					maxpos = {x=pos.x+0.25, y=pos.y+0.25, z=pos.z+0.25},
					minvel = {x=-0.8,	y=-0.8,	z=-0.8},
					maxvel = {x=0.8,	y=0.8,	z=0.8},
					minacc = {x=0, y=0, z=0},
					maxacc = {x=0, y=0, z=0},
					minexptime = 0.5,
					maxexptime = 1,
					minsize = 1,
					maxsize = 2,
					collisiondetection = false,
					vertical = true,
					texture = def.particle,
					--playername = "singleplayer",
				})
			end,
		})
	end
end

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	local playername = sender:get_player_name()
	if formname == "beacon_"..playername then
		--minetest.chat_send_all("fields="..dump(fields))
		local nameBeaconPos = modbeacon2.beacon_atual[playername]
		if type(fields.txtName)=="string" then
			local charBeacons = modsavevars.getCharValue(playername, "beacons")
			if type(charBeacons)=="table" then
				if type(charBeacons[nameBeaconPos])=="table"  then
					if fields.name~="" then
						charBeacons[nameBeaconPos].name = fields.txtName
					else
						charBeacons[nameBeaconPos].name = nameBeaconPos
					end
					modsavevars.setCharValue(playername, "beacons", charBeacons)
					modbeacon2.huds.update_waypoints(sender)
				end
			end
		end
	end
end)
--modbeacon2.beacon_atual[playername]

if minetest.get_modpath("lib_savevars") then
	modbeacon2.huds = {}
	modbeacon2.huds.waypoints = {}
	modbeacon2.huds.doHex2rgb = function(hex)
		 hex = hex:gsub("#","")
		 return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	end
	modbeacon2.huds.doRgb2hex = function(rgb)
		local colors = {rgb.r, rgb.g, rgb.b}
		local hexadecimal = '0X'

		for key, value in pairs(colors) do
			local hex = ''

			while(value > 0)do
				local index = math.fmod(value, 16) + 1
				value = math.floor(value / 16)
				hex = string.sub('0123456789ABCDEF', index, index) .. hex			
			end

			if(string.len(hex) == 0)then
				hex = '00'

			elseif(string.len(hex) == 1)then
				hex = '0' .. hex
			end

			hexadecimal = hexadecimal .. hex
		end

		return hexadecimal
	end
	modbeacon2.huds.add_waypoints = function(player)
		if player~= nil and player:is_player() then
			local playername = player:get_player_name()
			local charBeacons = modsavevars.getCharValue(playername, "beacons")
			--minetest.chat_send_all("type(charBeacons)="..type(charBeacons))
			if type(charBeacons)=="table" then
				if type(modbeacon2.huds.waypoints[playername])=="nil" then modbeacon2.huds.waypoints[playername] = {} end
				for nameBeaconPos in pairs(charBeacons) do
					local thisBeacon = charBeacons[nameBeaconPos]
					 --minetest.chat_send_all("nameBeaconPos="..dump(nameBeaconPos))
					 --minetest.chat_send_all("thisBeacon="..dump(thisBeacon))
					 
					 modbeacon2.huds.waypoints[playername][nameBeaconPos] = player:hud_add({
						hud_elem_type = "waypoint",
						name = thisBeacon.name,
						number = modbeacon2.huds.doRgb2hex(thisBeacon.color), 
						world_pos = thisBeacon.pos
					})
				end
			end
		end
	end
	modbeacon2.huds.update_waypoints = function(player)
		if player~= nil and player:is_player() then
			local playername = player:get_player_name()
			local charBeacons = modsavevars.getCharValue(playername, "beacons")
			if type(charBeacons)=="table" then
				for nameBeaconPos in pairs(charBeacons) do
					local thisBeacon = charBeacons[nameBeaconPos]
					--minetest.chat_send_all("type(modbeacon2.huds.waypoints[playername][nameBeaconPos])="..dump(type(modbeacon2.huds.waypoints[playername][nameBeaconPos])))
					--minetest.chat_send_all("modbeacon2.huds.waypoints[playername][nameBeaconPos]="..dump(modbeacon2.huds.waypoints[playername][nameBeaconPos]))
					if type(modbeacon2.huds.waypoints[playername][nameBeaconPos])=="number" then
						player:hud_change(modbeacon2.huds.waypoints[playername][nameBeaconPos], "name", thisBeacon.name)
					else
						--modbeacon2.huds.add_waypoints(player)
					end
				end
			end
		end
	end
	minetest.register_on_joinplayer(function(player)
		modbeacon2.huds.add_waypoints(player)
	end)
	minetest.after(3, function()
		minetest.register_globalstep(function(dtime)
			local players = minetest.get_connected_players()
			if #players >= 1 then
				local uptime = 10.0 + (#players * dtime * 2) --Não sei se 0.3 e rapido d+ ou lento d+
				if modbeacon2.huds.time==nil or type(modbeacon2.huds.time)~="number" then 
					modbeacon2.huds.time = 0 
				end
				modbeacon2.huds.time = modbeacon2.huds.time + dtime; -- 'dtime' e sempre uma fracao entre 0 e 1
				--print("modbeacon2.huds.time("..modbeacon2.huds.time..") >= uptime("..uptime..")")
				if modbeacon2.huds.time >= uptime then --atualiza a barra do jogador a cada 'uptime' segundos (se hp tiver mudado)
					--OBS.: Não sei se o valor 0.1 acima
					for _, player in ipairs(players) do
						if player~= nil and player:is_player() then
							if type(modbeacon2.huds.update_waypoints) ~= "nil" then
								modbeacon2.huds.update_waypoints(player)
							end
						end
					end
					modbeacon2.huds.time = 0
				end
			end
		end)
	end)
end
