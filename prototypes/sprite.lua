data:extend{
  {
    -- Underpass for straight bridge
    type = "sprite",
    name = "rail-bridge",
    filename = "__rail-bridge__/graphics/bridge.png",
    width = 72,
    height = 32,
    shift = util.by_pixel(0, 34),
    hr_version = {
      filename = "__rail-bridge__/graphics/hr_bridge.png",
      width = 144,
      height = 64,
      shift = util.by_pixel(0, 34),
      scale = 0.5,
    }
  },
  {
    -- Underpass for diagonal left bridge
    type = "sprite",
    name = "rail-bridge-ne",
    filename = "__rail-bridge__/graphics/bridge_ne.png",
    width = 72,
    height = 72,
    shift = {0, 1.4375},
    hr_version = {
      filename = "__rail-bridge__/graphics/hr_bridge_ne.png",
      width = 144,
      height = 144,
      shift = {0, 1.4375},
      scale = 0.5,
    }
  },
  {
    -- Underpass for diagonal left bridge
    type = "sprite",
    name = "rail-bridge-sw",
    filename = "__rail-bridge__/graphics/bridge_sw.png",
    width = 72,
    height = 32,
    shift = {-1, 1.0625},
    hr_version = {
      filename = "__rail-bridge__/graphics/hr_bridge_sw.png",
      width = 144,
      height = 64,
      shift = {-1, 1.0625},
      scale = 0.5,
    }
  },
  {
    -- Underpass for diagonal right bridge
    type = "sprite",
    name = "rail-bridge-nw",
    filename = "__rail-bridge__/graphics/bridge_nw.png",
    width = 72,
    height = 72,
    shift = {0, 1.4375},
    hr_version = {
      filename = "__rail-bridge__/graphics/hr_bridge_nw.png",
      width = 144,
      height = 144,
      shift = {0, 1.4375},
      scale = 0.5,
    }
  },
  {
    -- Underpass for diagonal right bridge
    type = "sprite",
    name = "rail-bridge-se",
    filename = "__rail-bridge__/graphics/bridge_se.png",
    width = 72,
    height = 32,
    shift = {1, 1.0625},
    hr_version = {
      filename = "__rail-bridge__/graphics/hr_bridge_se.png",
      width = 144,
      height = 64,
      shift = {1, 1.0625},
      scale = 0.5,
    }
  },
}
