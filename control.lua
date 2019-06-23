local MY_BRIDGES = {
  ["rail-bridge-test"] = true,
  ["rail-bridge"] = true,
  ["rail-bridge-diagonal-left"] = true,
  ["rail-bridge-diagonal-right"] = true,
}
local MY_RAILS = {
  ["rail-bridge-north"] = true,
  ["rail-bridge-east"] = true,
  ["rail-bridge-rail-1"] = true,
  ["rail-bridge-rail-2"] = true,
  ["rail-bridge-rail-3"] = true,
  ["rail-bridge-rail-4"] = true,
}

function on_init()
  -- Unlock recipe
  for _, force in pairs(game.forces) do
    if force.technologies["logistics-3"].researched then
      force.recipes["rail-bridge"].enabled = true
      force.recipes["rail-bridge-diagonal-left"].enabled = true
      force.recipes["rail-bridge-diagonal-right"].enabled = true
    end
  end
end

function on_built(event)
  local entity = event.created_entity or event.entity
  if not entity or not entity.valid then return end
  if not MY_BRIDGES[entity.name] then return end

  -- Align to rail grid
  local mod_x = 0
  local mod_y = 0
  if entity.name == "rail-bridge-diagonal-left" or entity.name == "rail-bridge-diagonal-right" then
    if entity.direction % 4 == defines.direction.north then
      mod_x = 0
      mod_y = 1
    else
      mod_x = 1
      mod_y = 0
    end
  end
  local x = entity.position.x
  local y = entity.position.y
  if x % 2 == mod_x then x = x - 1 end
  if y % 2 == mod_y then y = y - 1 end
  if entity.position.x ~= x or entity.position.y ~= y then
    entity.teleport{x, y}
  end

  -- Check collisions
  local delete_rails = {}
  for _, obstacle in pairs(entity.surface.find_entities_filtered{
    type = {"straight-rail", "entity-ghost"},
    area = area_under(entity),
  }) do
    if obstacle.type == "straight-rail"
    and not MY_RAILS[obstacle.name]
    and obstacle.force == entity.force
    and obstacle.can_be_destroyed() then
      table.insert(delete_rails, obstacle)
    elseif obstacle.type == "entity-ghost"
    and obstacle.ghost_type == "straight-rail" then
      table.insert(delete_rails, obstacle)
    else
      -- Obstacle can't be destroyed, abort the build!
      refund_entity(entity, event, obstacle)
      return
    end
  end

  -- Destroy rails in the area
  for _, rail in pairs(delete_rails) do
    if not MY_RAILS[rail.name] then
      refund_entity(rail, event)
    end
  end

  -- Create crossing rails
  if entity.name == "rail-bridge" then
    create_rail("rail-bridge-north", entity, defines.direction.north)
    create_rail("rail-bridge-east", entity, defines.direction.east)

  elseif entity.name == "rail-bridge-diagonal-left" then
    if entity.direction % 4 == defines.direction.north then
      create_rail("rail-bridge-rail-1", entity, defines.direction.north, {0, -1})
      create_rail("rail-bridge-rail-2", entity, defines.direction.north, {0, 1})
      create_rail("rail-bridge-rail-1", entity, defines.direction.southwest, {0, -1})
      create_rail("rail-bridge-rail-2", entity, defines.direction.northeast, {0, 1})
    else
      create_rail("rail-bridge-rail-1", entity, defines.direction.east, {-1, 0})
      create_rail("rail-bridge-rail-2", entity, defines.direction.east, {1, 0})
      create_rail("rail-bridge-rail-1", entity, defines.direction.southeast, {-1, 0})
      create_rail("rail-bridge-rail-2", entity, defines.direction.northwest, {1, 0})
    end

  elseif entity.name == "rail-bridge-diagonal-right" then
    if entity.direction % 4 == defines.direction.north then
      create_rail("rail-bridge-rail-3", entity, defines.direction.north, {0, -1})
      create_rail("rail-bridge-rail-4", entity, defines.direction.north, {0, 1})
      create_rail("rail-bridge-rail-3", entity, defines.direction.southeast, {0, -1})
      create_rail("rail-bridge-rail-4", entity, defines.direction.northwest, {0, 1})
    else
      create_rail("rail-bridge-rail-4", entity, defines.direction.east, {-1, 0})
      create_rail("rail-bridge-rail-3", entity, defines.direction.east, {1, 0})
      create_rail("rail-bridge-rail-3", entity, defines.direction.northeast, {-1, 0})
      create_rail("rail-bridge-rail-4", entity, defines.direction.southwest, {1, 0})
    end
  end
end

function on_destroyed(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not MY_BRIDGES[entity.name] then return end

  -- Remove crossing rails
  for _, rail in pairs(entity.surface.find_entities_filtered {
    type = "straight-rail",
    area = area_under(entity),
    force = entity.force,
  }) do
    if MY_RAILS[rail.name] then
      rail.destroy()
    end
  end
end

function on_gui_opened(event)
  -- Disable bridge gui
  local entity = event.entity
  if not entity or not entity.valid then return end
  if MY_BRIDGES[event.entity.name] then
    game.players[event.player_index].opened = nil
  end
end

function create_rail(name, bridge, direction, position)
  if not position then position = {0, 0} end
  local rail = bridge.surface.create_entity{
    name = name,
    direction = direction,
    force = bridge.force,
    position = {bridge.position.x + position[1], bridge.position.y + position[2]},
  }
  if rail then rail.destructible = false end
end

function area_under(entity)
  local p = entity.position
  local box = entity.prototype.collision_box
  local dx = (box.right_bottom.x - box.left_top.x) / 2
  local dy = (box.right_bottom.y - box.left_top.y) / 2
  if entity.direction and entity.direction % 4 ~= defines.direction.north then
    dx, dy = dy, dx
  end
  return {{p.x - dx, p.y - dy}, {p.x + dx, p.y + dy}}
end

function refund_entity(entity, build_event, colliding_entity)
  -- Show alert
  local player = nil
  if build_event and build_event.player_index then
    player = game.players[build_event.player_index]
  end
  if player and colliding_entity then
    entity.surface.create_entity{
      name = "flying-text",
      text = {"cant-build-reason.entity-in-the-way", colliding_entity.localised_name},
      position = entity.position,
      render_player_index = build_event.player_index,
    }
  end

  if entity.prototype.items_to_place_this then
    -- Find the item used to place the entity
    local item_count = 0
    local item_name = nil
    if build_event and build_event.stack and build_event.stack.valid_for_read then
      item_name = build_event.stack.name
    end
    for _, item in pairs(entity.prototype.items_to_place_this) do
      if item_name == item.name then
        item_count = item.count
        break
      end
    end
    if item_count == 0 then
      local item = entity.prototype.items_to_place_this[1]
      if item then
        item_name = item.name
        item_count = item.count
      end
    end
    local health = entity.health / entity.prototype.max_health

    -- Return item to player inventory
    if item_count > 0 and player then
      local result = player.insert{name=item_name, count=item_count, health=health}
      item_count = item_count - result
    end

    -- Return item to ground
    if item_count > 0 then
      entity.surface.spill_item_stack(entity.position, {name=item_name, count=item_count, health=health}, false, entity.force, false)
    end
  end

  -- Destroy entity
  entity.destroy{raise_destroy = true}
end

script.on_init(on_init)
script.on_configuration_changed(on_init)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_entity_cloned, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
