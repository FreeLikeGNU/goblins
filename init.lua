local path = minetest.get_modpath("goblins")
goblins_db = minetest.get_mod_storage()
goblins_db:set_string("goblins mod start time", os.date() )
local goblins_version="20200504"  
  -- create the table if it does not exist!
local goblins_db_fields = goblins_db:to_table()["fields"]
local function goblins_db_write(key, table)
  local data = minetest.serialize(table)
  goblins_db:set_string(key, data)
  return key, data
end
  if not goblins_db_fields["territories"] then
    print("-------------\nWe must Initialize!\n-------------")
    goblins_db_write("territories", {test = {version = goblins_version, encode = minetest.encode_base64(os.date()), created = os.date() }})
  end

dofile(path .. "/traps.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/soundsets.lua")
dofile(path .. "/behaviors.lua")
dofile(path .. "/animals.lua")
dofile(path .. "/goblins.lua")
goblins.version = goblins_version
minetest.log("action", "[MOD] goblins " ..goblins.version.. " is lowdings....")
print("Please report issues at https://github.com/FreeLikeGNU/goblins/issues ")

if mobs.version then
  if tonumber(mobs.version) >= tonumber(20200430) then
    print("Mobs Redo 20200430 or greater found!")
  else
    print("You may need a more recent version of Mobs Redo!")
    print("https://notabug.org/TenPlus1/mobs_redo")
  end
else
  print("This mod requires Mobs Redo 20200430 or greater!")
  print("https://notabug.org/TenPlus1/mobs_redo")
end


  
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

