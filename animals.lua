local announce_spawning_goblins = true 

local announce_goblin_spawn = function(self)
  if announce_spawning_goblins == true then
    local pos = vector.round(self.object:getpos())
    if not pos then return end
    print( self.name:split(":")[2].. ":" .. minetest.pos_to_string(pos))
  end
end

mobs:register_mob("goblins:goblins_goblin_dog", {
  description ="Gobdog",
  lore = "Gobdogs are not canids but goblins that have mutated somehow, fortunately they do not share the hunger and size of the mythical werewolf.",
  stepheight = 1.2,
  type = "animal",
  passive =false,
  attack_type = "dogfight",
  group_attack = true,
  owner_loyal = true,
  attack_npcs = false,
  attack_players = true,
  specific_attack = "player",
  reach = 2,
  damage = 1,
  hp_min = 2,
  hp_max = 5,
  armor = 100,
  collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.95, 0.4},
  visual = "mesh",
  mesh = "goblins_goblin_dog.b3d",
  textures = {
    {"goblins_goblin_dog.png"},
  },
  makes_footstep_sound = true,
  sounds = {
    random = "goblins_goblin_dog_ambient_cave",
    warcry = "goblins_goblin_dog_warcry_cave",
    attack = "goblins_goblin_dog_attack_cave",
    damage = "goblins_goblin_dog_damage_cave",
    death = "goblins_goblin_dog_death_cave",
  },
  walk_velocity = 2,
  run_velocity = 4,
  jump = true,
  jump_height = 4,
  pushable = true,
  knock_back = true,
  follow = {"goblins:goblins_goblin_bone","goblins:goblins_goblin_bone_meaty","group:meat"},
  view_range = 15,
  drops = {
    {name = "goblins:goblins_goblin_bone", chance = 1, min = 1, max = 3},
  },
  water_damage = 0,
  lava_damage = 5,
  light_damage = 0,
  fear_height = 2,
  stay_near = {"group:water", 20,
               "group:sand", 20,
               "group:soil", 20,
               "default:mossycobble", 10,
               "group:meat" ,5},
  floats = 1,
  glow = 3,
  animation = {
    speed_normal = 60,
    stand_start = 0,
    stand_end = 60,
    walk_start = 70,
    walk_end = 90,
    run_start = 130,
    run_end = 140,
    run_speed =30,
    punch_start = 130,
    punch_end = 140,
    punch_speed = 30,
    die_start = 140,
    die_stop = 145,
    die_speed = 30,
    die_loop = false,
  },
  
  on_spawn = function(self)
  minetest.sound_play("goblins_goblin_dog_warcry_cave", {
      object = self.object,
      gain = .5,
      max_hear_distance =30
    })
    announce_goblin_spawn(self)
  end,
  on_rightclick = function(self, clicker)

    if mobs:feed_tame(self, clicker, 8, true, true) then return end
    if mobs:protect(self, clicker) then return end
    if mobs:capture_mob(self, clicker, 0, 5, 50, false, nil) then return end
  end,
})

mobs:register_egg("goblins:goblins_goblin_dog", "Goblin Gobdog Egg", "default_mossycobble.png", 1)

mobs:spawn({
  name = "goblins:goblins_goblin_dog",
  nodes = {"default:mossycobble", "group:sand"},
  min_light = 0,
  max_light = 14,
  chance = 500,
  active_object_count = 4,
  min_height = -31000,
  max_height = -20,
})

minetest.register_node("goblins:goblins_goblin_bone", {
  description = "bone",
  tiles = {"goblins_goblin_bone.png"},
  inventory_image  = "goblins_goblin_bone.png",
  visual_scale = 0.7,
  drawtype = "plantlike",
  wield_image = "goblins_goblin_bone.png",
  paramtype = "light",
  walkable = false,
  is_ground_content = true,
  sunlight_propagates = true,
  selection_box = {
    type = "fixed",
    fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
  },
  groups = {meat = 1, snappy = 2, fleshy =1, dig_immediate = 3},
  after_place_node = function(pos, placer, itemstack)
    if placer:is_player() then
      minetest.set_node(pos, {name = "goblins:goblins_goblin_bone", param2 = 1})
    end
  end,
})

minetest.register_node("goblins:goblins_goblin_bone_meaty", {
  description = "meaty bone",
  tiles = {"goblins_goblin_bone_meaty.png"},
  inventory_image  = "goblins_goblin_bone_meaty.png",
  visual_scale = 0.7,
  drawtype = "plantlike",
  wield_image = "goblins_goblin_bone_meaty.png",
  paramtype = "light",
  walkable = false,
  is_ground_content = true,
  sunlight_propagates = true,
  selection_box = {
    type = "fixed",
    fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
  },
  groups = {meat = 3, snappy = 2, fleshy =3, dig_immediate = 3},
  after_place_node = function(pos, placer, itemstack)
    if placer:is_player() then
      minetest.set_node(pos, {name = "goblins:goblins_goblin_bone_meaty", param2 = 1})
    end
  end,
})