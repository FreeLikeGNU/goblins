dofile(minetest.get_modpath("goblins").."/traps.lua")

-- Npc by TenPlus1 converted for FLG Goblins :D

local goblin_drops = {
	"default:pick_steel",  "default:sword_steel",
	"default:shovel_steel", "farming:bread", "bucket:bucket_water"
}

local goblin_sounds = {
	random = "goblins_goblin_ambient",
	warcry = "goblins_goblin_attack",
	attack = "goblins_goblin_attack",
	damage = "goblins_goblin_damage",
	death = "goblins_goblin_death",
	replace = "goblins_goblin_pick",
	distance = 15,
}

local debugging_goblins = true

-- local routine for do_custom so that api doesn't need changed
local search_replace2 = function(
	self,
	search_rate,
	search_rate_above,
	search_rate_below,
	search_offset,
	search_offset_above,
	search_offset_below,
	replace_rate,
	replace_what,
	replace_with,
	replace_rate_secondary,
	replace_with_secondary)

	if math.random(1, search_rate) == 1 then
		-- look for nodes
		local pos  = vector.round(self.object:getpos())
		local pos1 = vector.round(self.object:getpos())
		local pos2 = vector.round(self.object:getpos())

		-- if we are looking, will we look below and by how much?
		if math.random(1, search_rate_below) == 1 then
			pos1.y = pos1.y - search_offset_below
		end

		-- if we are looking, will we look above and by how much?
		if math.random(1, search_rate_above) == 1 then
			pos2.y = pos2.y + search_offset_above
		end

		pos1.x = pos1.x - search_offset
		pos1.z = pos1.z - search_offset
		pos2.x = pos2.x + search_offset
		pos2.z = pos2.z + search_offset

		if debugging_goblins then
			print (self.name:split(":")[2]
			.. " at "
			.. minetest.pos_to_string(pos)
			.. " is searching between "
			.. minetest.pos_to_string(pos1)
			.. " and "
			.. minetest.pos_to_string(pos2))
		end

		local nodelist = minetest.find_nodes_in_area(pos1, pos2, replace_what)
		if #nodelist > 0 then
			--print (#nodelist.." nodes found by "..self.description.." !!!")
			--for k,v in pairs(nodelist) do print(minetest.get_node(v).name.. " found!!") end
			for key,value in pairs(nodelist) do 
				-- ok we see some nodes around us, are we going to replace them?
				if math.random(1, replace_rate) == 1 then
					if replace_rate_secondary and
					math.random(1, replace_rate_secondary) == 1 then
						minetest.set_node(value, {name = replace_with_secondary})
						if debugging_goblins == true then
							print(replace_with_secondary.." placed")
						end
					else
						minetest.set_node(value, {name = replace_with})
						if debugging_goblins == true then
							print(replace_with.." placed")
						end
					end
					minetest.sound_play(self.sounds.replace, {
						object = self.object,
						max_hear_distance = self.sounds.distance
					})
				end
			end
		end
	end
end

mobs:register_mob("goblins:goblin_cobble", {
	description = "Cobble Goblin",
	type = "animal",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_cobble1.png"},
			{"goblins_goblin_cobble2.png"},
			
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:mossycobble",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:torch",
		chance = 3, min = 1, max = 10},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	lifetimer = 360,
	follow = {"default:diamond", "default:apple", "farming:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		20, --search_rate
		1, --search_rate_above
		1, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:desert_stone",
			"default:torch"}, --replace_what
		"default:mossycobble", --replace_with
		3, --replace_rate_secondary
		"goblins:mossycobble_trap" --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_cobble", "Goblin Egg (cobble)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_digger", {
	description = "Digger Goblin",
	type = "animal",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_digger.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:mossycobble",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:torch",
		chance = 3, min = 1, max = 10},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	lifetimer = 360,
	follow = {"default:diamond", "default:apple", "default:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		5, --search_rate
		20, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		1, --search_offset_above
		1.1, --search_offset_below
		4, --replace_rate
		{	"group:soil",
			"group:sand",
			"default:gravel",
			"default:stone",
			"default:desert_stone",
			"default:torch"}, --replace_what
		"air", --replace_with
		nil, --replace_rate_secondary
		nil --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_coal", {
	description = "Coal Goblin",
	type = "animal",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_coal1.png"},
			{"goblins_goblin_coal2.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:coal_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:torch",
		chance = 3, min = 1, max = 10},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "farming:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:stone_with_coal",
			"default:torch"}, --replace_what
		"air", --replace_with
		3, --replace_rate_secondary
		"goblins:stone_with_coal_trap" --replace_with_secondary
		)
	end,

})
mobs:register_egg("goblins:goblin_coal", "Goblin Egg (coal)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_iron", {
	description = "Iron Goblin",
	type = "monster",
	passive = false,
	damage = 2,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_iron1.png"},
			{"goblins_goblin_iron2.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:iron_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:pick_steel",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "default:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:desert_stone",
			"default:stone_with_iron",
			"default:torch"}, --replace_what
		"air", --replace_with
		3, --replace_rate_secondary
		"goblins:stone_with_iron_trap" --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_iron", "Goblin Egg (iron)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_copper", {
	description = "Copper Goblin",
	type = "monster",
	passive = false,
	damage = 2,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_copper1.png"},
			{"goblins_goblin_copper2.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:copper_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:pick_steel",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "default:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:desert_stone",
			"default:stone_with_copper",
			"default:torch"}, --replace_what
		"air", --replace_with
		3, --replace_rate_secondary
		"goblins:stone_with_copper_trap" --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_copper", "Goblin Egg (copper)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_gold", {
	description = "Gold Goblin",
	type = "monster",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 10,
	hp_max = 30,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
	textures = {
		{"goblins_goblin_gold1.png"},
		{"goblins_goblin_gold2.png"},
	},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:gold_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:gold_ingot",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "farming:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:desert_stone",
			"default:stone_with_gold",
			"default:torch"}, --replace_what
		"air", --replace_with
		3, --replace_rate_secondary
		"goblins:stone_with_gold_trap" --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_gold", "Goblin Egg (gold)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_diamond", {
	description = "Diamond Goblin",
	type = "monster",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_diamond1.png"},
			{"goblins_goblin_diamond2.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:pick_diamond",
		chance = 1, min = 1, max = 1},
		{name = "default:apple",
		chance = 2, min = 1, max = 10},
		{name = "default:diamond",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "farming:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"default:stone",
			"default:desert_stone",
			"default:stone_with_diamond",
			"default:torch"}, --replace_what
		"air", --replace_with
		3, --replace_rate_secondary
		"goblins:stone_with_diamond_trap" --replace_with_secondary
		)
	end,

})
mobs:register_egg("goblins:goblin_diamond", "Goblin Egg (diamond)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_king", {
	description = "Goblin King",
	type = "monster",
	passive = false,
	damage = 4,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 20,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_king.png"},
		},
	makes_footstep_sound = true,
	sounds = goblin_sounds,
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:pick_mese",
		chance = 1, min = 1, max = 1},
		{name = "default:apple",
		chance = 2, min = 1, max = 10},
		{name = "default:mese_crystal",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond", "default:apple", "farming:bread"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},

	on_rightclick = function(self, clicker)
		-- feed to heal goblin (breed and tame set to false)
		if not mobs:feed_tame(self, clicker, 8, false, false) then
			local item = clicker:get_wielded_item()
			local name = clicker:get_player_name()

			-- right clicking with gold lump drops random item from mobs.npc_drops
			if item:get_name() == "default:gold_lump" then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				local pos = self.object:getpos()
				pos.y = pos.y + 0.5
				minetest.add_item(pos, {
					name = goblin_drops[math.random(1, #goblin_drops)]
				})
				return
			end
		end
	end,

	do_custom = function(self)
		search_replace2(
		self,
		10, --search_rate
		1, --search_rate_above
		20, --search_rate_below
		1, --search_offset
		2, --search_offset_above
		1, --search_offset_below
		5, --replace_rate
		{	"group:stone",
			"default:torch"}, --replace_what
		"default:mossycobble", --replace_with
		3, --replace_rate_secondary
		"goblins:mossycobble_trap" --replace_with_secondary
		)
	end,
})
mobs:register_egg("goblins:goblin_king", "Goblin King Egg", "default_mossycobble.png", 1)

-- spawn at or below 0 near ore and dungeons and goblin lairs (areas of mossy cobble), except diggers that will dig out caves from stone and cobble goblins who create goblin lairs near stone.
--function mobs_goblins:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height)
--[[
mobs:register_spawn("goblins:goblin_cobble", {"group:stone"}, 100, 0, 20, 4, 0)
mobs:register_spawn("goblins:goblin_digger", {"group:stone"}, 100, 0, 20, 4, 0)
mobs:register_spawn("goblins:goblin_coal", {"default:stone_with_coal"}, 100, 0, 1, 3, 0)
mobs:register_spawn("goblins:goblin_iron", {"default:stone_with_iron"}, 100, 0, 1, 3, -20)
mobs:register_spawn("goblins:goblin_copper", {"default:stone_with_copper","default:mossycobble"}, 100, 0, 1, 3, -30)
mobs:register_spawn("goblins:goblin_gold", {"default:stone_with_gold" }, 100, 0, 1, 2, -40)
mobs:register_spawn("goblins:goblin_diamond", {"default:stone_with_diamond"}, 100, 0, 1, 2, -60)
mobs:register_spawn("goblins:goblin_king", {"default:stone_with_mese","default:mossycobble", }, 100, 0, 2, 1, -100)
]]
--[[ function mobs_goblins:spawn_specific(
name,
nodes, 
neighbors, 
min_light, 
max_light, 
interval, 
chance, 
active_object_count, 
min_height, 
max_height)
]]
mobs:spawn_specific("goblins:goblin_cobble", {"group:stone"}, "air", 0, 50, 1, 10, 3, -30000 , 0)
mobs:spawn_specific("goblins:goblin_digger", {"group:stone"},  "air", 0, 50, 1, 10, 3, -30000 , 0)
mobs:spawn_specific("goblins:goblin_coal", {"default:stone_with_coal", "default:mossycobble"}, "air",0, 50, 1, 2, 3, -30000, 0)
mobs:spawn_specific("goblins:goblin_iron", {"default:stone_with_iron", "default:mossycobble"}, "air", 0, 50, 1, 2, 3, -30000, -20)
mobs:spawn_specific("goblins:goblin_copper", {"default:stone_with_copper", "default:mossycobble"}, "air", 0, 50, 1, 2, 3, -30000, -20)
mobs:spawn_specific("goblins:goblin_gold", {"default:stone_with_gold", "default:mossycobble"}, "air",0, 50, 1, 2, 3, -30000, -40)
mobs:spawn_specific("goblins:goblin_diamond", {"default:stone_with_diamond", "default:mossycobble" }, "air", 0, 50, 1,2, 3, -30000, -80)
mobs:spawn_specific("goblins:goblin_king", {"default:mossycobble",},"air", 0, 50, 1, 10, 3, -30000, -100)

print ("[MOD] Goblins loaded")