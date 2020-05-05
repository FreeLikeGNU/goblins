
local announce_spawning = false

local debug_goblins_search = false
local debug_goblins_find = false
local debug_goblins_replace = false
local debug_goblins_replace2 = false
local debug_goblins_tunneling = false
local debug_goblins_trade = false
local debug_goblins_territories = false

local goblin_node_protect_strict = true

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

function goblins.generate(gob_types,goblin_template)
  for k, v in pairs(gob_types) do
    -- we need to get a fresh template to modify for every type or we get some carryover values:-P
    local g_template = table.copy(goblin_template)
    -- g_type should be different every time so no need to freshen
    local g_type = v
    for x, y in pairs(g_type) do
      -- print("found template modifiers " ..dump(x).." = "..dump(y))
      g_template[x] = g_type[x]
    end
    print ("Assembling the "..g_template.description..":")
    if g_template.lore then print("  "..g_template.lore) end
    --print("resulting template: " ..dump(g_template))
    mobs:register_mob("goblins:goblin_"..k, g_template)
    mobs:register_egg("goblins:goblin_"..k,g_template.description.. " Goblin Egg","default_mossycobble.png", 1)
    g_template.spawning.name = "goblins:goblin_"..k --spawn in the name of the key!
    mobs:spawn(g_template.spawning)
    g_template = {}
  end
end

