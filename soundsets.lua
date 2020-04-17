-- optional ambience api mod: https://notabug.org/TenPlus1/ambience

if minetest.get_modpath("ambience") then
--print(dump( minetest.get_modpath("ambience") ))
print("ambience mod detected!")

ambience.del_set("cave")
 ambience.add_set("underground", {
  frequency = 1000,
  sounds = {
    {name = "goblins_ambient_underground", length = 25}
  },
  sound_check = function(def)
      		--[[ local c = (def.totals["default:mossycobble"] or 0)
                       + (def.totals["default:stone"] or 0) 
      if c > 5  then--]]
    if  def.pos.y < -15 then
      return "underground"
    end
  end,
  })
  
--Does not seem to be working as expected, but maybe someday:
  ambience.add_set("mossycobble", {
    frequency = 100,
    sounds = {
      {name = "goblins_ambient_drip", length = 11.4}
    },
    sound_check = function(def)
      local c = (def.totals["default:mossycobble"] or 0)
   
      if c > 10 and def.pos.y < -15 then

        return "mossycobble"
      end
    end,
  })


end