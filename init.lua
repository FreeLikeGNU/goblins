local path = minetest.get_modpath("goblins")
goblins_db = minetest.get_mod_storage()
goblins_db:set_string("goblins mod start time", os.date() )
--set namespace for goblins functions
goblins = {}

goblins.version = "20200606"

-- Strips any kind of escape codes (translation, colors) from a string
-- https://github.com/minetest/minetest/blob/53dd7819277c53954d1298dfffa5287c306db8d0/src/util/string.cpp#L777
function goblins.strip_escapes(input)
  local s = function(idx) return input:sub(idx, idx) end
  local out = ""
  local i = 1
  while i <= #input do
    if s(i) == "\027" then -- escape sequence
      i = i + 1
      if s(i) == "(" then -- enclosed
        i = i + 1
        while i <= #input and s(i) ~= ")" do
          if s(i) == "\\" then
            i = i + 2
          else
            i = i + 1
          end
        end
      end
    else
      out = out .. s(i)
    end
    i = i + 1
  end
  --print(("%q -> %q"):format(input, out))
  return out
end
local function strip_escapes(input)
  goblins.strip_escapes(input)
end

local function print_s(input)
  print(goblins.strip_escapes(input))
end

local S = minetest.get_translator("goblins")

local goblins_version = goblins.version
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
if not goblins_db_fields["relations"] then
  print("-------------\nWe must Initialize!\n-------------")
  goblins_db_write("relations", {test = {version = goblins_version, encode = minetest.encode_base64(os.date()), created = os.date() }})
end
--compatability with minimal game
if not default.LIGHT_MAX then
  default.LIGHT_MAX = 14
  LIGHT_MAX = default.LIGHT_MAX
end


dofile(path .. "/utilities.lua")
dofile(path .. "/traps.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/items.lua")
dofile(path .. "/soundsets.lua")
dofile(path .. "/behaviors.lua")
dofile(path .. "/animals.lua")
dofile(path .. "/goblins.lua")
dofile(path .. "/hunger.lua")

minetest.log("action", "[MOD] goblins " ..goblins.version.. " is lowdings....")
print_s(S("Please report issues at https://github.com/FreeLikeGNU/goblins/issues "))

if mobs.version then
  if tonumber(mobs.version) >= tonumber(20200516) then
    print_s(S("Mobs Redo 20200516 or greater found!"))
  else
    print_s(S("You should find a more recent version of Mobs Redo!"))
    print_s(S("https://notabug.org/TenPlus1/mobs_redo"))
  end
else
  print_s(S("This mod requires Mobs Redo version 2020430 or greater!"))
  print_s(S("https://notabug.org/TenPlus1/mobs_redo"))
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

