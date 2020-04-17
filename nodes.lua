--set namespace for goblins functions
goblins = {}

minetest.register_node(":default:mossycobble", {
  description = "Mossy Cobblestone",
  tiles = {"default_mossycobble.png"},
  is_ground_content = false,
  groups = {cracky = 3, stone = 1},
  sounds = default.node_sound_stone_defaults(),
  paramtype = "light",
  light_source = 2,
})

minetest.register_node("goblins:mushroom_goblin", {
  description = "gobble mushroom",
  tiles = {"goblins_mushroom_brown.png"},
  inventory_image = "goblins_mushroom_brown.png",
  wield_image = "goblins_mushroom_brown.png",
  drawtype = "firelike",
  paramtype = "light",
  light_source = 2,
  sunlight_propagates = true,
  walkable = false,
  buildable_to = true,
  climbable = true,
  floodable = true,
  groups = {mushroom = 1, food_mushroom = 1, snappy = 1, attached_node = 1, flammable = 1},
  sounds = default.node_sound_leaves_defaults(),
  on_use = minetest.item_eat(2),
  selection_box = {
    type = "fixed",
    fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
  }
})

minetest.register_node("goblins:mushroom_goblin2", {
  description = "gobble mushroom",
  tiles = {"goblins_mushroom_brown2.png"},
  inventory_image = "goblins_mushroom_brown2.png",
  wield_image = "goblins_mushroom_brown.png",
  drawtype = "firelike",
  paramtype = "light",
  light_source = 2,
  sunlight_propagates = true,
  walkable = false,
  buildable_to = true,
  climbable = true,
  floodable = true,
  groups = {mushroom = 1, food_mushroom = 1, snappy = 1, attached_node = 1, flammable = 1},
  sounds = default.node_sound_leaves_defaults(),
  on_use = minetest.item_eat(4),
  selection_box = {
    type = "fixed",
    fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
  }
})

minetest.register_node("goblins:mushroom_goblin3", {
  description = "gobble mushroom",
  tiles = {"goblins_mushroom_brown3.png"},
  inventory_image = "goblins_mushroom_brown3.png",
  wield_image = "goblins_mushroom_brown.png",
  drawtype = "firelike",
  paramtype = "light",
  light_source = 2,
  sunlight_propagates = true,
  walkable = false,
  buildable_to = true,
  climbable = true,
  floodable = true,
  groups = {mushroom = 1, food_mushroom = 1, snappy = 2, attached_node = 1, flammable = 1},
  sounds = default.node_sound_leaves_defaults(),
  on_use = minetest.item_eat(5),
  selection_box = {
    type = "fixed",
    fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
  }
})
minetest.register_node("goblins:mushroom_goblin4", {
  description = "gobble mushroom",
  tiles = {"goblins_mushroom_brown4.png"},
  inventory_image = "goblins_mushroom_brown4.png",
  wield_image = "goblins_mushroom_brown.png",
  drawtype = "firelike",
  paramtype = "light",
  light_source = 2,
  sunlight_propagates = true,
  walkable = false,
  buildable_to = true,
  climbable = true,
  floodable = true,
  groups = {mushroom = 1, food_mushroom = 1, snappy = 3, attached_node = 1, flammable = 1},
  sounds = default.node_sound_leaves_defaults(),
  on_use = minetest.item_eat(6),
  selection_box = {
    type = "fixed",
    fixed = {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16},
  }
})

function goblins.mushroom_spread(pos, node)
  if minetest.get_node_light(pos, 0.5) > 6 then
    if minetest.get_node_light(pos, nil) == 15 then
      minetest.remove_node(pos)
    end
    return
  end
  local positions = minetest.find_nodes_in_area_under_air(
    {x = pos.x - 1, y = pos.y - 2, z = pos.z - 1},
    {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
    {"default:mossycobble"})
  if #positions == 0 then
    return
  end
  local pos2 = positions[math.random(#positions)]
  pos2.y = pos2.y + 1
  if minetest.get_node_light(pos2, 0.5) <= 5 then
    minetest.set_node(pos2, {name = node.name})
  end
end

minetest.register_abm({
  label = "Mushroom spread",
  nodenames = {"goblins:mushroom_goblin","goblins:mushroom_goblin2","goblins:mushroom_goblin3","goblins:mushroom_goblin4"},
  interval = 100,
  chance = 100,
  action = function(...)
    goblins.mushroom_spread(...)
  end,
})
