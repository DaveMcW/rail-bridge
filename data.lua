function cut_off_bottom(picture, bottom)
  picture.scale = picture.scale or 1
  local top = -picture.height / 2
  if top < bottom then
    picture.height = bottom - top
    picture.shift = util.by_pixel(0, (top + picture.height/2) * picture.scale)
  else
    picture.filename = "__core__/graphics/empty.png"
    picture.height = 1
  end
end

-- Custom horizontal rail
local rail_east = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
rail_east.name = "rail-bridge-east"
rail_east.collision_mask = {}
rail_east.collision_box = {{-0.4, -0.99}, {0.4, 0.1}}
rail_east.minable = nil
rail_east.flags = {"building-direction-8-way", "not-deconstructable", "not-upgradable"}
rail_east.selectable_in_game = false
data:extend{rail_east}

-- Custom vertical rail
local rail_north = table.deepcopy(rail_east)
rail_north.name = "rail-bridge-north"
rail_north.collision_box = {{-0.4, -0.1}, {0.4, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer], -14)
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer].hr_version, -28)
end
for _, picture in pairs(rail_north.pictures.rail_endings.sheets) do
  cut_off_bottom(picture, 18)
  cut_off_bottom(picture.hr_version, 36)
end
data:extend{rail_north}

-- Bridge entity
local bridge = {
  type = "simple-entity-with-force",
  name = "rail-bridge",
  icon = "__rail-bridge__/graphics/icon.png",
  icon_size = 32,
  order = "a[train-system]-a[rail]-b[bridge]",
  subgroup = "transport",
  flags = {"placeable-neutral", "player-creation"},
  collision_mask = {"item-layer", "object-layer", "water-tile"},
  collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-1.2, -1}, {1.2, 1.6}},
  minable = {mining_time = 0.5, result = "rail-bridge"},
  max_health = 300,
  resistances = table.deepcopy(rail_north.resistances),
  corpse = "straight-rail-remnants",
  render_layer = "lower-object",
  picture = {layers = {}},
}
for _, layer in pairs{"stone_path", "ties", "backplates", "metals"} do
  table.insert(bridge.picture.layers, table.deepcopy(rail_east.pictures.straight_rail_horizontal[layer]))
end
table.insert(bridge.picture.layers, {
  filename = "__rail-bridge__/graphics/bridge.png",
  priority = "extra-high",
  width = 72,
  height = 30,
  shift = util.by_pixel(0, 34),
  hr_version = {
    filename = "__rail-bridge__/graphics/hr-bridge.png",
    priority = "extra-high",
    width = 144,
    height = 60,
    shift = util.by_pixel(0, 34),
    scale = 0.5,
  }
})
data:extend{bridge}

-- Bridge item
local item = {
  type = "item",
  name = bridge.name,
  place_result = bridge.name,
  icon = bridge.icon,
  icon_size = bridge.icon_size,
  subgroup = bridge.subgroup,
  order = bridge.order,
  flags = {},
  stack_size = 10,
}
data:extend{item}

-- Bridge recipe
local recipe = {
  type = "recipe",
  name = "rail-bridge",
  result = "rail-bridge",
  ingredients = {
    {"concrete", 100},
    {"steel-plate", 20},
    {"rail", 2},
  },
}
data:extend{recipe}

-- Bridge is unlocked with Logistics 3
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge",
})
