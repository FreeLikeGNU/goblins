
minetest.register_node(":default:mossycobble", {
	description = "Mossy Cobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	light_source = 2,
})




minetest.register_node("goblins:mushroom_goblin", {
	description = "gobble mushroom",
	tiles = {"goblins_mushroom_brown.png"},
	inventory_image = "goblins_mushroom_brown.png",
	wield_image = "goblins_mushroom_brown.png",
	drawtype = "plantlike",
	paramtype = "light",
    light_source = 2,
	sunlight_propagates = true,
	walkable = true,
	buildable_to = true,
	groups = {mushroom = 1, food_mushroom = 1, snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	on_use = minetest.item_eat(2),
	selection_box = {
		type = "fixed",
		fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
	}
})

