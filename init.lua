minetest.register_craftitem("curses:curse", {
	description = "Curse",
	inventory_image = "curses_curse.png",
	wield_image = "curses_curse.png",
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = minetest.get_pointed_thing_position(pointed_thing, above)
		if pointed_thing.type == "node" and not minetest.is_protected(pos, placer:get_player_name()) then
			local node = minetest.get_node(pos)
			local node_def = minetest.registered_nodes[node.name]
			if node_def.on_curse then
				node_def.on_curse(pos)
				if not minetest.setting_getbool("creative_mode") then
					itemstack:take_item()
					return itemstack
				end
			end
		end
	end
})

minetest.register_craftitem("curses:curse_start", {
	description = "Curse Start",
	inventory_image = "curses_curse_start.png",
	wield_image = "curses_curse_start.png",
})

minetest.register_craft({
	type = "cooking",
	output = "curses:curse",
	recipe = "curses:curse_start",
})

minetest.register_craft({
	output = "curses:curse_start",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "bones:bones", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})

minetest.register_craft({
	output = "curses:curse_start",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:nyancat", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})

dofile(minetest.get_modpath("curses").."/default.lua")
if minetest.get_modpath("farming") and farming.mod == "redo" then dofile(minetest.get_modpath("curses").."/farming_plus.lua") end
