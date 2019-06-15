function on_init()
  -- Unlock recipe
  for _, force in pairs(game.forces) do
    if force.technologies["logistics-3"].researched then
      force.recipes["rail-bridge"].enabled = true
    end
  end
end

function on_built(event)
  local entity = event.created_entity or event.entity
  if not entity or not entity.valid then return end
  if entity.name == "rail-bridge" then
    -- Align to rail grid
    local x = entity.position.x
    local y = entity.position.y
    if x % 2 == 0 then x = x - 1 end
    if y % 2 == 0 then y = y - 1 end
    if entity.position.x ~= x or entity.position.y ~= y then
      entity.teleport{x, y}
    end

    -- Create rail crossing
    entity.surface.create_entity{
      name = "rail-bridge-north",
      direction = defines.direction.north,
      force = entity.force,
      position = entity.position,
    }
    entity.surface.create_entity{
      name = "rail-bridge-east",
      direction = defines.direction.east,
      force = entity.force,
      position = entity.position,
    }
  end
end

function on_destroyed(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name == "rail-bridge" then
    -- Remove rail crossing
    local p = entity.position
    for _, rail in pairs(entity.surface.find_entities_filtered {
      type = "straight-rail",
      area = {{p.x - 1, p.y - 1}, {p.x + 1, p.y + 1}},
    }) do
      rail.destroy()
    end
  end
end

script.on_init(on_init)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_entity_cloned, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)
