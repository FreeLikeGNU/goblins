dofile(minetest.get_modpath("goblins").."/traps.lua")
dofile(minetest.get_modpath("goblins").."/nodes.lua")
dofile(minetest.get_modpath("goblins").."/items.lua")
dofile(minetest.get_modpath("goblins").."/soundsets.lua")
dofile(minetest.get_modpath("goblins").."/behaviors.lua")
dofile(minetest.get_modpath("goblins").."/animals.lua")
-- Npc by TenPlus1 converted for FLG Goblins :D

minetest.log("action", "[MOD] goblins 20200423 is lowdings....")

local announce_spawning_goblins = true

goblins.defaults = {  --your average goblin, 
  type = "npc",
  passive = false,
  damage = 1,
  reach = 2,
  knock_back = true,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  runaway = true,
  runaway_from = "player",
  hp_min = 5,
  hp_max = 10,
  armor = 100,
  visual = "mesh",
  mesh = "goblins_goblin.b3d",
  textures = {
    {"goblins_goblin_cobble1.png"},
    {"goblins_goblin_cobble2.png"},

  },
 -- collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
  collisionbox = {-0.25, -1, -0.25, 0.25, .1, 0.25},
  drawtype = "front",	
  makes_footstep_sound = true,
  sounds = {
    random = "goblins_goblin_breathing",
    warcry = "goblins_goblin_warcry",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "goblins_goblin_cackle", gain = 0.05,
    distance = 15},
  walk_velocity = 2,
  run_velocity = 3,
  jump = true,
  fear_height = 4,
  water_damage = 0,
  lava_damage = 2,
  light_damage = 1,
  lifetimer = 360,
  view_range = 10,
  stay_near = "group:stone",
  owner = "",
  order = "follow",
  animation = {
    
    stand_speed = 30,
    stand_start = 0,
    stand_end = 79,
    walk_speed = 30,
    walk_start = 168,
    walk_end = 187,
    run_speed = 45,
    run_start = 168,
    run_end = 187,
    punch_speed = 30,
    punch_start = 200,
    punch_end = 219,
  },
  drops = {
    "default:pick_steel",  "default:sword_steel",
    "default:shovel_steel", "farming:bread", "bucket:bucket_water","goblins:goblins_goblin_bone","goblins:goblins_goblin_bone_meaty"
  }
}

local announce_goblin_spawn = function(self)
  if announce_spawning_goblins == true then    
    local pos = vector.round(self.object:getpos())
    if not pos then return end
    print( self.name:split(":")[2].. " spawned at: " .. minetest.pos_to_string(pos))
  end                    
end

-- local routine for do_custom so that api doesn't need to be changed

local give_goblin = function(self,clicker)        
  -- feed to heal goblin (breed and tame set to false)
  if not mobs:feed_tame(self, clicker, 8, false, false) then
    local item = clicker:get_wielded_item()
    local name = clicker:get_player_name()
    --print(dump({item, name}))
    -- right clicking with gold lump drops random item from mobs.npc_drops
    if item:get_name() == "default:gold_lump" then
      if not minetest.settings:get_bool("creative_mode") then
        item:take_item()
        clicker:set_wielded_item(item)
      end
      --print(dump(self.object:get_luaentity()).. " at " ..dump(self.object:getpos()).. " takes: " ..dump(item:get_name()))             	
      local pos = self.object:getpos()          
      pos.y = pos.y + 0.5
      minetest.add_item(pos, {
        name = goblins.defaults.drops[math.random(1, #goblins.defaults.drops)]
      })
      return
    end
  end  
end

mobs:register_mob("goblins:goblin_snuffer", {
  description = "Goblin Snuffer",
  lore = "the snuffer likes to put out pesky torches and steal them, collecting the fuel for trap makers",
  type = "npc",
  passive = false,
  damage = 1,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  runaway = true,
  runaway_from = "player",
  hp_min = 5,
  hp_max = 10,
  armor = goblins.defaults.armor,
  textures = {
    "goblins_goblin_digger.png",
  },

  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  stay_near = "group:torch",
  owner = "",
  order = "follow",
  animation = goblins.defaults.animation, 
  follow = {"default:diamond", "default:apple", "farming:bread"},
  drops = {
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}
  },

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    --print(dump(clicker).. "gives" ..dump(self))
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      5, --search_rate
      10, --search_rate_above
      10, --search_rate_below
      3, --search_offset
      2, --search_offset_above
      2, --search_offset_below
      10, --replace_rate
      {"group:torch"}, --replace_what
      "air", --replace_with
      1000, --replace_rate_secondary
      "goblins:mossycobble_trap" --replace_with_secondary
    )
  end,
})

