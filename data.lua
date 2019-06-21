local function cut_off_bottom(picture, bottom)
  picture.scale = picture.scale or 1
  local top = -picture.height / 2
  if top < bottom then
    picture.height = bottom - top
    local shift = util.by_pixel(0, (top + picture.height/2) * picture.scale)
    if not picture.shift then
      picture.shift = shift
    else
      picture.shift[1] = picture.shift[1] + shift[1]
      picture.shift[2] = picture.shift[2] + shift[2]
    end
  else
    picture.filename = "__core__/graphics/empty.png"
    picture.width = 1
    picture.height = 1
  end
end

local function copy_and_shift(source, shift)
  local picture = table.deepcopy(source)
  if not picture.shift then picture.shift = {0, 0} end
  if not picture.hr_version.shift then picture.hr_version.shift = {0, 0} end
  picture.shift[1] = picture.shift[1] + shift[1]
  picture.shift[2] = picture.shift[2] + shift[2]
  picture.hr_version.shift[1] = picture.hr_version.shift[1] + shift[1]
  picture.hr_version.shift[2] = picture.hr_version.shift[2] + shift[2]
  return picture
end

-- Horizontal rail for up/down bridge
local rail_east = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
rail_east.name = "rail-bridge-east"
rail_east.collision_box = {{-0.4, -0.99}, {0.4, 0.1}}
rail_east.collision_mask = {}
rail_east.minable = nil
rail_east.flags = {"building-direction-8-way", "not-deconstructable", "not-upgradable"}
rail_east.selectable_in_game = false
data:extend{rail_east}

-- Vertical rail for up/down bridge
local rail_north = table.deepcopy(rail_east)
rail_north.name = "rail-bridge-north"
rail_north.collision_box = {{-0.4, -0.1}, {0.4, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer], -14)
  cut_off_bottom(rail_north.pictures.straight_rail_vertical[layer].hr_version, -28)
end
-- Manually edited files with the following changes. Double the dimensions for hr_version.
-- 1. Cut out rectangle at {{0,82}, {128,128}}
-- 2. Cut out rectangle at {{512,0}, {640,54}}
rail_north.pictures.rail_endings.sheets[1].filename = "__rail-bridge__/graphics/rail-endings-background.png"
rail_north.pictures.rail_endings.sheets[1].hr_version.filename = "__rail-bridge__/graphics/hr-rail-endings-background.png"
rail_north.pictures.rail_endings.sheets[2].filename = "__rail-bridge__/graphics/rail-endings-metals.png"
rail_north.pictures.rail_endings.sheets[2].hr_version.filename = "__rail-bridge__/graphics/hr-rail-endings-metals.png"
data:extend{rail_north}

-- Rail for diagonal left bridge
local rail_1 = table.deepcopy(rail_east);
rail_1.name = "rail-bridge-rail-1"
rail_1.localised_name = {"entity-name.rail-bridge-diagonal-left"}
rail_1.collision_box = {{-0.1, -0.99}, {0.1, 0.1}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_1.pictures.straight_rail_diagonal_right_bottom[layer], 2)
  cut_off_bottom(rail_1.pictures.straight_rail_diagonal_right_bottom[layer].hr_version, 4)
end
data:extend{rail_1}

