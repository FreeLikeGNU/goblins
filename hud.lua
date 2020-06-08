local saved_huds = {}

function goblins.update_hud(player)

  --for _,player in ipairs(minetest.get_connected_players()) do
    local player_name = player:get_player_name()

    print(player_name)
    local meta = player:get_meta()
      local territory_current = meta:get_string("territory_current")
      local known_territories = minetest.deserialize(meta:get_string("territory_list"))
      local territory = "unknown"
      if known_territories then
        for k,v in pairs(known_territories) do
          if territory_current == v then
            territory = v
          end
        end
      end
      local text_territory_current   = "Current territory: " ..territory
      local territory_score_table = minetest.deserialize(meta:get_string(territory_current))
      local text_territory_scores = {}
      if not territory_score_table then return end
      for k,v in pairs(territory_score_table) do
        text_territory_scores[k] = k.." = "..v
      end

      local ids = saved_huds[player_name]

      if ids then
          player:hud_change(ids["territory_current"], "text", text_territory_current)
          for k,v in pairs(territory_score_table) do
            player:hud_change(ids.territory_scores[k],   "text", text_territory_scores[k])
          end
          --player:hud_change(ids["bar_foreground"],
                  --"scale", { x = percent, y = 1 })
      else
          ids = {}
          ids.territory_scores = {}
          saved_huds[player_name] = ids

          -- create HUD elements and set ids into `ids`
          player:hud_add({
            hud_elem_type = "text",
            position  = {x = 1, y = 0.5},
            offset    = {x = -120, y = -25},
            text      = "Goblin HUD",
            alignment = -0,
            scale     = { x = 100, y = 30},
            number    = 0xFFFFFF,
          })

          ids.territory_current = player:hud_add({
            hud_elem_type = "text",
            position  = {x = 1, y = 0.5},
            offset    = {x = -120, y = 0},
            text      = text_territory_current,
            alignment = -1,
            scale     = { x = 50, y = 10},
            number    = 0xFFFFFF,
          })

          local tst_yo = 0
          for k,v in pairs(territory_score_table) do
            tst_yo = tst_yo + 20
            ids.territory_scores[k] = player:hud_add({
              hud_elem_type = "text",
              position  = {x = 1, y = 0.5},
              offset    = {x = -120, y = tst_yo},
              text      = text_territory_scores[k],
              alignment = -1,
              scale     = { x = 50, y = 10},
              number    = 0xFFFFFF,
            })
          end
          
      end

  --end
end

minetest.register_on_joinplayer(goblins.update_hud)
minetest.register_on_leaveplayer(function(player)
  saved_huds[player:get_player_name()] = nil
end)