
local announce_spawning = false

local debug_goblins_attack = true
local debug_goblins_find = false
local debug_goblins_relations = false
local debug_goblins_replace = false
local debug_goblins_replace2 = false
local debug_goblins_search = false
local debug_goblins_secret = false
local debug_goblins_territories = false
local debug_goblins_tunneling = false
local debug_goblins_trade = false
local debug_goblins_trade_relations = false

local goblin_node_protect_strict = true

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

local S = minetest.get_translator("goblins")

local gob_name_parts = goblins.gob_name_parts

local function strip_escapes(input)
  goblins.strip_escapes(input)
end

local function print_s(input)
  print(goblins.strip_escapes(input))
end

function goblins.mixitup(pos)
  pos.y = pos.y + math.random()
  pos.x = pos.x + math.random()
  pos.x = pos.x - math.random()
  pos.z = pos.z + math.random()
  pos.z = pos.z - math.random()
  return pos
end
--- This can build all the mobs in our mod.
-- @gob_types is a table with the key used to build the subtype with values that are unique to that subtype
-- @goblin_template is the table with all params that a mob type would have defined
function goblins.generate(gob_types,goblin_template)
  for k, v in pairs(gob_types) do
    -- we need to get a fresh template to modify for every type or we get some carryover values:-P
    local g_template = table.copy(goblin_template)
    -- g_type should be different every time so no need to freshen
    local g_type = v
    for x, y in pairs(g_type) do
      -- print_s("found template modifiers " ..dump(x).." = "..dump(y))
      g_template[x] = g_type[x]
    end
    print_s("Assembling the "..g_template.description..":")
    if g_template.lore then print_s("  "..g_template.lore) end
    --print_s("resulting template: " ..dump(g_template))
    mobs:register_mob("goblins:goblin_"..k, g_template)
    mobs:register_egg("goblins:goblin_"..k, S("@1  Egg",g_template.description),"default_mossycobble.png", 1)
    g_template.spawning.name = "goblins:goblin_"..k --spawn in the name of the key!
    mobs:spawn(g_template.spawning)
    g_template = {}
  end
end

