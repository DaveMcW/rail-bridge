local MY_BRIDGES = {
  ["rail-bridge"] = true,
  ["rail-bridge-diagonal-left"] = true,
  ["rail-bridge-diagonal-right"] = true,
--  ["rail-bridge-diagonal-left-preview"] = true,
--  ["rail-bridge-diagonal-right-preview"] = true,
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

function on_configuration_changed(event)
  on_init()
  local changes = event.mod_changes["rail-bridge"]
  if not changes then return end

  -- Move bridge sprite to the rendering system
  if changes.old_version < "0.0.3" and changes.new_version >= "0.0.3" then
    for _, surface in pairs(game.surfaces) do
      for _, bridge in pairs(surface.find_entities_filtered{name = {
        "rail-bridge",
        "rail-bridge-diagonal-left",
        "rail-bridge-diagonal-right",
      }}) do
        draw_sprite(bridge)
      end
    end
  end
end

function on_built(event)
  local entity = event.created_entity or event.entity or event.destination
  if not entity or not entity.valid then return end
  if not MY_BRIDGES[entity.name] then return end

  -- Align to rail grid
  local mod_x = 0
  local mod_y = 0
  if entity.name == "rail-bridge-diagonal-left"
  or entity.name == "rail-bridge-diagonal-left-preview"
  or entity.name == "rail-bridge-diagonal-right"
  or entity.name == "rail-bridge-diagonal-right-preview" then
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
    if entity.name == "rail-bridge" and MY_RAILS[rail] and rail.direction % 2 == 1 then
      -- Straight bridge can't remove diagonal rails
    else
      refund_entity(rail, event)
    end
  end

  -- Replace preview
  if entity.name == "rail-bridge-preview"
  or entity.name == "rail-bridge-diagonal-left-preview"
  or entity.name == "rail-bridge-diagonal-right-preview" then
    local surface = entity.surface
    local data = {
      name = entity.name:sub(1, -9),
      position = entity.position,
      direction = entity.direction,
      force = entity.force,
      create_build_effect_smoke = false,
    }
    entity.destroy()
    entity = surface.create_entity(data)
  end

  -- Turn off constant combinator
  if entity.type == "constant-combinator" then
    entity.get_or_create_control_behavior().enabled = false
  end

  -- Create bridge sprite
  draw_sprite(entity)

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
      create_rail("rail-bridge-rail-4", entity, defines.direction.northeast, {-1, 0})
      create_rail("rail-bridge-rail-3", entity, defines.direction.southwest, {1, 0})
    end
  end
end

function on_entity_cloned(event)
  local entity = event.destination
  if not entity or not entity.valid then return end
  if MY_BRIDGES[entity.name] then
    -- Continue in on_built
    on_built({entity=entity, name=event.name})
  elseif MY_RAILS[entity.name] then
    -- Don't let other mods clone our custom rails
    entity.destroy()
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
      if entity.name == "rail-bridge" and rail.direction % 2 == 1 then
        -- Straight bridge can't remove diagonal rails
      else
        rail.destroy()
      end
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

-- function on_player_pipette(event)
--   -- Replace fake preview item with a real item
--   if event.item.name == "rail-bridge-preview"
--   or event.item.name == "rail-bridge-diagonal-left-preview"
--   or event.item.name == "rail-bridge-diagonal-right-preview" then
--     local player = game.players[event.player_index]
--     local item = game.item_prototypes[event.item.name:sub(1, -9)]
--     local cursor_stack = player.cursor_stack.valid_for_read and player.cursor_stack
--     if cursor_stack then
--       if cursor_stack.name == event.item.name then
--         set_cursor(player, item)
--       end
--     elseif player.cursor_ghost and player.cursor_ghost.name == event.item.name then
--       set_cursor(player, item)
--     end
--   end
-- end

-- function on_blueprint_created(event)
--   -- Get the blueprint
--   local player = game.players[event.player_index]
--   local blueprint = player.cursor_stack
--   if not blueprint.valid_for_read then return end
--   if blueprint.is_blueprint_book then
--     local inventory = blueprint.get_inventory(defines.inventory.item_main)
--     blueprint = inventory[blueprint.active_index]
--   end
--   if not blueprint.is_blueprint then return end
--   if not blueprint.is_blueprint_setup() then return end
--
--   -- Add preview items to the blueprint
--   local entities = blueprint.get_blueprint_entities()
--   for _, entity in pairs(entities) do
--     if entity.name == "rail-bridge-diagonal-left"
--     or entity.name == "rail-bridge-diagonal-right" then
--       entity.name = entity.name .. "-preview"
--     end
--   end
--   blueprint.set_blueprint_entities(entities)
-- end

function create_rail(name, bridge, direction, position)
  -- Create one of our custom rails
  if not position then position = {0, 0} end
  local rail = bridge.surface.create_entity{
    name = name,
    direction = direction,
    force = bridge.force,
    position = {bridge.position.x + position[1], bridge.position.y + position[2]},
    create_build_effect_smoke = false,
  }
  if rail then rail.destructible = false end
end

function area_under(entity)
  -- Calculate the absolute position of the entity's collision box
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

function draw_sprite(bridge)
  -- Get sprite name
  local sprite = nil
  if bridge.name == "rail-bridge" then
    sprite = "rail-bridge"
  elseif bridge.name == "rail-bridge-diagonal-left" then
    if bridge.direction % 4 == defines.direction.north then
      sprite = "rail-bridge-ne"
    else
      sprite = "rail-bridge-sw"
    end
  elseif bridge.name == "rail-bridge-diagonal-right" then
    if bridge.direction % 4 == defines.direction.north then
      sprite = "rail-bridge-nw"
    else
      sprite = "rail-bridge-se"
    end
  end

  -- Draw sprite
  if sprite then
    rendering.draw_sprite{
      sprite = sprite,
      surface = bridge.surface,
      target = bridge,
      render_layer = "transport-belt",
    }
  end
end

function set_cursor(player, item)
  local count = math.min(player.get_main_inventory().get_item_count(item.name), item.stack_size)
  if count > 0 then
    -- Use existing items
    player.remove_item{name = item.name, count = count}
    player.cursor_stack.set_stack{name = item.name, count = count}
  elseif player.cheat_mode then
    -- Cheat for some items
    player.cursor_stack.set_stack{name = item.name, count = item.stack_size}
  else
    -- Use an item ghost
    player.cursor_stack.clear()
    player.cursor_ghost = item
  end
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_entity_cloned, on_entity_cloned)
script.on_event(defines.events.on_player_mined_entity, on_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)
script.on_event(defines.events.on_gui_opened, on_gui_opened)
--script.on_event(defines.events.on_player_pipette, on_player_pipette)
--script.on_event(defines.events.on_player_setup_blueprint, on_blueprint_created)
--script.on_event(defines.events.on_player_configured_blueprint, on_blueprint_created)
