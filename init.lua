local path = minetest.get_modpath("goblins")
dofile(path .. "/traps.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/soundsets.lua")
dofile(path .. "/behaviors.lua")
dofile(path .. "/animals.lua")
goblins.version="20200426"
minetest.log("action", "[MOD] goblins " ..goblins.version.. " is lowdings....")
print("Please report issues at https://github.com/FreeLikeGNU/goblins/issues ")

if mobs.version then
  if tonumber(mobs.version) >= tonumber(20200412) then
    print("Mobs Redo 20200412 or greater found!")
  else 
    print("You may need a more recent version of Mobs Redo!")
    print("https://notabug.org/TenPlus1/mobs_redo")
  end
 else
  print("This mod requires Mobs Redo 20200412 or greater!")
  print("https://notabug.org/TenPlus1/mobs_redo")
end

local goblin_defaults = {  --your average goblin, 
  type = "npc",
  passive = false,
  attack_type = "dogfight",
  attack_monsters = false,
  attack_npcs = false,
  attack_players = true,
  group_attack = true,
  runaway = true,
  damage = 1,
  reach = 2,
  knock_back = true,
  hp_min = 5,
  hp_max = 10,
  armor = 100,
  visual = "mesh",
  mesh = "goblins_goblin.b3d",
  textures = {
    {"default_tool_stoneaxe.png","goblins_goblin_cobble1.png"},
    {"default_tool_stoneshovel.png","goblins_goblin_cobble2.png"},

  },
  collisionbox = {-0.25, -.01, -0.25, 0.25, .9, 0.25},
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
  jump_height = 5,
  step_height = 1.5,
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
    {name = "default:pick_mossycobble",
      chance = 10, min = 1, max = 1},
    {name = "default:mossycbble",
      chance = 7, min = 1, max = 1},
    {name = "default:axe_stone",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
}


mobs:register_mob("goblins:goblin_snuffer", {
  description = "Goblin Snuffer",
  lore = "the snuffer likes to put out pesky torches and steal them, collecting the fuel for trap makers",
  damage = 1,
  reach = goblin_defaults.reach,
  hp_min = 5,
  hp_max = 10,
  textures = {
    "default_stick.png", "goblins_goblin_digger.png",
  },
  sounds = goblin_defaults.sounds,
  stay_near = "group:torch",
  owner = "",
  order = "follow",
  follow = {"default:diamond", "default:apple", "farming:bread"},
  drops = goblin_defaults.drops,
  type = goblin_defaults.type,
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 
  on_spawn = function(self)
      goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    --print(dump(clicker).. "gives" ..dump(self))
    goblins.give_gift(self,clicker)
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
  damage = 1,
  hp_min = 5,
  hp_max = 10,
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
  textures = {
    "default_tool_stonepick.png","goblins_goblin_digger.png"
  },
  drops = goblin_defaults.drops,
  follow = {"default:diamond", "default:apple", "default:bread"},
  owner = "",
  order = "follow",
  type = goblin_defaults.type,
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,	
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
  end,

  --dig a rough patch rarely, otherwise use a more sopisticated tunnel/room mode...
  do_custom = function(self)
    if math.random() < 0.05 then --higher values for more straight tunnels and room-like features 
      goblins.tunneling(self, "digger")
    elseif math.random() < 0.5 then
      goblins.search_replace(
        self,
        15, --search_rate how often do we search?
        10, --search_rate_above
        10, --search_rate_below
        .6,--search_offset
        1.2, --search_offset_above
        1, --search_offset_below
        2, --replace_rate
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
    end
  end,
})


mobs:register_egg("goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_cobble", {
  description = "Cobble Goblin",
  lore = "Cobbler crumbles walls infusing them with moss to collect moisture for a fetid, mushroom friendly habitat",
  damage = 1,
  hp_min = 5,
  hp_max = 10,
  sounds = {
    random = {"goblins_goblin_breathing",gain = 0.5},
    warcry = "goblins_goblin_warcry",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "default_place_node",gain = 0.8,
    distance = 15
  },
  textures = {
    {"default_tool_stoneaxe.png","goblins_goblin_cobble1.png"},
    {"default_tool_stoneaxe.png","goblins_goblin_cobble2.png"},	
  },
  drops = goblin_defaults.drops,
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = goblin_defaults.type,
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
  damage = 1,
  hp_min = 5,
  hp_max = 10,
  sounds = {
    random = "goblins_goblin_breathing",
    warcry = "goblins_goblin_warcry",
    attack = "goblins_goblin_attack",
    damage = "goblins_goblin_damage",
    death = "goblins_goblin_death",
    replace = "default_place_node", gain = 0.8,
    distance = 15
  },
  textures = {
    {"goblins_mushroom_brown.png","goblins_goblin_cobble1.png"},
    {"goblins_mushroom_brown.png","goblins_goblin_cobble2.png"},	
  },
  drops = {
    {name = "default:pick_mossycobble",
      chance = 10, min = 1, max = 1},
    {name = "default:mossycbble",
      chance = 7, min = 1, max = 1},
    {name = "default:axe_stone",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = goblin_defaults.type,
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)          
  end,
  on_rightclick = function(self, clicker)
    goblins.give_gift(self, clicker)
  end,
  do_custom = function(self)
    goblins.search_replace(
      self,
      50, --search_rate
      50, --search_rate_above
      50, --search_rate_below
      1, --search_offset
      2, --search_offset_above
      1, --search_offset_below
      20, --replace_rate
      "default:mossycobble", --replace_what
      "goblins:mushroom_goblin", --replace_with
      150, --replace_rate_secondary
      "goblins:mushroom_goblin2", --replace_with_secondary
      true,
      true
    )
  end,
})

mobs:register_egg("goblins:goblin_fungiler", "Goblin Egg (fungiler)", "default_mossycobble.png", 1)

mobs:register_mob("goblins:goblin_coal", {
  description = "Coal Goblin",
  damage = 1,
  hp_min = 5,
  hp_max = 10,
  textures = {
    {"default_tool_stonepick.png","goblins_goblin_coal1.png"},
    {"default_tool_stonepick.png","goblins_goblin_coal2.png"},
  },
  drops = {
    {name = "default:pick_mossycobble",
      chance = 10, min = 1, max = 1},
    {name = "default:mossycbble",
      chance = 7, min = 1, max = 1},
    {name = "default:axe_stone",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = goblin_defaults.type,
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation,

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
  damage = 2,
  hp_min = 10,
  hp_max = 20,
  textures = {
    {"default_tool_stonepick.png","goblins_goblin_iron1.png"},
    {"default_tool_stonesword.png","goblins_goblin_iron2.png"},
  },
  drops = {
    {name = "default:pick_steel",
      chance = 10, min = 1, max = 1},
    {name = "default:steel_ingot",
      chance = 7, min = 1, max = 1},
    {name = "default:axe_steel",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "default:bread"},
  type = "monster",
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
  damage = 2,
  hp_min = 10,
  hp_max = 20,
  textures = {
    {"default_tool_bronzepick.png","goblins_goblin_copper1.png"},
    {"default_tool_bronzesword.png","goblins_goblin_copper2.png"},
  },
  drops = {
    {name = "default:pick_bronze",
      chance = 10, min = 1, max = 1},
    {name = "default:bronze_ingot",
      chance = 7, min = 1, max = 1},
    {name = "default:axe_bronze",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "default:bread"},
  type = "monster",
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)          
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
  damage = 3,
  hp_min = 10,
  hp_max = 30,
  textures = {
    {"default_tool_steelpick.png","goblins_goblin_gold1.png"},
    {"default_tool_steelsword.png","goblins_goblin_gold2.png"},
  },
  drops = {
    {name = "default:pick_gold",
      chance = 10, min = 1, max = 1},
    {name = "default:gold_lump",
      chance = 7, min = 1, max = 1},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = "monster",
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self, clicker)
    --print(dump({self,clicker}))        
    goblins.give_gift(self, clicker)
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
  damage = 3,
  hp_min = 20,
  hp_max = 30,
  textures = {
    {"default_tool_diamondpick.png","goblins_goblin_diamond1.png"},
    {"default_tool_diamondsword.png","goblins_goblin_diamond2.png"},
  },
  drops = {
    {name = "default:pick_diamond",
      chance = 10, min = 1, max = 1},
    {name = "default:diamond",
      chance = 7, min = 1, max = 1},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = "monster",
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 

  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
  damage = 4,
  hp_min = 20,
  hp_max = 40,
  textures = {
    {"default_tool_mesepick.png","goblins_goblin_king.png"},
  },
  drops = {
    {name = "default:pick_mese",
      chance = 10, min = 1, max = 1},
    {name = "default:mese_crystal",
      chance = 7, min = 1, max = 1},
    {name = "default:pick_bronze",
      chance = 5, min = 1, max = 1},
    {name = "default:torch",
      chance = 4, min = 1, max = 10},
    {name = "default:flint",
      chance = 3, min = 1, max = 2},
    {name = "default:mossycobble",
      chance = 2, min = 1, max = 3},
    {name = "goblins:goblins_goblin_bone_meaty",
      chance = 3, min = 1, max = 1}, 
    {name = "goblins:goblins_goblin_bone",
      chance = 2, min = 1, max = 3},
    {name = "goblins:mushroom_goblin",
      chance = 2, min = 1, max = 5},
  },
  follow = {"default:diamond", "default:apple", "farming:bread"},
  type = "monster",
  passive = goblin_defaults.passive,
  attack_type = goblin_defaults.attack_type,
  reach = goblin_defaults.reach,
  knock_back = goblin_defaults.knockback,
  attack_monsters = goblin_defaults.attack_monsters,
  attack_npcs = goblin_defaults.attack_npcs,
  attack_players = goblin_defaults.attack_players,
  group_attack = goblin_defaults.group_attack,
  runaway = goblin_defaults.runaway,
  armor = goblin_defaults.armor,
  visual = goblin_defaults.visual,
  mesh = goblin_defaults.mesh,
  collisionbox = goblin_defaults.collisionbox,
  drawtype = goblin_defaults.drawtype,  
  makes_footstep_sound = goblin_defaults.makes_footstep_sound,
  walk_velocity = goblin_defaults.walk_velocity,
  step_height = goblin_defaults.step_height,
  run_velocity = goblin_defaults.run_velocity,
  jump = goblin_defaults.jump,
  jump_height = goblin_defaults.jump_height,
  fear_height = goblin_defaults.fear_height,
  water_damage = goblin_defaults.water_damage,
  lava_damage = goblin_defaults.lava_damage,
  light_damage = goblin_defaults.light_damage,
  lifetimer = goblin_defaults.lifetimer,
  view_range = goblin_defaults.viewrange,
  animation = goblin_defaults.animation, 
  
  on_spawn = function(self)
    goblins.announce_spawn(self)
  end,

  on_rightclick = function(self,clicker) 
    goblins.give_gift(self,clicker)
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
minetest.log("action", "[MOD] goblins " ..goblins.version.. " is lodids!")

--[[
mobs:register_mob("goblins:goblin_npc_test", {
  type = "npc",
  passive = false,
  attack_type = "dogfight",
  damage = 1,
  attack_monsters = false,
  attack_npcs = false,
  attack_players = true,
  group_attack = true,
  runaway = true,
    visual = "mesh",
  mesh = "goblins_goblin.b3d",
  collisionbox = {-0.25, -.01, -0.25, 0.25, .9, 0.25},
  drawtype = "front"
})
  
mobs:register_mob("goblins:goblin_monster_test", {
  type = "monster",
  attack_type = "dogfight",
  damage = 1,
  passive = false,
  group_attack = true,
  attack_monsters = false,
  attack_npcs = false,
  attack_players = true,
  collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.85, 0.45},
  visual = "mesh",
  mesh = "goblins_goblin_dog.b3d",
  makes_footstep_sound = true,
})

mobs:register_egg("goblins:goblin_npc_test", "Goblin Egg (test NPC)", "default_mossycobble.png", 1)
mobs:register_egg("goblins:goblin_monster_test", "Goblin Egg (test MONSTER)", "default_mossycobble.png", 1)
--]]