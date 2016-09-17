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

local curse_a_tree = function(name)
	local node_def = minetest.registered_nodes[name]
	local subname = name:split(":")[2]
	minetest.register_node("curses:"..subname.."_monster", {
		description = node_def.description.." Monster",
		tiles = {node_def.tiles[1], node_def.tiles[1], node_def.tiles[3],
				node_def.tiles[3], node_def.tiles[3], node_def.tiles[3].."^curses_"..subname.."_monster.png"},
		paramtype2 = "facedir",
		groups = node_def.groups,
		drop = name,
		sounds = default.node_sound_wood_defaults(),
		on_rotate = screwdriver.disallow
	})

	minetest.override_item(name, {
		on_curse = function(pos)
			minetest.swap_node(pos, {name = "curses:"..subname.."_monster"})
		end
	})
end

curse_a_tree("default:tree")
curse_a_tree("default:jungletree")
curse_a_tree("default:pine_tree")
curse_a_tree("default:acacia_tree")
curse_a_tree("default:aspen_tree")

minetest.register_abm({
	nodenames = {
		"curses:tree_monster",
		"curses:jungletree_monster",
		"curses:pine_tree_monster",
		"curses:acacia_tree_monster",
		"curses:aspen_tree_monster"
	},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local objs = minetest.env:get_objects_inside_radius(pos, 5)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
				local player_pos = obj:getpos()
				local dir = vector.direction(player_pos, pos)
				local facedir = minetest.dir_to_facedir(dir)
				minetest.swap_node(pos, {name = node.name, param2 = facedir})
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