mobs:register_egg("goblins:goblin_snuffer", "Goblin Egg (snuffer)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_digger", {
  description = "Digger Goblin",
  lore = "The digger burrows though stone to carve out the bowels of a goblin warren",
  type = "npc",
  attack_npcs = false,  
  passive = false,
  damage = 1,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  runaway = true,
  hp_min = 5,
  hp_max = 10,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = {
    random = "goblins_goblin_breathing",
    warcry = "goblins_goblin_attack",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "goblins_goblin_pick",
    gain = .5,
    distance = 15
    },
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    "goblins_goblin_digger.png",
  },

  drops = {
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "goblins:pick_mossycobble",
      chance = 3, min = 1, max = 1},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3},
     {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}    
  },
  follow = {"default:diamond", "default:apple", "default:bread"},
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

--dig a rough patch rarely, otherwise use a more sopisticated tunnel/room mode...
 do_custom = function(self)
    if math.random() < 0.5 then --lower values for more straight tunnels and room-like features that will ascend toward the surface.
    goblins.search_replace(
      self,
      4, --search_rate
      20, --search_rate_above
      20, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1.5, --search_offset_below
      4, --replace_rate
      {"group:soil",
        "group:sand",
        "default:gravel",
        "default:stone",
        "default:desert_stone",
        "group:torch"}, --replace_what
      "air", --replace_with
      nil, --replace_rate_secondary
      nil, --replace_with_secondary
      nil, --decorate
      true --debug_me if debugging also enabled in behaviors.lua
    ) 
    else
      goblins.tunneling(self, "digger") 
    end
   end,
})


mobs:register_egg("goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_cobble", {
  description = "Cobble Goblin",
  lore = "Cobbler crumbles walls infusing them with moss to collect moisture for a fetid, mushroom friendly habitat",
  type = "npc",
  passive = false,
  damage = 1,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  runaway = true,
  hp_min = 5,
  hp_max = 10,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = {
    random = {"goblins_goblin_breathing",gain = 0.5},
    warcry = "goblins_goblin_warcry",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "default_place_node",gain = 0.8,
    distance = 15
  },
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    "goblins_goblin_cobble1.png",
    "goblins_goblin_cobble2.png",	
  },
  drops = {
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "goblins:pick_mossycobble",
      chance = 3, min = 1, max = 1},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}    

  },

  follow = {"default:diamond", "default:apple", "farming:bread"},


  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      10, --search_rate
      1, --search_rate_above
      1, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"group:stone",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      50, --replace_rate_secondary
      "goblins:mossycobble_trap" --replace_with_secondary
    )
  end,
})
mobs:register_egg("goblins:goblin_cobble", "Goblin Egg (cobble)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_fungiler", {
  description = "Goblin Fungiler",
  lore = "Fungilers keep the warren full of tasty mushrooms which are also fuel for pyromancy",
  type = "npc",
  passive = false,
  damage = 1,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  runaway = true,
  hp_min = 5,
  hp_max = 10,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = {
    random = "goblins_goblin_breathing",
    warcry = "goblins_goblin_warcry",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "default_place_node", gain = 0.8,
    distance = 15
  },
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_cobble1.png"},
    {"goblins_goblin_cobble2.png"},	
  },
  drops = {
    {name = "goblins:mushroom_goblin",
      chance = 1, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 10, min = 1, max = 3},
    {name = "default:flint",
      chance = 10, min = 1, max = 2},
    {name = "default:torch",
      chance = 20, min = 1, max = 5},
    {name = "goblins:pick_mossycobble",
      chance = 10, min = 1, max = 1},    

  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  owner = "",
  order = "follow",
  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,
  on_rightclick = function(self, clicker)
    give_goblin(self, clicker)
  end,
  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      100, --replace_rate
      "default:mossycobble", --replace_what
      "goblins:mushroom_goblin", --replace_with
      150, --replace_rate_secondary
      "goblins:mushroom_goblin2", --replace_with_secondary
      true
    )
  end,
})