-- Rail for diagonal left bridge
local rail_2 = table.deepcopy(rail_east);
rail_2.name = "rail-bridge-rail-2"
rail_2.localised_name = {"entity-name.rail-bridge-diagonal-left"}
rail_2.collision_box = {{-0.1, -0.1}, {0.1, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_2.pictures.straight_rail_diagonal_left_top[layer], -30)
  cut_off_bottom(rail_2.pictures.straight_rail_diagonal_left_top[layer].hr_version, -60)
end
data:extend{rail_2}

-- Rail for diagonal right bridge
local rail_3 = table.deepcopy(rail_east)
rail_3.name = "rail-bridge-rail-3"
rail_3.localised_name = {"entity-name.rail-bridge-diagonal-right"}
rail_3.collision_box = {{-0.1, -0.99}, {0.1, 0.1}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_3.pictures.straight_rail_diagonal_left_bottom[layer], 2)
  cut_off_bottom(rail_3.pictures.straight_rail_diagonal_left_bottom[layer].hr_version, 4)
end
data:extend{rail_3}

-- Rail for diagonal right bridge
local rail_4 = table.deepcopy(rail_east)
rail_4.name = "rail-bridge-rail-4"
rail_4.localised_name = {"entity-name.rail-bridge-diagonal-right"}
rail_4.collision_box = {{-0.1, -0.1}, {0.1, 0.99}}
for _, layer in pairs{"stone_path_background", "stone_path", "ties", "backplates", "metals"} do
  cut_off_bottom(rail_4.pictures.straight_rail_diagonal_right_top[layer], -30)
  cut_off_bottom(rail_4.pictures.straight_rail_diagonal_right_top[layer].hr_version, -60)
end
data:extend{rail_4}

-- Up/down bridge entity
local bridge = {
  type = "simple-entity-with-force",
  name = "rail-bridge",
  icon = "__rail-bridge__/graphics/icon.png",
  icon_size = 32,
  subgroup = "transport",
  order = "a[train-system]-a[rail]-b[bridge]",
  flags = {"placeable-neutral", "player-creation"},
  collision_mask = {"item-layer", "object-layer", "water-tile"},
  collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
  selection_box = {{-1, -1}, {1, 1}},
  minable = {mining_time = 0.5, result = "rail-bridge"},
  max_health = 300,
  resistances = table.deepcopy(rail_east.resistances),
  corpse = "straight-rail-remnants",
  render_layer = "lower-object",
  picture = {layers = {}},
}
for _, layer in pairs{"stone_path_background", "stone_path", "ties"} do
  table.insert(bridge.picture.layers, table.deepcopy(rail_north.pictures.straight_rail_vertical[layer]))
  table.insert(bridge.picture.layers, table.deepcopy(rail_east.pictures.straight_rail_horizontal[layer]))
end
table.insert(bridge.picture.layers, {
  filename = "__rail-bridge__/graphics/bridge.png",
  width = 72,
  height = 32,
  shift = util.by_pixel(0, 34),
  hr_version = {
    filename = "__rail-bridge__/graphics/hr-bridge.png",
    width = 144,
    height = 64,
    shift = util.by_pixel(0, 34),
    scale = 0.5,
  }
})
for _, layer in pairs{"backplates", "metals"} do
  table.insert(bridge.picture.layers, table.deepcopy(rail_north.pictures.straight_rail_vertical[layer]))
  table.insert(bridge.picture.layers, table.deepcopy(rail_east.pictures.straight_rail_horizontal[layer]))
end
data:extend{bridge}

-- Test turret


-- Diagonal left bridge entity
local diag_left = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"]);
diag_left.name = "rail-bridge-diagonal-left"
diag_left.icon = "__rail-bridge__/graphics/icon.png"
diag_left.icon_size = 32
diag_left.subgroup = "transport"
diag_left.order = "a[train-system]-a[rail]-b[diagonal-bridge]"
diag_left.flags = {"placeable-neutral", "player-creation", "hide-alt-info"}
diag_left.fast_replaceable_group = nil
diag_left.collision_mask = {"item-layer", "object-layer", "water-tile"}
diag_left.collision_box = {{-0.55, -1.55}, {0.55, 1.55}}
diag_left.selection_box = {{-1, -2}, {1, 2}}
diag_left.minable = { mining_time = 0.5, result = "rail-bridge-diagonal-left" }
diag_left.max_health = 300
diag_left.corpse = "straight-rail-remnants"
diag_left.item_slot_count = 0
diag_left.circuit_wire_max_distance = 0
diag_left.activity_led_light_offsets = {{0,0}, {0,0}, {0,0}, {0,0}}
diag_left.activity_led_sprites = {}
for _, direction in pairs{"north", "east", "south", "west"} do
  diag_left.sprites[direction] = {layers = {}}
  diag_left.activity_led_sprites[direction] = {
    filename = "__core__/graphics/empty.png",
    width = 1,
    height = 1,
  }
end
for _, layer in pairs{"stone_path_background", "stone_path", "ties"} do
  for _, direction in pairs{"north", "south"} do
    table.insert(diag_left.asprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_vertical[layer], {0, -1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_vertical[layer], {0, 1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_left_bottom[layer], {0, -1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_right_top[layer], {0, 1}))
  end
  for _, direction in pairs{"east", "west"} do
    table.insert(diag_left.activity_led_sprites[direction].layers, {
      filename = "__rail-bridge__/graphics/constant-combinator-LED-E.png",
      height = 8,
      width = 8,
      frame_count = 1,
      shift = {0, 0},
      hr_version = {
        filename = "__rail-bridge__/graphics/hr-constant-combinator-LED-E.png",
        width = 14,
        height = 14,
        frame_count = 1,
        shift = {0, 0},
        scale = 0.5,
      },
    })
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_right_bottom[layer], {-1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_diagonal_left_top[layer], {1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_horizontal[layer], {-1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_horizontal[layer], {1, 0}))
  end
end
for _, direction in pairs{"north", "east", "south", "west"} do
  if direction == "north" or direction == "south" then
    table.insert(diag_left.sprites[direction].layers, {
      filename = "__rail-bridge__/graphics/bridge.png",
      width = 72,
      height = 32,
      shift = util.by_pixel(0, 34),
      hr_version = {
        filename = "__rail-bridge__/graphics/hr-bridge.png",
        width = 144,
        height = 64,
        shift = util.by_pixel(0, 34),
        scale = 0.5,
      }
    })
  else
    table.insert(diag_left.sprites[direction].layers, {
      filename = "__rail-bridge__/graphics/bridge-sw.png",
      width = 72,
      height = 32,
      shift = util.by_pixel(-32, 34),
      hr_version = {
        filename = "__rail-bridge__/graphics/hr-bridge-sw.png",
        width = 144,
        height = 64,
        shift = util.by_pixel(-32, 34),
        scale = 0.5,
      }
    })
  end
end
for _, layer in pairs{"backplates", "metals"} do
  for _, direction in pairs{"north", "south"} do
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_vertical[layer], {0, -1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_vertical[layer], {0, 1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_left_bottom[layer], {0, -1}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_right_top[layer], {0, 1}))
  end
  for _, direction in pairs{"east", "west"} do
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_diagonal_right_bottom[layer], {-1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_2.pictures.straight_rail_diagonal_left_top[layer], {1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_horizontal[layer], {-1, 0}))
    table.insert(diag_left.sprites[direction].layers, copy_and_shift(rail_1.pictures.straight_rail_horizontal[layer], {1, 0}))
  end
end
data:extend{diag_left}

-- Diagonal right bridge entity
local diag_right = table.deepcopy(diag_left)
diag_right.name = "rail-bridge-diagonal-right"
diag_right.icon = "__rail-bridge__/graphics/icon.png"
diag_right.minable.result = "rail-bridge-diagonal-right"
for _, direction in pairs{"north", "east", "south", "west"} do
  diag_right.sprites[direction] = {layers = {}}
end
for _, layer in pairs{"stone_path_background", "stone_path", "ties"} do
  for _, direction in pairs{"north", "south"} do
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_vertical[layer], {0, -1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_vertical[layer], {0, 1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_right_bottom[layer], {0, -1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_left_top[layer], {0, 1}))
  end
  for _, direction in pairs{"east", "west"} do
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_diagonal_right_top[layer], {-1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_left_bottom[layer], {1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_horizontal[layer], {-1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_horizontal[layer], {1, 0}))
  end
end
for _, direction in pairs{"north", "east", "south", "west"} do
  if direction == "north" or direction == "south" then
    table.insert(diag_right.sprites[direction].layers, {
      filename = "__rail-bridge__/graphics/bridge.png",
      width = 72,
      height = 32,
      shift = util.by_pixel(0, 34),
      hr_version = {
        filename = "__rail-bridge__/graphics/hr-bridge.png",
        width = 144,
        height = 64,
        shift = util.by_pixel(0, 34),
        scale = 0.5,
      }
    })
  else
    table.insert(diag_right.sprites[direction].layers, {
      filename = "__rail-bridge__/graphics/bridge-se.png",
      width = 72,
      height = 32,
      shift = util.by_pixel(32, 34),
      hr_version = {
        filename = "__rail-bridge__/graphics/hr-bridge-se.png",
        width = 144,
        height = 64,
        shift = util.by_pixel(32, 34),
        scale = 0.5,
      }
    })
  end
end
for _, layer in pairs{"backplates", "metals"} do
  for _, direction in pairs{"north", "south"} do
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_vertical[layer], {0, -1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_vertical[layer], {0, 1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_right_bottom[layer], {0, -1}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_left_top[layer], {0, 1}))
  end
  for _, direction in pairs{"east", "west"} do
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_4.pictures.straight_rail_diagonal_right_top[layer], {-1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_diagonal_left_bottom[layer], {1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_horizontal[layer], {-1, 0}))
    table.insert(diag_right.sprites[direction].layers, copy_and_shift(rail_3.pictures.straight_rail_horizontal[layer], {1, 0}))
  end
end
data:extend{diag_right};

-- Items
data:extend {
  {
    type = "item",
    name = bridge.name,
    place_result = bridge.name,
    icon = bridge.icon,
    subgroup = bridge.subgroup,
    icon_size = bridge.icon_size,
    order = bridge.order,
    flags = {},
    stack_size = 10,
  },
  {
    type = "item",
    name = diag_left.name,
    place_result = diag_left.name,
    icon = diag_left.icon,
    subgroup = diag_left.subgroup,
    icon_size = diag_left.icon_size,
    order = diag_left.order,
    flags = {},
    stack_size = 10,
  },
  {
    type = "item",
    name = diag_right.name,
    place_result = diag_right.name,
    icon = diag_right.icon,
    subgroup = diag_right.subgroup,
    icon_size = diag_right.icon_size,
    order = diag_right.order,
    flags = {},
    stack_size = 10,
  },
}

-- Recipes
data:extend{
  {
    type = "recipe",
    name = "rail-bridge",
    result = "rail-bridge",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {"concrete", 100},
      {"steel-plate", 20},
      {"rail", 2},
    },
  },
  {
    type = "recipe",
    name = "rail-bridge-diagonal-left",
    result = "rail-bridge-diagonal-left",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {"concrete", 100},
      {"steel-plate", 20},
      {"rail", 4},
    },
  },
  {
    type = "recipe",
    name = "rail-bridge-diagonal-right",
    result = "rail-bridge-diagonal-right",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {"concrete", 100},
      {"steel-plate", 20},
      {"rail", 4},
    },
  },
}

-- Recipes are unlocked with Logistics 3
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge",
})
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge-diagonal-left",
})
table.insert(data.raw.technology["logistics-3"].effects, {
  type = "unlock-recipe",
  recipe = "rail-bridge-diagonal-right",
})
