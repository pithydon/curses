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

minetest.register_node("curses:infertile_dirt", {
	description = "Infertile Dirt",
	tiles = {"default_dirt.png"},
	groups = {crumbly = 3},
	sounds = default.node_sound_dirt_defaults()
})

minetest.register_craft({
	type = "shapeless",
	output = "curses:infertile_dirt",
	recipe = {"curses:curse", "default:dirt"}
})

local dirts = {"default:dirt", "default:dirt_with_grass",
		"default:dirt_with_grass_footsteps", "default:dirt_with_dry_grass",
		"default:dirt_with_snow"}

for _,v in ipairs(dirts) do
	minetest.override_item(v, {
		on_curse = function(pos)
			minetest.swap_node(pos, {name = "curses:infertile_dirt"})
		end
	})
end

minetest.register_node("curses:filth_water", {
	description = "Filth Water",
	drawtype = "liquid",
	tiles = {"curses_filth_water.png"},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "curses:filth_water",
	liquid_alternative_source = "curses:filth_water",
	liquid_viscosity = 4,
	liquid_renewable = false,
	liquid_range = 0,
	damage_per_second = 4,
	post_effect_color = {a = 255, r = 57, g = 56, b = 12},
	groups = {oddly_breakable_by_hand = 1}
})

local waters = {"default:water_source", "default:river_water_source"}

for _,v in ipairs(waters) do
	minetest.override_item(v, {
		on_curse = function(pos)
			minetest.swap_node(pos, {name = "curses:filth_water"})
		end
	})
end

local trees = {"default:tree", "default:jungletree",
		"default:pine_tree", "default:acacia_tree", "default:aspen_tree"}

for _,v in ipairs(trees) do
	local node_def = minetest.registered_nodes[v]
	local subname = v:split(":")[2]
	minetest.register_node("curses:"..subname.."_monster", {
		description = node_def.description.." Monster",
		tiles = {node_def.tiles[1], node_def.tiles[1], node_def.tiles[3],
				node_def.tiles[3], node_def.tiles[3], node_def.tiles[3].."^curses_"..subname.."_monster.png"},
		paramtype2 = "facedir",
		groups = node_def.groups,
		drop = v,
		sounds = default.node_sound_wood_defaults(),
		on_rotate = screwdriver.disallow
	})

	minetest.override_item(v, {
		on_curse = function(pos)
			minetest.swap_node(pos, {name = "curses:"..subname.."_monster"})
		end
	})
end

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

minetest.register_node("curses:soul_sand", {
	description = "Soul Sand",
	tiles = {"curses_soul_sand_top.png", "curses_soul_sand.png"},
	groups = {crumbly = 3, falling_node = 1, disable_jump = 1},
	sounds = default.node_sound_sand_defaults()
})

local sands = {"default:sand", "default:desert_sand"}

for _,v in ipairs(sands) do
	minetest.register_craft({
		type = "shapeless",
		output = "curses:soul_sand",
		recipe = {"curses:curse", v}
	})

	minetest.override_item(v, {
		on_curse = function(pos)
			minetest.swap_node(pos, {name = "curses:soul_sand"})
		end
	})
end