mobs:register_egg("goblins:goblin_fungiler", "Goblin Egg (fungiler)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_coal", {
  description = "Coal Goblin",
  type = "npc",
  passive = false,
  damage = 1,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  hp_min = 5,
  hp_max = 10,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_coal1.png"},
    {"goblins_goblin_coal2.png"},
  },
  drops = {
    {name = "default:coal_lump",
      chance = 1, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},    
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},

  owner = "",
  order = "follow",    

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"default:mossycobble",
        "default:stone_with_coal",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      50, --replace_rate_secondary
      "goblins:stone_with_coal_trap" --replace_with_secondary
    )
  end,

})
mobs:register_egg("goblins:goblin_coal", "Goblin Egg (coal)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_iron", {
  description = "Iron Goblin",
  type = "npc",
  passive = false,
  damage = 2,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_player = true,    
  attack_npcs = false,
  group_attack = true,
  hp_min = 10,
  hp_max = 20,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_iron1.png"},
    {"goblins_goblin_iron2.png"},
  },
  drops = {
    {name = "default:iron_lump",
      chance = 1, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},    
    {name = "default:pick_steel",
      chance = 5, min = 1, max = 1},
  },

  follow = {"default:diamond", "default:apple", "default:bread"},
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"default:mossycobble",
        "default:stone_with_iron",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      50, --replace_rate_secondary
      "goblins:stone_with_iron_trap" --replace_with_secondary
    )
  end,
})
mobs:register_egg("goblins:goblin_iron", "Goblin Egg (iron)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_copper", {
  description = "Copper Goblin",
  type = "npc",
  passive = false,
  damage = 2,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  group_attack = true,
  hp_min = 10,
  hp_max = 20,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_copper1.png"},
    {"goblins_goblin_copper2.png"},
  },
  drops = {
    {name = "default:copper_lump",
      chance = 1, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},    
    {name = "default:pick_steel",
      chance = 5, min = 1, max = 1},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}
  },
  follow = {"default:diamond", "default:apple", "default:bread"},
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"default:mossycobble",
        "default:stone_with_copper",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      50, --replace_rate_secondary
      "goblins:stone_with_copper_trap" --replace_with_secondary
    )
  end,
})
mobs:register_egg("goblins:goblin_copper", "Goblin Egg (copper)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_gold", {
  description = "Gold Goblin",
  type = "npc",
  passive = false,
  damage = 3,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_npcs = false,
  hp_min = 10,
  hp_max = 30,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_gold1.png"},
    {"goblins_goblin_gold2.png"},
  },
  drops = {
    {name = "default:gold_lump",
      chance = 1, min = 1, max = 3},
    {name = "default:apple",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},    
    {name = "default:gold_ingot",
      chance = 5, min = 1, max = 1},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self, clicker)
    --print(dump({self,clicker}))        
    give_goblin(self, clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"default:mossycobble",
        "default:stone_with_gold",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      30, --replace_rate_secondary
      "goblins:stone_with_gold_trap" --replace_with_secondary
    )
  end,
})