--- Our mobs, territories, etc can have randomly generated names.
-- @name_parts is the name parts table: {list_a = "foo bar baz"}
-- @rules are the list table key names in order of how they will be chosen
-- "-" and "\'" are rules that can be used to add a hyphen or apostrophe respectively
function goblins.generate_name(name_parts, rules)
  -- print_s("generating name")
  local name_arrays = {}
  local r_parts = {}
  local generated_name = {}
  for k,v in pairs(name_parts) do
    --  name_arrays.k = mysplit(v)
    name_arrays.k = string.split(v," ")
    -- print_s(dump(name_arrays.k))
    r_parts[k] = k
    r_parts[k] = name_arrays.k[math.random(1,#name_arrays.k)]
  end
  --local r_parts.k = name_arrays.k[math.random(1,#name_arrays.k)] did not work
  --print_s(name_a)
  if r_parts.list_opt and math.random() <= 0.5 then r_parts.list_opt = "" end
  --print_s(r_parts.list_a..r_parts.list_b..r_parts.list_opt)

  if rules then
    --print_s(dump(rules))
    local gen_name = ""
    for i, v in ipairs(rules) do

      if v == "-" then
        gen_name = gen_name.."-"
      elseif v == "\'" then
        gen_name = gen_name.."\'"
      else
        gen_name = gen_name..r_parts[v]
      end
    end
    generated_name = gen_name
    --print_s(dump(generated_name))
    return generated_name
  else

    generated_name = r_parts.list_a..r_parts.list_b..r_parts.list_opt
    return generated_name
  end
end

--- This will store the name of a player that learns the mobs territory in the mobs table.
function goblins.secret_territory(self, player_name, tell)
  local pname = player_name
  --self.nametag = self.secret_name.." of "..self.secret_territory.name
  if not self.secret_territory_told then
    self.secret_territory_told = {initialized = os.time()}
  end
  if self.secret_territory_told[pname] then return self.secret_territory end
  if not self.secret_territory_told[pname] and tell then
    minetest.chat_send_player(pname,
      S("   You have learned the secret territory name of @1!!",dump(self.secret_territory.name)))
    self.secret_territory_told[pname] = os.time()
    ---self.nametag = self.secret_name.." of "..self.secret_territory.name

    ---player could also receive some kind of functional token for this territory
    return self.secret_territory
  end
  if debug_goblins_secret then
    for k,v in pairs(self.secret_territory_told)  do
      print_s(self.secret_name.." revealed secret territories to: "..k.." "..v)
    end
  end
end

--- This will store the name of a player that learns the mobs name in the mobs table.
function goblins.secret_name(self, player_name,tell)
  -- self.nametag = self.secret_name
  local pname = player_name
  if not self.secret_name_told then
    self.secret_name_told = {[self.secret_name] = os.time()}
  end
  if self.secret_name_told[pname] then return self.secret_name end
  if not self.secret_name_told[pname] and tell then
    --The goblin is willing to share something special!
    minetest.chat_send_player(pname,
      S("   You have learned the secret name of @1!!",self.secret_name))
    self.secret_name_told[pname] = os.time()
    --self.nametag = self.secret_name
    return self.secret_name
  end
  if debug_goblins_secret then
    for k,v in pairs(self.secret_name_told)  do
      print_s(self.secret_name.." revealed secret name to: "..k.." "..v)
    end
  end
end

------------
-- Announce Spawn ...summon it with care, for the floods shall come!
-----------
-- Purely for debugging or curiosity it can be enabled at the top of this page
function goblins.announce_spawn(self)
  if announce_spawning == true then
    local pos = vector.round(self.object:getpos())
    if not pos then return end
    if self.secret_name then
      print_s( self.name:split(":")[2].. ", "..self.secret_name.." spawned at: " .. minetest.pos_to_string(pos))
    else
      print_s( self.name:split(":")[2].. " spawned at: " .. minetest.pos_to_string(pos))
    end
    --goblins.territory(pos)
    if self.secret_territory then
      if self.secret_name then
        print_s(self.secret_name.. " dwells in "..self.secret_territory["name"].." at " ..self.secret_territory["vol"].."!\n" )
      else
        print_s("A nameless creature inhabits"..self.secret_territory["name"].." at " ..self.secret_territory["vol"].."!\n" )
      end
    else
      local territory = {goblins.territory(pos)}
      if self.secret_name then
        print_s(territory[1].." at "..territory[2].." festers with the lurking form of "..self.secret_name.."\n")
      else
        print_s(territory[1].." at "..territory[2].." becomses the domain of a nameless one\n")
      end
    end
  end
end

--Goblins will become aggro at range
--code reused from Mobs Redo by TenPlus1
--not quite ready yet...

local function match_item_list(item, list)
  for k,v in pairs(list) do
    local found = string.find(item, v)
    return found
  end
end

function goblins.attack(self, target, type)
  if self.state == "runaway"
    or self.state == "attack"
    or self:day_docile() then
    return
  end
  local pos = vector.round(self.object:getpos())
  local s = self.object:get_pos()
  local objs = minetest.get_objects_inside_radius(s, self.view_range)
  local aggro_wielded = self.aggro_wielded
  --print_s(S(dump(aggro_wielded)))
  -- remove entities we aren't interested in
  for n = 1, #objs do
    local ent = objs[n]:get_luaentity()
    -- are we a player?
    if objs[n]:is_player() then
      -- if player invisible or mob not setup to attack then remove from list
      local wielded = objs[n]:get_wielded_item():to_string()
      if debug_goblins_attack then print_s( S("player has @1 in hand",dump(objs[n]:get_wielded_item():to_string())))end
      if self.attack_players == false
      --or (self.owner and self.type ~= "monster")
      or mobs.invis[objs[n]:get_player_name()] then
      --or not specific_attack(self.specific_attack, "player") then
      if debug_goblins_attack then print_s(S("found players with @1",dump(objs[n]:get_wielded_item():to_string())))end
        objs[n] = nil
        --print("- pla", n)
        
      else
      if debug_goblins_attack then print_s(S("attackable players @1",dump(objs[n]:get_wielded_item():to_string())))end
        if aggro_wielded and match_item_list(wielded, aggro_wielded) then
          if debug_goblins_attack then print_s(S("*** aggro triggered by @1 at @2 !!  ***",wielded,dump(pos)))end
          self:set_animation("run")
          self:set_velocity(self.run_velocity)
          self.state = "attack"
          self.attack = (objs[n])
        end
      end
    end --end of player eval
    --what else do we care about?
  end
end

--- Drops a special personlized item
function goblins.special_gifts(self, pname, drop_chance, max_drops)

  if pname then
    if self.drops then
      if not drop_chance then drop_chance = 1000 end
      if not max_drops then max_drops = 1 end
      local rares = {}
      for k,v in pairs(self.drops) do
        --print_s(dump(v.name).." and "..dump(v.chance))
        if v.chance >= drop_chance then
          table.insert(rares,v.name)
        end
      end
      if #rares > 0 then
        --print_s("rares = "..dump(rares))
        local pos = self.object:getpos()
        pos.y = pos.y + 0.5
        goblins.mixitup(pos)
        if #rares > max_drops then
          rares = rares[math.random(max_drops, #rares)]
          if type(rares) ~= table then rares = {rares} end --
        end
        for k,v in pairs(rares) do
          minetest.sound_play("goblins_goblin_cackle", {
            pos = pos,
            gain = 1.0,
            max_hear_distance = self.sounds.distance or 10
          })
          local item_wear = math.random(5000,10000)
          local stack = ItemStack({name = v, wear = item_wear })
          local org_desc = minetest.registered_items[v].description
          local meta = stack:get_meta()
          local tool_adj = goblins.generate_name(goblins.words_desc, {"tool_adj"})
          -- special thanks here to rubenwardy for showing me how translation works!
          meta:set_string(
            "description", S("@1's @2 @3", self.secret_name, tool_adj, org_desc)
          )
          local obj = minetest.add_item(pos, stack)
          minetest.chat_send_player(
            pname,S("@1 drops @2",self.secret_name, meta:get_string("description"))
          )
        end
      end
    end
  end
end
--- You can give a gift, they *may* give something(s) in return.
function goblins.give_gift(self,clicker)
  --if mobs:feed_tame(self, clicker, 14, false, false) then
  local item = clicker:get_wielded_item()
  local name = clicker:get_player_name()
  local gift_accepted = nil
  local gift_declined = nil
  local pname = clicker:get_player_name()
  local name_told = goblins.secret_name(self, pname)
  local territory_told = goblins.secret_territory(self, pname)
  --establish trade if its not set
  if not self.relations[pname] then
    goblins.relations(self, pname, {trade = 0})
  end
  if debug_goblins_relations then print_s(dump(goblins.relations(self, pname))) end
  --grel = goblins.relations(self, pname)
  local srp_trade = self.relations[pname].trade
  local gr_trade = goblins.relations_trade(self,pname)
  local gift = item:get_name()
  local gift_description = item:get_definition().description
  if debug_goblins_trade then print_s("you offer: " ..dump(gift)) end
  for _,v in pairs(self.follow) do
    if v == gift then
      gift_accepted = true
      if debug_goblins_trade then print_s(self.name.. " accepts " .. dump(gift)) end
      --increase trade rating on gifting - first item in follow list is worth more
      srp_trade = srp_trade + 1
      if gift == self.follow[1] then
        srp_trade =  srp_trade + 4
        minetest.chat_send_player(pname,"Yessss! " .. gift_description.."!")
      end
      goblins.relations(self, pname,{trade = srp_trade})
      if debug_goblins_trade then print_s("trade rating is now = " ..dump(srp_trade)) end
      if debug_goblins_trade then print_s("storage written"..dump(gr_trade)) end
      if not minetest.settings:get_bool("creative_mode") then
        item:take_item()
        clicker:set_wielded_item(item)
      end
      --print_s(dump(self.object:get_luaentity()).. " at " ..dump(self.object:getpos()).. " takes: " ..dump(item:get_name()))
      if self.drops then
        if debug_goblins_trade then
          print_s("you may get some of "..dump(#self.drops).. " things such as: ")
          for _,v in pairs(self.drops) do
            print_s(dump(v.name).. " with a base drop chance of 1 in " ..dump(v.chance))
          end
        end
        -- we can make some mobs extra stingy despite trade relations
        if not self.shrewdness then self.shrewdness = 1 end
        local pos = self.object:getpos()
        pos.y = pos.y + 0.5
        for _,v in pairs(self.drops) do
          local d_chance = v.chance / (gr_trade + 1)
          d_chance = d_chance + self.shrewdness
          --more likely to get something really rare , less likely to get something common
          if gift == self.follow[1] then d_chance = 10 end
          d_chance = math.floor(d_chance)
          if math.random(1, d_chance) == 1 then
            if debug_goblins_trade == true then
              print_s(dump(v.name.. " dropped by "..self.name.. " at an adjusted chance of 1 in " ..d_chance))
            end
            minetest.sound_play("goblins_goblin_cackle", {
              pos = pos,
              gain = 0.2,
              max_hear_distance = self.sounds.distance or 10
            })
            --let it go already!
            goblins.mixitup(pos)
            minetest.add_item(pos, {
              name = v.name
            })
          end
        end
      end
      gift_accepted = true
      if name_told and territory_told then
        minetest.chat_send_player(pname,S("@1 of @2 takes your @3!",self.secret_name,self.secret_territory.name,gift_description))
      elseif name_told then
        minetest.chat_send_player(pname,S("@1 takes your @2!",self.secret_name,gift_description))

      else
        minetest.chat_send_player(pname,S("Goblin takes your @1!", gift_description))
      end
      return gift_accepted --acception of gift complete

    else
      if debug_goblins_trade == true then print_s("You did not offer " .. dump(string.split(v,":")[2]) ) end
    end
  end
  minetest.sound_play("goblins_goblin_damage", {
    pos = pos,
    gain = 0.2,
    max_hear_distance = self.sounds.distance or 10
  })
  if name_told and territory_told then
    minetest.chat_send_player(
      pname,S("@1 of @2  does not want your @3",
        self.secret_name,self.secret_territory.name,gift_description))
  elseif name_told then
    minetest.chat_send_player(pname,S("@1 does not want your @2",self.secret_name,gift_description))
  else
    minetest.chat_send_player(pname,S("Goblin does not want your @1",gift_description))
  end
  gift_declined = true
end

--- Replaces nodes with many params.
function goblins.search_replace(
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
  replace_with_secondary,
  decorate,
  debug_me) --this is for placing attached nodes like goblin mushrooms and torches
  local pos  = self.object:getpos()
  if mobs_griefing and not minetest.is_protected(pos, "") and math.random(1, search_rate) == 1 then
    -- look for nodes
    local pos  = self.object:getpos() --
    local pos1 = self.object:getpos()
    local pos2 = self.object:getpos()

    --local pos  = vector.round(self.object:getpos())  --will have to investigate these further
    --local pos1 = vector.round(self.object:getpos())
    --local pos2 = vector.round(self.object:getpos())

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

    if debug_goblins_search and debug_me then
      print (self.name:split(":")[2] .. " at\n "
        .. minetest.pos_to_string(pos) .. " is searching between\n "
        .. minetest.pos_to_string(pos1) .. " and\n "
        .. minetest.pos_to_string(pos2))
    end

    local nodelist = minetest.find_nodes_in_area(pos1, pos2, replace_what)
    if #nodelist > 0 then
      if debug_goblins_find and debug_me then
        print_s(#nodelist.." nodes found by " .. self.name:split(":")[2]..":")
        for k,v in pairs(nodelist) do print_s(minetest.get_node(v).name:split(":")[2].. " found.") end
      end
      for key,value in pairs(nodelist) do
        -- ok we see some nodes around us, are we going to replace them?
        if minetest.is_protected(value.pos, "")  and goblin_node_protect_strict then break end
        if math.random(1, replace_rate) == 1 then
          if replace_rate_secondary and
            math.random(1, replace_rate_secondary) == 1 then
            if decorate then
              value = minetest.find_node_near(value, 2, "air")
            end
            if value ~= nil then
              self:set_velocity(0)
              self:set_animation("stand")
              minetest.set_node(value, {name = replace_with_secondary})
            end
            if debug_goblins_replace2 and debug_me then
              print_s(replace_with_secondary.." secondary node placed by " .. self.name:split(":")[2])
            end
          else
            if decorate then
              value = minetest.find_node_near(value, 2, "air")
            end
            if value ~= nil then
              self:set_velocity(0)
              self:set_animation("stand")
              minetest.set_node(value, {name = replace_with})
            end
            if debug_goblins_replace and debug_me then
              print_s(replace_with.." placed by " .. self.name:split(":")[2])
            end
          end
          minetest.sound_play(self.sounds.replace, {
            object = self.object, gain = self.sounds.gain,
            max_hear_distance = self.sounds.distance
          })
        end
      end
    end
  end
end

--[[
"He destroys everything diggable in his path. It's too much trouble
to fudge around with particulars. Besides, I don't want them to
mine for me." 
      --From the tome __Of Goblinkind__ by duane-r
  
 "The domain of stone is the Goblins home, 
  by metals might one thwart them from invasion."
      --Epithet from __The Luanacy of Goblins__ by Persont Bachslachdi   
--]]

--the following is built from duane-r's goblin tunnel digging:
local diggable_nodes = {"group:stone", "group:sand", "group:soil", "group:cracky", "group:crumbly"}
-- This translates yaw into vectors.
local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}
----------
-- Goblins Tunneling.
---------
-- @type are available for fine-tuning.
function goblins.tunneling(self, type)
  --
  if type == nil then
    type = "digger"
  end

  local pos = self.object:getpos()
  if mobs_griefing and not minetest.is_protected(pos, "") then
    if self.state == "tunnel" then
      self:set_animation("walk")
      self:set_velocity(self.walk_velocity)
      -- Yaw is stored as one of the four cardinal directions.
      if not self.digging_dir then
        self.digging_dir = math.random(0,3)
      end

      -- Turn him roughly in the right direction.
      -- self.object:setyaw(self.digging_dir * math.pi * 0.5 + math.random() * 0.5 - 0.25)
      self.object:setyaw(self.digging_dir * math.pi * 0.5)

      -- Get a pair of coordinates that should cover what's in front of him.
      local p = vector.add(pos, cardinals[self.digging_dir+1])
      -- p.y = p.y - 1  -- What's this about?
      local p1 = vector.add(p, .1)
      local p2 = vector.add(p, 1.5)

      -- Get any diggable nodes in that area.
      local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)
      if #np_list > 0 then
        -- Dig it.
        for _, np in pairs(np_list) do
          if minetest.is_protected(np.pos, "")  and goblin_node_protect_strict then break end
          if np.name ~= "default:mossycobble" and np.name ~= "default:chest" then
            minetest.remove_node(np)
            minetest.sound_play(self.sounds.replace, {
              object = self.object, gain = self.sounds.gain,
              max_hear_distance = self.sounds.distance
            })
          end
        end
      end

      if math.random() < 0.2 then
        local d = {-1,1}
        self.digging_dir = (self.digging_dir + d[math.random(2)]) % 4
      end
      self.state = "walk"
      self:set_animation("walk")
      self:set_velocity(self.walk_velocity)

    elseif self.state == "room" then  -- Dig a room.
      --[[first make sure player is not near by! (not quite ready yet)
          goblins.must_hide = function() 
          end --]]
      if not self.room_radius then
        self.room_radius = 1
    end

    self:set_velocity(0)
    self.state = "stand"
    self:set_animation("stand")

    -- Work from the inside, out.
    for r = 1,self.room_radius do
      -- Get a pair of coordinates that form a room.
      local p1 = vector.add(pos, -r)
      local p2 = vector.add(pos, r)
      -- But not below him.
      p1.y = pos.y

      local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

      --FLG prefers a smaller room with a rougher look for goblin warrens.  Maybe this should be a setting for users preference?
      if r >= self.room_radius and #np_list == 0 then
        --self.room_radius = math.random(1,2) + math.random(0,1)
        self.room_radius = math.random(1,1.5) + math.random(0,0.5)
        --        self.state = "stand"
        --        self:set_velocity(0)
        --        self:set_animation("stand")
        break
      end

      if #np_list > 0 then -- dig it
        if goblin_node_protect_strict then break end
        minetest.remove_node(np_list[math.random(#np_list)])
        minetest.sound_play(self.sounds.replace, {
          object = self.object, gain = self.sounds.gain,
          max_hear_distance = self.sounds.distance
        })
        break
      end
      self.state = "walk"
      self:set_animation("walk")
      self:set_velocity(self.walk_velocity)
    end
    end
    ---the following values should be vars for settings...
    --if we are standing, maybe make a tunnel or
    --if we are tunneling, maybe make a room or
    --if we are tunneling stand or maybe just end this function
    --
    if self.state == "stand" and math.random() < 0.1 then
      self.state = "tunnel"
      if debug_goblins_tunneling then print_s("goblineer is now tunneling") end
    elseif self.state == "tunnel" and math.random() < 0.1 then
      self.state = "room"
      if debug_goblins_tunneling then print_s("goblineer is now making a room") end
    elseif self.state == "tunnel" and math.random() < 0.1 then
      self.state = "stand"
      if debug_goblins_tunneling then print_s(dump(vector.round(self.object:getpos())).. "goblineer is thinking...") end
    end
  end
end


function goblins.goblin_dog_behaviors(self)
  local pos = self.object:getpos()
  if mobs_griefing and not minetest.is_protected(pos, "") then
    if math.random() < 0.5 then
      --consume meaty bones"
      goblins.search_replace(
        self,
        100, --search_rate
        100000, --search_rate_above
        100000, --search_rate_below
        1, --search_offset
        1, --search_offset_above
        1, --search_offset_below
        5, --replace_rate
        {"group:meat","group:food_meat","group:food_meat_raw"}, --replace_what
        "goblins:goblins_goblin_bone", --replace_with
        10, --replace_rate_secondary
        "air", --replace_with_secondary --very hungry
        nil, --decorate
        false --debug_me if debugging also enabled in behaviors.lua
      )
    elseif math.random() < 0.5 then
      --consume dry bones"
      goblins.search_replace(
        self,
        100, --search_rate
        100000, --search_rate_above
        100000, --search_rate_below
        1, --search_offset
        1, --search_offset_above
        1, --search_offset_below
        5, --replace_rate
        "goblins:goblins_goblin_bone", --replace_what
        "air", --replace_with
        nil, --replace_rate_secondary
        nil, --replace_with_secondary
        nil, --decorate
        false--debug_me if debugging also enabled in behaviors.lua
      )
    elseif math.random() < 0.8 then
      --dig and maybe bury bones if theres suitable terrain around
      goblins.search_replace(
        self,
        100, --search_rate
        100000, --search_rate_above
        100, --search_rate_below
        1, --search_offset
        1, --search_offset_above
        2, --search_offset_below
        10, --replace_rate
        {"group:soil",
          "group:sand",
          "default:gravel"}, --replace_what
        "goblins:dirt_with_bone",
        2, --replace_rate_secondary
        "default:dirt", --replace_with_secondary
        nil, --decorate
        false --debug_me if debugging also enabled in behaviors.lua
      )
    else
      --or maybe bury something more useful
      goblins.search_replace(
        self,
        100, --search_rate
        100000, --search_rate_above
        100, --search_rate_below
        1, --search_offset
        1, --search_offset_above
        2, --search_offset_below
        10, --replace_rate
        {"group:soil",
          "group:sand",
          "default:gravel"}, --replace_what
        "goblins:dirt_with_stuff",
        2, --replace_rate_secondary
        "default:dirt", --replace_with_secondary
        nil, --decorate
        false --debug_me if debugging also enabled in behaviors.lua
      )
    end
  end
  --[[not quite ready yet...
  if math.random() < 0.01 then
     goblins.do_taunt_at(self)
     print_s("are " ..dump(self.name).. " barking?" )
  end
 --]]
end

-----
-- CREATE TERRITORIES
-----
-- Get the Minimum of a Chunk https://forum.minetest.net/viewtopic.php?p=351592#p351592
-- by duane » Sun Jul 14, 2019 00:20 and
-- by TalkLounge » Sun Jul 14, 2019 11:39

local function mapgen_min_max(pos)
  local pos = vector.round(pos)
  local chunksize = tonumber(type(minetest.settings) ~= "nil" and minetest.settings:get("chunksize") or minetest.setting_get("chunksize")) or 5
  local chunk_offset = math.floor(chunksize / 2) * 16
  local csize = {x = chunksize * 16, y = chunksize * 16, z = chunksize * 16}
  local chunk = vector.floor(vector.divide(vector.add(pos, chunk_offset), csize))
  local minp = vector.add(vector.multiply(chunk, 80), -chunk_offset)
  local maxp = vector.add(minp, (chunksize * 16) - 1)
  return minp, maxp
end

-- refer to https://rubenwardy.com/minetest_modding_book/en/map/storage.html
local goblins_db_fields = goblins_db:to_table()["fields"]

local function goblins_db_deser(table)
  local data = minetest.deserialize(goblins_db_fields[table])
  return data
end

local function goblins_db_read(table)
  local data = minetest.deserialize(goblins_db:to_table()["fields"][table])
  return data
end

local function goblins_db_write(key, table)
  local data = minetest.serialize(table)

  goblins_db:set_string(key, data)
  return key, data
end

function goblins.territory_test(pos,territories)

  local db_test = minetest.serialize({fieldtest = "initialized"})
  print_s("\nBEGIN EXISTING LIST--------\n"..dump(goblins_db_read("territories")).."\n ------END LIST\n")
end --test

-- Provides a way to take a chunks position and use it a base for storing information in a mod.
-- it is dependant on the mapgen_min_max function above as well the goblins_db functions for storage.
-- @opt_data is just for adding information to this territories storage it expects a table
function goblins.territory(pos, opt_data)
  -- this should be called on spawn but before a goblin gets its secret name
  -- a handy chunk name key generator, should create a unique name for every chunk
  local function cat_pos(chunk)
    return "Xa"..chunk[1].x.."_Ya"..chunk[1].y.."_Za"..chunk[1].z.."_x_Xb"..chunk[2].x.."_Yb"..chunk[2].y.."_Zb"..chunk[2].z
  end

  -- get list of known territories and thier chunks or
  local existing_territories = {}
  existing_territories = goblins_db_read("territories")
  local minp_maxp = {mapgen_min_max(pos)}
  local this_territory = {}
  local volume_cat_pos = cat_pos(minp_maxp)
  --print_s(dump(volume_cat_pos).." cat paws!")
  if debug_goblins_territories then
    print_s("\n----Known territories")
    for k,v in pairs(existing_territories) do
      print_s(dump(k).." is known as "..dump(existing_territories[k].name))
    end
    print_s("----End Known territories\n")
  end
  local territories_table = table.copy(existing_territories)
  -- print_s(dump(territories_table).."copied territories")
  -- print_s("\nTERRITORY TEST TABLE READ:\n" ..dump(goblins_db_read("territories")).."\n")
  if territories_table[volume_cat_pos]  then
    local t_vol = volume_cat_pos
    local t_name = territories_table[volume_cat_pos]["name"]
    if opt_data then  --insert a table
      for k,v in pairs(opt_data) do
        --if not territories_table[volume_cat_pos][k] -- this is tricky...
        territories_table[volume_cat_pos][k] = v
        local territories_table_ser = minetest.serialize(territories_table)
        goblins_db:set_string("territories", territories_table_ser )
        if debug_goblins_territories then
          print_s(k.." added to "..territories_table[volume_cat_pos]["name"])
        end
        --end
    end
    return t_name, t_vol
    end
    if debug_goblins_territories then
      print_s(dump(t_name).." at "..dump(t_vol).." is already known!")
    end
    -- print_s(dump(territories_table[volume_cat_pos]).. "\n ---end details \n")
    return t_name, t_vol
  else
    -- generate a name for this territory
    local name_rules = {"list_a","list_opt","-","list_b"}
    local territory_name = goblins.generate_name(gob_name_parts,name_rules)
    -- print_s(dump(territory_name).." is a name whispered among those who dwell here")
    -- set concatenated minp_maxp as the key for this territory and populate data
    -- print_s(dump(volume_cat_pos)))
    this_territory[(volume_cat_pos)] = {
      ["name"] = territory_name,
      ["flag"] = pos,
    }
    if debug_goblins_territories then
      print_s("The territory of "..dump(this_territory[volume_cat_pos]["name"]).. " at "..volume_cat_pos.." will be recorded.")
    end
    territories_table[volume_cat_pos] = this_territory[volume_cat_pos]
    -- print_s(dump(territories_table).. " is the new table \n")
    -- print_s("\nTERRITORY TESTING SERIALIZED WRITE:\n"..dump(this_territory_ser).."\n")
    -- prepare the territories_table for storage, unless we have something else to say..
    if opt_data then  --insert a table
      for k,v in pairs(opt_data) do
        --if not territories_table[volume_cat_pos][k] -- this is tricky...
        territories_table[volume_cat_pos][k] = v
        local territories_table_ser = minetest.serialize(territories_table)
        goblins_db:set_string("territories", territories_table_ser )
        if debug_goblins_territories then
          print_s(k.." added to "..territories_table[volume_cat_pos]["name"])
        end
        --end
    end
    local t_name = territory_name
    local t_vol = volume_cat_pos
    return t_name, t_vol
    end
    local territories_table_ser = minetest.serialize(territories_table)
    goblins_db:set_string("territories", territories_table_ser )
    local t_name = territory_name
    local t_vol = volume_cat_pos
    return t_name, t_vol
  end
  --print_s("\nTERRITORY TEST:\n"..dump(this_territory.name).."\n")
end


-- Expresses and optionally store the relationship between a mob and a player or another mob.
-- Will return all known relationships if nothing is defined.
-- @self will return only relations know to that mob
-- @target_name will return the table of the self.relations (mobs) relations to the target if
-- optional target_table is not defined.
-- @target_table will set the value of a mobs relation to the target.
-- THIS SCRIPT IS DEPENDANT on secret_name and secret_territory!
function goblins.relations(self, target_name, target_table)
  local existing_relations = {}
  if not goblins_db_read("relations") then
    print_s("relations DB not initialized from init.lua!!")
    return
  end
  local existing_relations = goblins_db_read("relations")
  -- do we want to know something in particular?
  if self then
    local name = self.secret_name
    --have we started keeping track of who we know?
    if not self["relations"] then
      self.relations = {initialized = os.time()}
      if debug_goblins_relations then print_s("self table: "..dump(self)) end
      -- create an entry for ourselves with our territory as the value
      if self.secret_name and self.secret_territory then
        self.relations[name] = self.secret_territory.name
        existing_relations[name] = self.relations
        if debug_goblins_relations then print_s("self table updated: "..dump(self.relations).."\n") end
        if debug_goblins_relations then print_s("adding mob to relations table: "..dump(existing_relations[self]).."\n")end
        goblins_db_write("relations",existing_relations)
      end
    end
    -- do we just want to know how we feel about the target?
    if target_name and not target_table then
      -- do we even know the target?
      if not self.relations[target_name] then
        self.relations[target_name] = {initialized = os.time()}
        existing_relations[name] = self.relations
        goblins_db_write("relations",existing_relations)
      end
      return self.relations[target_name]
    end
    -- we have something to say about the target!
    if target_name and target_table then
      -- mob adds it to their entity..
      self.relations[target_name] = target_table
      existing_relations[name] = self.relations
      -- we add or modify this relationship in the mod storage "relations"

      --existing_relations[name][target_name] = target_value
      --print_s(dump(existing_relations))
      goblins_db_write("relations",existing_relations)
      if debug_goblins_relations then print_s("updated self table: "..dump(self.relations).."\n") end
      return existing_relations[target_name]
    end
  end
  -- we dont have a target just dump everything known about everone
  return existing_relations
end

--Returns the trade score of a player for the mobs home territory
function goblins.relations_trade(self, player_name)
  local pname = player_name
  local relations = goblins.relations(self)
  local t_trade = 0
  -- initialize tables if necessary
  if not self["relations"] then self.relations = {initialized = os.time()} end
  if not self.relations[pname] then goblins.reltions(self, pname) end
  if not self.relations[pname]["trade"] then self.relations[pname]["trade"] = 0 end
  --be sure that relations have been started with player before using this!
  for m_name,prop in pairs(relations) do
    if self.secret_territory.name == relations[m_name][m_name] and
      relations[m_name][pname] and relations[m_name][pname].trade then
      t_trade = t_trade + relations[m_name][pname].trade
      if debug_goblins_trade_relations then print_s(m_name.." = "..relations[m_name][pname].trade)end
    end
  end
  if debug_goblins_trade_relations then
    print_s("relations are "..dump(relations[self.secret_name]))
    print_s("territory trade score = "..t_trade)
  end
  return t_trade
end
  
