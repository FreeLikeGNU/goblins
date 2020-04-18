
local debugging_goblins_search = false
local debugging_goblins_find = false
local debugging_goblins_replace = false
local debugging_goblins_replace2 = false
local debugging_goblins_tunneling = false

goblins.search_replace = function(
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

  if math.random(1, search_rate) == 1 then
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

    if debugging_goblins_search and debug_me then
      print (self.name:split(":")[2] .. " at\n "
        .. minetest.pos_to_string(pos) .. " is searching between\n "
        .. minetest.pos_to_string(pos1) .. " and\n "
        .. minetest.pos_to_string(pos2))
    end

    local nodelist = minetest.find_nodes_in_area(pos1, pos2, replace_what)
    if #nodelist > 0 then
      if debugging_goblins_find and debug_me then
        print(#nodelist.." nodes found by " .. self.name:split(":")[2]..":")
        for k,v in pairs(nodelist) do print(minetest.get_node(v).name:split(":")[2].. " found.") end
      end
      for key,value in pairs(nodelist) do 
        -- ok we see some nodes around us, are we going to replace them?
        if math.random(1, replace_rate) == 1 then
          if replace_rate_secondary and
            math.random(1, replace_rate_secondary) == 1 then
            if decorate then
              value = minetest.find_node_near(value, 2, "air")
            end   
            if value ~= nil then
              minetest.set_node(value, {name = replace_with_secondary})
            end
            if debugging_goblins_replace2 and debug_me then
              print(replace_with_secondary.." secondary node placed by " .. self.name:split(":")[2])
            end
          else
            if decorate then
              value = minetest.find_node_near(value, 2, "air")
            end   
            if value ~= nil then
              minetest.set_node(value, {name = replace_with})
            end
            if debugging_goblins_replace and debug_me then
              print(replace_with.." placed by " .. self.name:split(":")[2])
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
local diggable_nodes = {"group:stone", "group:sand", "group:soil", "group:cracky", "group:crumbly", "group:choppy", "group:plant"}
-- This translates yaw into vectors.
local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}

goblins.tunneling = function(self, type)
  -- Types are available for fine-tuning.
  if type == nil then
    type = "digger"
  end

  local pos = self.object:getpos()

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
    --nah too flat! p.y = p.y - 0.5  -- What's this about?
    local p1 = vector.add(p, -0.3)
    local p2 = vector.add(p, 0.3)

    -- Get any diggable nodes in that area.
    local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

    if #np_list > 0 then
      -- Dig it.
      for _, np in pairs(np_list) do
        if np.name ~= "default:cobble" then
          minetest.remove_node(np)
        end
      end
    end

    if math.random() < 0.2 then
      local d = {-1,1}
      self.digging_dir = (self.digging_dir + d[math.random(2)]) % 4
    end

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
        self.state = "stand"
            self:set_velocity(0)
            self:set_animation("stand")
        break
      end

      if #np_list > 0 then
        -- Dig it.
        minetest.remove_node(np_list[math.random(#np_list)])
        break
      end
    end
  end
---the following values should be vars for settings...
  if self.state == "stand" and math.random() < 0.01 then
    self.state = "tunnel"
    if debugging_goblins_tunneling then print("goblineer is now tunneling") end
  elseif self.state == "tunnel" and math.random() < 0.01 then
    self.state = "room"
    if debugging_goblins_tunneling then print("goblineer is now making a room") end
  elseif self.state == "tunnel" and math.random() < 0.001 then
    self.state = "stand"
    if debugging_goblins_tunneling then print(dump(vector.round(self.object:getpos())).. "goblineer is thinking...") end
  end
end



--To Be Implemented someday:
--Goblin Chest gen based on Minetest Game mod: dungeon_loot Originally by sfan5 (MIT)