mobs:register_egg("goblins:goblin_gold", "Goblin Egg (gold)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_diamond", {
  description = "Diamond Goblin",
  type = "npc",
  passive = false,
  damage = 3,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_players = true,
  attack_monsters = true,
  attack_npcs = false,
  hp_min = 20,
  hp_max = 30,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  textures = {
    {"goblins_goblin_diamond1.png"},
    {"goblins_goblin_diamond2.png"},
  },
  drops = {
    {name = "default:pick_diamond",
      chance = 1, min = 1, max = 1},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 10},
    {name = "default:diamond",
      chance = 5, min = 1, max = 1},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  view_range = 10,
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"default:mossycobble",
        "default:stone_with_diamond",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      30, --replace_rate_secondary
      "goblins:stone_with_diamond_trap" --replace_with_secondary
    )
  end,

})
mobs:register_egg("goblins:goblin_diamond", "Goblin Egg (diamond)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_king", {
  description = "Goblin King",
  type = "npc",
  passive = false,
  damage = 4,
  reach = goblins.defaults.reach,
  knock_back = goblins.defaults.knockback,
  attack_type = "dogfight",
  attack_monsters = true,
  attack_players = true,
  attack_npcs = false,
  hp_min = 20,
  hp_max = 40,
  armor = goblins.defaults.armor,
  visual = goblins.defaults.visual,
  mesh = goblins.defaults.mesh,
  collisionbox = goblins.defaults.collisionbox,
  drawtype = goblins.defaults.drawtype,	
  makes_footstep_sound = goblins.defaults.makes_footstep_sound,
  sounds = goblins.defaults.sounds,
  walk_velocity = goblins.defaults.walk_velocity,
  run_velocity = goblins.defaults.run_velocity,
  jump = goblins.defaults.jump,
  fear_height = goblins.defaults.fear_height,
  water_damage = goblins.defaults.water_damage,
  lava_damage = goblins.defaults.lava_damage,
  light_damage = goblins.defaults.light_damage,
  lifetimer = goblins.defaults.lifetimer,
  view_range = goblins.defaults.viewrange,
  animation = goblins.defaults.animation, 
  drawtype = "front",
  textures = {
    {"goblins_goblin_king.png"},
  },
  drops = {
    {name = "default:pick_mese",
      chance = 1, min = 1, max = 1},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},    
    {name = "default:mese_crystal",
      chance = 5, min = 1, max = 1},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 10, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
     chance = 10, min = 1, max = 3}
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  view_range = 10,
  owner = "",
  order = "follow",

  on_spawn = function(self)
    announce_goblin_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    give_goblin(self,clicker)
  end,

  do_custom = function(self)
    goblins.search_replace(
      self,
      100, --search_rate
      100, --search_rate_above
      100, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      10, --replace_rate
      {	"group:stone",
        "group:torch"}, --replace_what
      "default:mossycobble", --replace_with
      10, --replace_rate_secondary
      "goblins:mossycobble_trap" --replace_with_secondary
    )
  end,
})
mobs:register_egg("goblins:goblin_king", "Goblin King Egg", "default_mossycobble.png", 1)

-- spawn at or below 10 near ore and dungeons and goblin lairs (areas of mossy cobble), except diggers that will dig out caves from stone and cobble goblins who create goblin lairs near stone.
--function mobs:spawn_specific:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height)

--[[ function mobs:spawn_specific:spawn_specific(
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
mobs:spawn_specific("goblins:goblin_snuffer", {"default:mossycobble"},  "air",                                  0, 50, 30, 1000, 2, -30000 , -15)
mobs:spawn_specific("goblins:goblin_digger", {"group:stone"},  "air",                                           0, 50, 30, 1000, 2, -30000 , -15)
mobs:spawn_specific("goblins:goblin_cobble", {"group:stone"}, "air",                                            0, 50, 30, 1000, 2, -30000 , -10)
mobs:spawn_specific("goblins:goblin_fungiler", {"default:mossycobble"}, "air",                                  0, 50, 30, 1500, 1, -30000 , -10)
mobs:spawn_specific("goblins:goblin_coal", {"default:stone_with_coal", "default:mossycobble"}, "air",           0, 50, 20, 500, 3, -30000, -20)
mobs:spawn_specific("goblins:goblin_iron", {"default:stone_with_iron", "default:mossycobble"}, "air",           0, 50, 20, 500, 3, -30000, -30)
mobs:spawn_specific("goblins:goblin_copper", {"default:stone_with_copper", "default:mossycobble"}, "air",       0, 50, 30, 500, 2, -30000, -50)
mobs:spawn_specific("goblins:goblin_gold", {"default:stone_with_gold", "default:mossycobble"}, "air",           0, 50, 30, 500, 2, -30000, -100)
mobs:spawn_specific("goblins:goblin_diamond", {"default:stone_with_diamond", "default:mossycobble" }, "air",    0, 50, 60, 1000, 2, -30000, -200)
mobs:spawn_specific("goblins:goblin_king", {"default:mossycobble","default:chest"},"air",                       0, 50, 90, 2000, 1, -30000, -300)
--goblin kings may come near the surface of there is a chest near by
mobs:spawn_specific("goblins:goblin_king", {"default:chest"},"air",                                             0, 50, 90, 2000, 1, -30000, -25) 
minetest.log("action", "[MOD] goblins 20200423 is lodids!")
