-- goblin namegen sets from https://github.com/LukeMS/lua-namegen
-- libtcod https://github.com/libtcod/libtcod name set format have been adapted for my Goblins gen_name function
local S = minetest.get_translator("goblins")
local gob_name_parts = goblins.gob_name_parts
-- this table defines the goblins with how they differ from the goblin template.
local gob_types = {
  digger = {
    description = S("Cavedigger Goblin"),
    lore = S("The digger burrows though stone to carve out the bowels of a goblin warren"),
    damage = 1,
    hp_min = 5,
    hp_max = 10,
    runaway_from = "player",
    sounds = {
      random = "goblins_goblin_breathing",
      war_cry = "goblins_goblin_attack",
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

    -- if either digging style is set too close to "1", then the digging will go vertical!
    -- best to set either of these less than 0.5 to give the gobs time to roam...
    do_custom = function(self)
      if math.random() < 0.01 then -- higher values for more straight tunnels and room-like features
        goblins.tunneling(self, "digger")
      elseif math.random() < 0.5 then -- higher values more rough, tight and twisty digging
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
    spawning = {
      nodes = {"group:stone"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 1000,
      active_object_count = 2,
      min_height = -31000,
      max_height = -15,
      day_toggle = nil,
      on_spawn = nil,
    }
  },
  cobble = {
    description = S("Cobblemoss Goblin"),
    lore = S("Cobbler crumbles walls infusing them with moss to collect moisture for a fetid, mushroom friendly habitat"),
    damage = 1,
    hp_min = 5,
    hp_max = 10,
    sounds = {
      random = {"goblins_goblin_breathing",gain = 0.5},
      war_cry = "goblins_goblin_war_cry",
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
    runaway_from = "player",

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
        { "group:stone",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        50, --replace_rate_secondary
        "goblins:mossycobble_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"group:stone"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 1000,
      active_object_count = 2,
      min_height = -31000,
      max_height = -15,
      day_toggle = nil,
      on_spawn = nil,
    }
  },
  snuffer = {
    description = S("Snuffer Goblin"),
    lore = S("The Snuffer likes to put out pesky torches and steal them, collecting the fuel for trap makers"),
    damage = 1,
    hp_min = 5,
    hp_max = 10,
    textures = {
      "default_stick.png", "goblins_goblin_digger.png",
    },
    stay_near = "group:torch",
    runaway_from = "player",

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

    spawning = {
      nodes = {"default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 1000,
      active_object_count = 2,
      min_height = -31000,
      max_height = -15,
      day_toggle = nil,
      on_spawn = nil,
    }
  },
  fungiler = {
    description = S("Goblin Fungiler"),
    lore = S("Fungilers keep the warren full of tasty mushrooms which are also fuel for pyromancy"),
    damage = 1,
    hp_min = 5,
    hp_max = 10,
    sounds = {
      random = "goblins_goblin_breathing",
      war_cry = "goblins_goblin_war_cry",
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
      {name = "default:pick_steel",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_steel",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_steel",
        chance = 1000, min = 1, max = 1},
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
    runaway_from = "player",

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
        true, --decorate
        true  --debug if replace
      )
    end,

    spawning = {
      nodes = {"default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 1500,
      active_object_count = 1,
      min_height = -31000,
      max_height = -15,
      day_toggle = nil,
      on_spawn = nil,
    }
  },
  coal = {
    description = S("Coalbreath Goblin"),
    damage = 1,
    hp_min = 5,
    hp_max = 10,
    textures = {
      {"default_tool_stonepick.png","goblins_goblin_coal1.png"},
      {"default_tool_stonepick.png","goblins_goblin_coal2.png"},
    },
    drops = {
      {name = "default:pick_steel",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_steel",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_steel",
        chance = 1000, min = 1, max = 1},
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
        { "default:mossycobble",
          "default:stone_with_coal",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        50, --replace_rate_secondary
        "goblins:stone_with_coal_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"default:stone_with_coal", "default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 20,
      chance = 500,
      active_object_count = 3,
      min_height = -31000,
      max_height = -25,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
  copper = {
    description = S("Coppertooth Goblin"),
    damage = 2,
    hp_min = 10,
    hp_max = 20,
    textures = {
      {"default_tool_bronzepick.png","goblins_goblin_copper1.png"},
      {"default_tool_bronzesword.png","goblins_goblin_copper2.png"},
    },
    drops = {
      {name = "default:pick_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_diamond",
        chance = 1000, min = 1, max = 1},
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
        { "default:mossycobble",
          "default:stone_with_copper",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        50, --replace_rate_secondary
        "goblins:stone_with_copper_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"default:stone_with_copper", "default:mossycobble", "default:blueberries"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 500,
      active_object_count = 2,
      min_height = -31000,
      max_height = -35,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
  iron ={
    description = S("Ironpick Goblin"),
    type = "monster",
    damage = 2,
    hp_min = 10,
    hp_max = 20,
    textures = {
      {"default_tool_stonepick.png","goblins_goblin_iron1.png"},
      {"default_tool_stonesword.png","goblins_goblin_iron2.png"},
    },
    drops = {
      {name = "default:pick_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_diamond",
        chance = 1000, min = 1, max = 1},
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
        { "default:mossycobble",
          "default:stone_with_iron",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        50, --replace_rate_secondary
        "goblins:stone_with_iron_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"default:stone_with_iron", "default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 20,
      chance = 500,
      active_object_count = 3,
      min_height = -31000,
      max_height = -35,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
  gold = {
    description = S("Goldshiv Goblin"),
    type = "monster",
    damage = 3,
    hp_min = 10,
    hp_max = 30,
    textures = {
      {"default_tool_steelpick.png","goblins_goblin_gold1.png"},
      {"default_tool_steelsword.png","goblins_goblin_gold2.png"},
    },
    drops = {
      {name = "default:pick_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_diamond",
        chance = 1000, min = 1, max = 1},
      {name = "default:pick_gold",
        chance = 100, min = 1, max = 1},
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
        { "default:mossycobble",
          "default:stone_with_gold",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        30, --replace_rate_secondary
        "goblins:stone_with_gold_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"default:stone_with_gold", "default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 30,
      chance = 500,
      active_object_count = 2,
      min_height = -31000,
      max_height = -100,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
  diamond = {
    description = S("Diamondagger Goblin"),
    type = "monster",
    damage = 3,
    hp_min = 20,
    hp_max = 30,
    textures = {
      {"default_tool_diamondpick.png","goblins_goblin_diamond1.png"},
      {"default_tool_diamondsword.png","goblins_goblin_diamond2.png"},
    },
    drops = {
      {name = "default:pick_mese",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_mese",
        chance = 1000, min = 1, max = 1},
      {name = "default:axe_mese",
        chance = 1000, min = 1, max = 1},
      {name = "default:pick_diamond",
        chance = 100, min = 1, max = 1},
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
    follow = {"default:diamond", "default:apple", "default:torch", "default:blueberries"},

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
        { "default:mossycobble",
          "default:stone_with_diamond",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        30, --replace_rate_secondary
        "goblins:stone_with_diamond_trap" --replace_with_secondary
      )
    end,
    spawning = {
      nodes = {"default:stone_with_diamond", "default:mossycobble"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 60,
      chance = 1000,
      active_object_count = 2,
      min_height = -31000,
      max_height = -200,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
  hoarder = {
    description = S("Goblin Hoarder"),
    type = "monster",
    damage = 4,
    hp_min = 20,
    hp_max = 40,
    textures = {
      {"default_tool_mesepick.png","goblins_goblin_hoarder.png"},
    },
    drops = {
      {name = "default:meselamp",
        chance = 1000, min = 1, max = 1},
      {name = "default:pick_mese",
        chance = 1000, min = 1, max = 1},
      {name = "default:shovel_mese",
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
        { "group:stone",
          "group:torch"}, --replace_what
        "default:mossycobble", --replace_with
        10, --replace_rate_secondary
        "goblins:mossycobble_trap" --replace_with_secondary
      )
    end,

    spawning = {
      nodes = {"default:mossycobble","default:chest"},
      neighbors = "air",
      min_light = 0,
      max_light = 10,
      interval = 90,
      chance = 2000,
      active_object_count = 1,
      min_height = -31000,
      max_height = -20,
      day_toggle = nil,
      on_spawn = nil,
    },
  },
}

--gob_types.king = gob_types.hoarder  -- for compatability
mobs:alias_mob("goblins:goblin_king", "goblins:goblin_hoarder")

----------------------------------
--DEFAULT GOBLIN TEMPLATE
----------------------------------

local goblin_template = {  --your average goblin,
  description = "Basic Goblin",
  lore = "This goblin has a story yet to be...",
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
  blood_texture = "goblins_blood.png",
  collisionbox = {-0.25, -.01, -0.25, 0.25, .9, 0.25},
  drawtype = "front",
  makes_footstep_sound = true,
  sounds = {
    random = "goblins_goblin_breathing",
    war_cry = "goblins_goblin_war_cry",
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
    {name = "default:pick_steel",
      chance = 1000, min = 1, max = 1},
    {name = "default:shovel_steel",
      chance = 1000, min = 1, max = 1},
    {name = "default:axe_steel",
      chance = 1000, min = 1, max = 1},
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
  follow = {"default:diamond", "default:apple", "default:torch", "default:blueberries"},
  on_spawn = function(self)
    if not self.secret_name then
      self.secret_name = goblins.generate_name(gob_name_parts)
    end
    --print (dump(self.secret_name))
    --print (dump(self.special_gifts).. " are precious to "..dump(self.secret_name).. "!")
    local pos = vector.round(self.object:getpos())
    if not pos then print(dump(self).."\n **position error!** \n") return end --something went wrong!
    if not self.secret_territory then
      local opt_data = {}
      opt_data[self.secret_name] = os.time() --add this goblin as a key member of territory
      local territory = {goblins.territory(pos,opt_data)}
      self.secret_territory = {name = territory[1], vol = territory[2]}
      --print(dump(self.secret_territory.name).." secret_territory assigned")
    else
    --print(dump(self.secret_territory.name).." secret_territory already assigned")
    end
    goblins.announce_spawn(self)
  end,

  --By default the Goblins are willing to trade,
  --this can be overridden in the table for any goblin.
  on_rightclick = function(self,clicker)
    local pname = clicker:get_player_name()
    local relations = goblins.relations(self, pname)

    if not relations.trade then
      goblins.relations(self, pname, {trade = 0})
    end
    goblins.special_gifts(self)
    --print(self.secret_name.." relations on click:\n"..dump(self.relations).."\n")

    if self.relations[pname].trade >= 30 and not self.secret_territory_told[pname] then
      goblins.secret_territory(self, pname, "tell")
      goblins.special_gifts(self,pname)
      --print("  these gifts lined up "..dump(self.special_gifts))
    end

    if self.relations[pname].trade >= 15 and not self.secret_name_told[pname] then
      goblins.secret_name(self, pname, "tell")
      goblins.special_gifts(self,pname)
      --print("  these gifts lined up "..dump(self.special_gifts))
    end
    -- print(pname.." is about to make an offering")
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
      "goblins:mossycobble_trap", --replace_with_secondary
      nil, -- decorate
      nil --debug
    )
  end,
  spawning = {
    nodes = {"default:mossycobble"},
    min_light = 0,
    max_light = 10,
    chance = 500,
    active_object_count = 4,
    min_height = -31000,
    max_height = -20,
    day_toggle = nil,
    a = nil
  }

}
-------------
--ASSEMBLE THE GOBLIN HORDES!!!!
--------------
goblins.generate(gob_types,goblin_template)

local function ggn(gob_name_parts)
  return goblins.generate_name(gob_name_parts)
end

print("This diversion is dedicated to the memory of " ..ggn(gob_name_parts)..
  ", " ..ggn(gob_name_parts).. " and " ..ggn(gob_name_parts)..
  ". May their hordes be mine!")
print("   --"..ggn(gob_name_parts).." of the "..ggn(gob_name_parts).." clan")

