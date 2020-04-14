--more things to craft soon...
local craft_ingreds = {
	mossycobble = "default:mossycobble",
}

for name, mat in pairs(craft_ingreds) do
	minetest.register_craft({
		output = "goblins:pick_".. name,
		recipe = {
			{mat, mat, mat},
			{"", "group:stick", ""},
			{"", "group:stick", ""}
		}
	})
end


minetest.register_tool("goblins:pick_mossycobble", {
	description = "Mossycobble Pickaxe",
	inventory_image = "default_tool_stonepick.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[2]=1.8, [3]=0.90}, uses=25, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})
