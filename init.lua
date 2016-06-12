minetest.register_craftitem("curses:curse", {
  description = "Curse",
  inventory_image = "curses_curse.png",
  wield_image = "curses_curse.png",
  on_place = function(itemstack, placer, pointed_thing)
    if pointed_thing.type == "node" then
			local pos = minetest.get_pointed_thing_position(pointed_thing, above)
			local node = minetest.get_node(pos)
			local node = minetest.registered_nodes[node.name]
			if node.on_curse then
				node.on_curse(pos)
      	local creative = minetest.setting_getbool("creative_mode")
      	if not creative then
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

minetest.register_node("curses:tree_monster", {
	description = "Tree Monster",
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png", "default_tree.png", "default_tree.png", "default_tree.png^curses_tree_monster.png"},
	paramtype2 = "facedir",
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	drop = "default:tree",
	sounds = default.node_sound_wood_defaults(),
	on_rotate = screwdriver.disallow
})

minetest.override_item("default:tree", {
	on_curse = function(pos)
		minetest.swap_node(pos, {name = "curses:tree_monster"})
	end
})

minetest.register_abm({
	nodenames = {"curses:tree_monster"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local objs = minetest.env:get_objects_inside_radius(pos, 5)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
				local player_pos = obj:getpos()
				local dir = vector.direction(player_pos, pos)
				local facedir = minetest.dir_to_facedir(dir)
				minetest.swap_node(pos, {name = "curses:tree_monster", param2 = facedir})
				if minetest.setting_getbool("enable_damage") then
					local face_pos
					if facedir == 0 then
						face_pos = {x = 0, y = 0, z = -1}
					elseif facedir == 1 then
						face_pos = {x = -1, y = 0, z = 0}
					elseif facedir == 2 then
						face_pos = {x = 0, y = 0, z = 1}
					elseif facedir == 3 then
						face_pos = {x = 1, y = 0, z = 0}
					end
					local pos = vector.add(pos, face_pos)
					local lof, pos = minetest.line_of_sight(pos, player_pos, 0.25)
					if lof then
						obj:set_hp(obj:get_hp()-1)
					else
						local node = minetest.get_node(pos)
						local node = minetest.registered_nodes[node.name]
						if node.buildable_to then
							local pos = vector.add(pos, face_pos)
							local lof, pos = minetest.line_of_sight(pos, player_pos, 0.25)
							if lof then
								obj:set_hp(obj:get_hp()-1)
							end
						end
					end
				end
			end
		end
	end
})