function goblins.generate_name(name_parts, rules)
  -- print("generating name")
  local name_arrays = {}
  local r_parts = {}
  local generated_name = {}
  for k,v in pairs(name_parts) do
    --  name_arrays.k = mysplit(v)
    name_arrays.k = string.split(v," ")
    -- print(dump(name_arrays.k))
    r_parts[k] = k
    r_parts[k] = name_arrays.k[math.random(1,#name_arrays.k)]
  end
  --local r_parts.k = name_arrays.k[math.random(1,#name_arrays.k)] did not work
  --print(name_a)
  if r_parts.list_opt and math.random() <= 0.5 then r_parts.list_opt = "" end
  --print(r_parts.list_a..r_parts.list_b..r_parts.list_opt)

  if rules then
    --print(dump(rules))
    local gen_name = ""
    for i, v in ipairs(rules) do
      if v == "-" then
        gen_name = gen_name.."-"
      else
        gen_name = gen_name..r_parts[v]
      end
    end
    generated_name = gen_name
    --print(dump(generated_name))
    return generated_name
  else

    generated_name = r_parts.list_a..r_parts.list_b..r_parts.list_opt
    return generated_name
  end
end

--returns a list of special gifts based on goblin drops defs
function goblins.special_gifts(self)
  local special_gifts = {}
  --special things from goblins drops table can be defined with a very rare drop chance
  local from_drops = {}
  for _,v in pairs(self.drops) do
    if v.chance >= 1000 then
    --print(dump(v.name).. " with 1 chance in " ..dump(v.chance))
    end
    if v.chance >= 1000 then
      table.insert(from_drops, v.name)
    end
  end
  --print(dump(dump(from_drops).." are possible gifts")
  if from_drops then
    for _,v in pairs(from_drops) do
      table.insert(special_gifts, v)
    end
  end
  if special_gifts then
    --print(dump(special_gifts).." have been generated")
    return special_gifts
  else
    special_gifts = {"default:mese"}
    --print(dump(special_gifts).." have been generated due to lack of definition")
    return special_gifts
  end

end
------------
--(the omnicient) Announce Spawn ...summon it with care, for the floods shall come!
-----------
function goblins.announce_spawn(self)
  if announce_spawning == true then
    local pos = vector.round(self.object:getpos())
    if not pos then return end

    if self.secret_name then
      print( self.name:split(":")[2].. ", "..self.secret_name.." spawned at: " .. minetest.pos_to_string(pos))
    else
      print( self.name:split(":")[2].. " spawned at: " .. minetest.pos_to_string(pos))
    end

    --goblins.territory(pos)

    if self.secret_territory then
      if self.secret_name then
        print(self.secret_name.. " dwells in "..self.secret_territory["name"].." at " ..self.secret_territory["vol"].."!\n" )
      else
        print("A nameless creature inhabits"..self.secret_territory["name"].." at " ..self.secret_territory["vol"].."!\n" )
      end
    else
      local territory = {goblins.territory(pos)}
      if self.secret_name then
        print(territory[1].." at "..territory[2].." festers with the lurking form of "..self.secret_name.."\n")
      else
        print(territory[1].." at "..territory[2].." becomses the domain of a nameless one\n")
      end
    end

  end
end

function goblins.give_gift(self,clicker)
  -- you can give a gift, they may give something(s) in return...
  --if mobs:feed_tame(self, clicker, 14, false, false) then
  local item = clicker:get_wielded_item()
  local name = clicker:get_player_name()
  local gift_accepted = nil
  local gift_declined = nil
  local pname = clicker:get_player_name()
  --establish some shrewdness if its not set
  if not self.shrewdness then self.shrewdness = 10 end
  local gift = item:get_name()
  local gift_description = item:get_definition().description
  if debug_goblins_trade == true then print("you offer: " .. dump(gift)) end
  for _,v in pairs(self.follow) do
    if v == gift then
      gift_accepted = true
      if debug_goblins_trade == true then print("you gave "..self.name.. " a " .. dump(gift)) end
      --reduce shrewdness on gifting
      if self.shrewdness >= 2 then self.shrewdness = self.shrewdness - 1 end
      if gift == self.follow[1] then
        if self.shrewdness >= 4 then self.shrewdness = self.shrewdness - 3 end
        if debug_goblins_trade == true then print("you gave the perfect gift!") end
        minetest.chat_send_player(pname,"Yessss! " .. gift_description.."!")
      end
      if debug_goblins_trade == true then print("shrewdness = " ..dump(self.shrewdness)) end
      if not minetest.settings:get_bool("creative_mode") then
        item:take_item()
        clicker:set_wielded_item(item)
      end
      --print(dump(self.object:get_luaentity()).. " at " ..dump(self.object:getpos()).. " takes: " ..dump(item:get_name()))
      if debug_goblins_trade == true  then
        print("you may get some of "..dump(#self.drops).. " things such as: ")
        for _,v in pairs(self.drops) do
          print(dump(v.name).. " with 1 chance in " ..dump(v.chance).. " + " ..dump(self.shrewdness))
        end
      end
      local pos = self.object:getpos()
      pos.y = pos.y + 0.5
      if self.special_gift then
        minetest.add_item(pos, {
          name = self.special_gift
        })
        minetest.chat_send_player(pname, self.secret_name.. " gives you a precious thing")
        self.special_gift = false
      else
        for _,v in pairs(self.drops) do
          local trade_chance = v.chance + self.shrewdness
          if self.shrewdness and self.shrewdness <= 2 and gift == self.follow[1] then trade_chance = 2 end
          if math.random(1, trade_chance) == 1 then
            if debug_goblins_trade == true then print(dump(v.name.. " dropped by "..self.name.. " at a chance of 1 in " ..trade_chance)) end
            pos.y = pos.y + math.random()
            pos.x = pos.x + math.random()
            pos.x = pos.x - math.random()
            pos.z = pos.z + math.random()
            pos.z = pos.z - math.random()
            minetest.add_item(pos, {
              name = v.name
            })
          end
        end
      end
      gift_accepted = true
      if self.nametag then
        minetest.chat_send_player(pname,self.nametag.. " takes your " .. gift_description)
      else
        minetest.chat_send_player(pname,"Goblin takes your " .. gift_description)
      end
      return gift_accepted --acception of gift complete

    else
      if debug_goblins_trade == true then print("you did not offer " .. dump(string.split(v,":")[2]) ) end
    end
  end
  if self.nametag then
    minetest.chat_send_player(pname,self.nametag.. " does not want your " .. gift_description)
  else
    minetest.chat_send_player(pname,"Goblin does not want your " .. gift_description)
  end
  gift_declined = true
end


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
        print(#nodelist.." nodes found by " .. self.name:split(":")[2]..":")
        for k,v in pairs(nodelist) do print(minetest.get_node(v).name:split(":")[2].. " found.") end
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
              print(replace_with_secondary.." secondary node placed by " .. self.name:split(":")[2])
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
              print(replace_with.." placed by " .. self.name:split(":")[2])
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

function goblins.tunneling(self, type)
  -- Types are available for fine-tuning.
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
      if debug_goblins_tunneling then print("goblineer is now tunneling") end
    elseif self.state == "tunnel" and math.random() < 0.1 then
      self.state = "room"
      if debug_goblins_tunneling then print("goblineer is now making a room") end
    elseif self.state == "tunnel" and math.random() < 0.1 then
      self.state = "stand"
      if debug_goblins_tunneling then print(dump(vector.round(self.object:getpos())).. "goblineer is thinking...") end
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
     print("are " ..dump(self.name).. " barking?" )
  end
 --]]
end

-----
-- CREATE TERRITORIES
-----
local gob_name_parts = {
  list_a = "Ach Adz Ak Ark Az Balg Bilg Blid Blig Blok Blot Bolg Boor Bot Bug Burk Chu Dokh Drik Driz Drub Duf Flug Gaw Gad Gag Gah Gak Gar Gat Gaz Ghag Ghak Ghor Git Glag Glak Glat Glig Gliz Glok Gnat Gog Grak Grat Guk Hig Irk Kak Kav Khad Krig Lag Lak Lig Likk Loz Luk Lun Mak Maz Miz Mog Mub Mur Nad Nag Naz Nilg Nikk Nogg Nok Nukk Nur Pog Rag Rak Rat Rok Ronk Rot Shrig Shuk Skrag Skug Slai Slig Slog Sna Snag Snark Snat Snig Snik Snit Sog Spik Stogg Tog Unk Urf Vark Vog Yad Yagg Yak Yark Yarp Yig Yip Zat Zib Zit Ziz Zob Zord",
  list_b = "ach adz ak ark awg az balg bilg blid blig blok blot bolg bot bug burk bus dokh drik driz duf ffy flug g ga gad gag gah gak gar gat gaz ghag ghak git glag glak glat glig gliz glok gnat gog grak grat gub guk hig irk kak khad krig lag lak lig likk loz luk mak maz miz mub murch nad nag naz nilg nikk nogg nok nukk og plus rag rak rat rkus rok shrig shuk skrag skug slai slig slog sna snag snark snat snig snik snit sog spik stogg thus tog un urf us vark yad yagg yak yark yarp yig yip zat zib zit ziz",
  list_opt = "ah ay e ee gah ghy y ya"
}



-- Get the Minimum of a Chunk https://forum.minetest.net/viewtopic.php?p=351592#p351592
-- by duane » Sun Jul 14, 2019 00:20 and
-- by TalkLounge » Sun Jul 14, 2019 11:39
-- refer to https://rubenwardy.com/minetest_modding_book/en/map/storage.html

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
  print("\nBEGIN EXISTING LIST--------\n"..dump(goblins_db_read("territories")).."\n ------END LIST\n")
end --test

-- refer to https://rubenwardy.com/minetest_modding_book/en/map/storage.html
function goblins.territory(pos,t_name,t_vol)
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
  --print(dump(volume_cat_pos).." cat paws!")
  if debug_goblins_territories then
    print("\n----Known territories")
    for k,v in pairs(existing_territories) do
      print(dump(k).." is known as "..dump(existing_territories[k].name))
    end
    print("----End Known territories\n")
  end
  local territories_table = table.copy(existing_territories)
  -- print(dump(territories_table).."copied territories")
  -- print("\nTERRITORY TEST TABLE READ:\n" ..dump(goblins_db_read("territories")).."\n")
  if territories_table[volume_cat_pos]  then
    local t_vol = volume_cat_pos
    local t_name = territories_table[volume_cat_pos]["name"]
    if debug_goblins_territories then
      print(dump(t_name).." at "..dump(t_vol).." is already known!")
    end
    -- print(dump(territories_table[volume_cat_pos]).. "\n ---end details \n")
    return t_name, t_vol
  else
    -- generate a name for this territory
    local name_rules = {"list_a","list_opt","-","list_b"}
    local territory_name = goblins.generate_name(gob_name_parts,name_rules)
    -- print(dump(territory_name).." is a name whispered among those who dwell here")
    -- set concatenated minp_maxp as the key for this territory and populate data
    -- print(dump(volume_cat_pos)))
    this_territory[(volume_cat_pos)] = {
      ["name"] = territory_name,
      ["flag"] = pos,
    }
    if debug_goblins_territories then
      print("The territory of "..dump(this_territory[volume_cat_pos]["name"]).. " at "..volume_cat_pos.." will be recorded.")
    end
    territories_table[volume_cat_pos] = this_territory[volume_cat_pos]
    -- print(dump(territories_table).. " is the new table \n")
    -- print("\nTERRITORY TESTING SERIALIZED WRITE:\n"..dump(this_territory_ser).."\n")
    -- prepare the territories_table for storage
    local territories_table_ser = minetest.serialize(territories_table)
    goblins_db:set_string("territories", territories_table_ser )
    local t_name = territory_name
    local t_vol = volume_cat_pos
    return t_name, t_vol
  end
  --print("\nTERRITORY TEST:\n"..dump(this_territory.name).."\n")
end

