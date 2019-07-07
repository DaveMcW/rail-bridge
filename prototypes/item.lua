data:extend {
  {
    -- Rail bridge
    type = "item",
    name = "rail-bridge",
    localised_name = {"entity-name.rail-bridge"},
    place_result = "rail-bridge-preview",
    icon = "__rail-bridge__/graphics/icon.png",
    icon_size = 32,
    subgroup = "transport",
    order = "a[train-system]-a[rail]-b[bridge]",
    flags = {},
    stack_size = 10,
  },
  {
    -- Rail bridge diagonal left
    type = "item",
    name = "rail-bridge-diagonal-left",
    localised_name = {"entity-name.rail-bridge-diagonal-left"},
    place_result = "rail-bridge-diagonal-left-preview",
    icon = "__rail-bridge__/graphics/icon-left.png",
    icon_size = 32,
    subgroup = "transport",
    order = "a[train-system]-a[rail]-b[bridge]",
    flags = {},
    stack_size = 10,
  },
  {
    -- Rail bridge diagonal right
    type = "item",
    name = "rail-bridge-diagonal-right",
    localised_name = {"entity-name.rail-bridge-diagonal-right"},
    place_result = "rail-bridge-diagonal-right-preview",
    icon = "__rail-bridge__/graphics/icon-right.png",
    icon_size = 32,
    subgroup = "transport",
    order = "a[train-system]-a[rail]-b[bridge]",
    flags = {},
    stack_size = 10,
  },
  {
    -- Fake item for creating blueprints
    type = "item",
    name = "rail-bridge-preview",
    localised_name = {"entity-name.rail-bridge"},
    place_result = "rail-bridge",
    icon = "__rail-bridge__/graphics/icon.png",
    icon_size = 32,
    flags = {},
    stack_size = 10,
  },
  {
    -- Fake item for creating blueprints
    type = "item",
    name = "rail-bridge-diagonal-left-preview",
    localised_name = {"entity-name.rail-bridge-diagonal-left"},
    place_result = "rail-bridge-diagonal-left",
    icon = "__rail-bridge__/graphics/icon-left.png",
    icon_size = 32,
    flags = {"hidden"},
    stack_size = 10,
  },
  {
    -- Fake item for creating blueprints
    type = "item",
    name = "rail-bridge-diagonal-right-preview",
    localised_name = {"entity-name.rail-bridge-diagonal-right"},
    place_result = "rail-bridge-diagonal-right",
    icon = "__rail-bridge__/graphics/icon-right.png",
    icon_size = 32,
    flags = {"hidden"},
    stack_size = 10,
  },
}
