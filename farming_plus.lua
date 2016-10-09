minetest.register_node("curses:jackolantern", {
	description = "Cursed Jack 'O Lantern",
	tiles = {
		"farming_pumpkin_top.png",
		"farming_pumpkin_top.png",
		"farming_pumpkin_side.png",
		"farming_pumpkin_side.png",
		"farming_pumpkin_side.png",
		"farming_pumpkin_face_on.png"
	},
	light_source = default.LIGHT_MAX - 1,
	paramtype2 = "facedir",
	groups = {choppy = 1, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults(),
	drop = "farming:jackolantern"
})

minetest.override_item("farming:jackolantern", {
	on_curse = function(pos)
		minetest.swap_node(pos, {name = "curses:jackolantern"})
	end
})

minetest.override_item("farming:jackolantern_on", {
	on_curse = function(pos)
		minetest.swap_node(pos, {name = "curses:jackolantern"})
	end
})

minetest.register_abm({
	nodenames = {"curses:jackolantern"},
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
				local face_pos
				if facedir == 0 then
					face_pos = {x = pos.x, y = pos.y, z = pos.z - 1}
				elseif facedir == 1 then
					face_pos = {x = pos.x - 1, y = pos.y, z = pos.z}
				elseif facedir == 2 then
					face_pos = {x = pos.x, y = pos.y, z = pos.z + 1}
				elseif facedir == 3 then
					face_pos = {x = pos.x + 1, y = pos.y, z = pos.z}
				end
				local under_face_pos = {x = face_pos.x, y = face_pos.y - 1, z = face_pos.z}
				if vector.distance(player_pos, face_pos) <= 1 or vector.distance(player_pos, under_face_pos) <= 1 then
					local face_node = minetest.get_node_or_nil(face_pos)
					if face_node then
						if not minetest.registered_nodes[face_node.name].walkable then
							minetest.set_node(face_pos, {name = "fire:basic_flame"})
						end
					end
				end
			end
		end
	end
})
