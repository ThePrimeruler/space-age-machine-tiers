local util = require("util")
local get_constants = require('lib.constants')


local utils = {}




utils.debug = false


utils.mod_name = "space-age-machine-tiers"
utils.mod_path = "__"..utils.mod_name.."__"

utils.log = utils.debug and log or function(_) end
utils.error = function(input) log('[Error]['..utils.mod_name..']'..input) end
utils.warning = function(input) log('[Warning]['..utils.mod_name..']'..input) end
utils.info = function(input) log('[Info]['..utils.mod_name..']'..input) end
utils.debug = utils.debug and function(input) log('[Debug]['..utils.mod_name..']'..input) end or function(_) end


if not settings then
    return utils
end

---@type boolean 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_use_tints = settings.startup[utils.mod_name.."-use-tints"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_recipe_cost_mult = settings.startup[utils.mod_name.."-recipe-cost-multiplier"].value



---@type boolean 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_do_space_platform_tiers = settings.startup[utils.mod_name.."-do-space-platform-tiers"].value
---@type boolean 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_do_military_tiers = settings.startup[utils.mod_name.."-do-military-tiers"].value



---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_speed_mult = settings.startup[utils.mod_name.."-speed-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_energy_mult = settings.startup[utils.mod_name.."-energy-usage-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_pollution_mult = settings.startup[utils.mod_name.."-pollution-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_health_mult = settings.startup[utils.mod_name.."-health-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_range_mult = settings.startup[utils.mod_name.."-range-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_tank_mult = settings.startup[utils.mod_name.."-tank-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_storage_mult = settings.startup[utils.mod_name.."-storage-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_beacon_dist_mult = settings.startup[utils.mod_name.."-beacon-distribution-multiplier-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_thruster_performance_mult = settings.startup[utils.mod_name.."-thruster-performance-per-tier"].value
---@type number float 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_damage_mult = settings.startup[utils.mod_name.."-damage-multiplier-per-tier"].value





---@type number integer 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_module_mod = settings.startup[utils.mod_name.."-module-slots-per-tier"].value
---@type number integer 
---@diagnostic disable-next-line: assign-type-mismatch
utils.setting_agg_radius_mod = settings.startup[utils.mod_name.."-agg-radius-per-tier"].value


if mods["boblogistics"] then
    if settings.startup[utils.mod_name.."-fix-bob-turbo-belts"].value then
        utils.fix_bob_turbo_belts = true
    end
end

if mods["Age-of-Production"] then
    if settings.startup[utils.mod_name.."-add-aop-machines"].value then
        utils.do_aop = true
    end
end
if mods["lignumis"] then
    if settings.startup[utils.mod_name.."-add-lignumis-machines"].value then
        utils.do_lignumis = true
    end
end
if mods["planet-muluna"] then
    if settings.startup[utils.mod_name.."-add-muluna-machines"].value then
        utils.do_muluna = true
    end
end

if mods["maraxsis"] then
    if settings.startup[utils.mod_name.."-add-maraxsis-machines"].value then
        utils.do_maraxsis = true
    end
end




function utils.table_remove_by_value(the_table,value)
    for i = #the_table, 1, -1 do
        if the_table[i] == value then
            table.remove(the_table, i)
        end
    end
end

function utils.list_contains(the_list,value)
    for _, list_item in ipairs(the_list) do
        if list_item == value then
            return true
        end
    end
    return false
end




-- TODO: planet-muluna: consider options ...




-- Pull Constants And Load Them Into Utils
get_constants(utils)





function utils.luaSerializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep("    ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. utils.luaSerializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[unserializable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function utils.jsonSerializeTable(val, name, depth)
    local indent = '    '
    depth = depth or 0

    local tmp = string.rep(indent, depth)

    if name then tmp = tmp .. '"' .. name .. '": ' end

    if type(val) == "table" then
        tmp = tmp .. "{" .. "\n"
        local add_comma = false
        for k, v in pairs(val) do
            if add_comma then
                tmp = tmp .. "," .. (not skipnewlines and "\n" or "")
            else
                add_comma = true
            end
            tmp =  tmp .. utils.jsonSerializeTable(v, k, depth + 1)
        end
        tmp = tmp .. (not skipnewlines and "\n" or "")

        tmp = tmp .. string.rep(indent, depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[unserializable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

---@param level number integer
---@param multiplier number float
function utils.get_level_multiplier_delta(level, multiplier)
    return multiplier ^ (level-1)
end

---@param level number integer
---@param delta number float
function utils.get_level_linear_delta(level, delta)
    return delta * (level-1)
end

---@param input string string like "10kW"
---@param multiplier number float
function utils.multiply_with_unit(input, multiplier)
    -- Extract number and unit
    local value, unit = input:match("^(%d+%.?%d*)(%a+)$")
    if not value or not unit then
        error("Invalid format: expected something like '75kW'")
    end

    -- Convert value to number and multiply
    local result = tonumber(value) * multiplier

    -- Round to 3 decimal places
    result = math.floor(result * 1000 + 0.5) / 1000

    -- Remove trailing .0 if it's a whole number
    if result == math.floor(result) then
        result = math.floor(result)
    end

    return tostring(result) .. unit
end




---@param level number integer
---@param name string
function utils.get_machine_name(level, name)
    if level <= 1 and not utils.list_contains(utils.constants.added_machine_tier_1,name) then
        return tostring(name)
    end
    return utils.mod_name..'-'.. tostring(name) ..'-'..tostring(level)
end

---@param entity_name string
function utils.find_entity_by_name(entity_name) 
    -- look through our list and see if it's there
    for _, e_type in ipairs(utils.constants.entity_types) do
        if data.raw[e_type][entity_name] then
            return e_type, data.raw[e_type][entity_name]
        end
    end
    -- if that fails look through everything else
    local banned_types = {
        ['item']=true,
        ['recipe']=true,
        ['technology']=true,
    }
    for proto_type, proto_val in pairs(data.raw) do
        if banned_types[proto_type] then
            goto continue
        end
        if data.raw[proto_type][entity_name] then
            utils.warning('found entity through fallback method, type is '..proto_type)
            return proto_type, data.raw[proto_type][entity_name]
        end
        ::continue::
    end
    
    utils.error('did not find entity definition for '..tostring(entity_name))
    return '',{}
end




---@param level number integer
function utils.get_tint(level)
    -- Bob's Order: Yellow, Orange, Blue, Purple, Green
    if level == 2 then
        return {r=.8,g=.1,b=.8,a=1} -- kinda purple
    elseif level == 3 then
        return {r=.1,g=.9,b=.25,a=1} -- kinda green
    else
        error(utils.mod_name..': get_tint unknown level: '..level)
    end
end

local layers_to_tint = {
    big_drill = {
        graphics_set = {
            animation = {_0 = true,},
            working_visualisations = {_5=true,_10=true,},
        },
        wet_mining_graphics_set = {
            animation = {_0 = true,},
            working_visualisations = {_5=true,_10=true,},
        }
    },
    foundry = {
        graphics_set = {
            animation = {_1 = true,},
            working_visualisations = {_3=true,},
        }
    },
    recycler = {
        graphics_set = {
            animation = {_1 = true,},
        },
        graphics_set_flipped = {
            animation = {_1 = true,},
        }
    },
    electromagnetic_plant = {
        graphics_set = {
            idle_animation = {_1 = true,}
        }
    }
}

---@param entity table
---@param tint table
---@param entity_type string
function utils.add_tint_to_entity(entity, tint, entity_type)
    -- exit early if issues
    if not utils.setting_use_tints then
        utils.debug('not assigning tint to entity')
        return
    end
    if not entity then
        error(utils.mod_name..': No Entity')
    end
    local tint_settings = layers_to_tint[entity_type]
    if tint_settings == nil then
        utils.debug('add_tint_to_entity: '..entity_type..' does not have an entry in the layers_to_tint table')
        return
    end
    -- go through the graphics sets
    for graphics_set_key, graphics_set in pairs(tint_settings) do
        if not entity[graphics_set_key] then
            error(utils.mod_name..': add_tint_to_entity: graphics_set_key does not exist in entity: '..graphics_set_key)
        end

        -- go through the animation groups
        for animation_group_key, animation_group in pairs(graphics_set) do
            -- animation -> dir -> layers
            if animation_group_key == 'animation' then
                for _, direction in ipairs({'north','south','east','west'}) do
                    if entity[graphics_set_key][animation_group_key][direction] then
                        for i, layer in pairs(entity[graphics_set_key][animation_group_key][direction].layers) do
                            if animation_group['_'..i] then
                                utils.debug('adding tint to '..entity_type..': '..animation_group_key..': '..direction..': layer '..i)
                                entity[graphics_set_key][animation_group_key][direction].layers[i].tint = tint
                            end
                        end
                    end
                end
            elseif animation_group_key == 'working_visualisations' then
                for i, layer in pairs(entity[graphics_set_key][animation_group_key]) do
                    entity[graphics_set_key][animation_group_key][i].tint = tint
                    for _, direction in ipairs({'north_animation','south_animation','east_animation','west_animation'}) do
                        if entity[graphics_set_key][animation_group_key][i][direction] then
                            utils.debug('adding tint to '..entity_type..': '..animation_group_key..': layer '.. i ..': direction ' .. direction)
                            entity[graphics_set_key][animation_group_key][i][direction].tint = tint
                        end
                    end
                end
            elseif animation_group_key == 'idle_animation' then
                -- idle_animation -> layers
                for i, layer in pairs(entity[graphics_set_key][animation_group_key]) do
                    if animation_group['_'..i] then
                        utils.debug('adding tint to '..entity_type..': '..animation_group_key..': layer '.. i)
                        entity[graphics_set_key][animation_group_key]['layers'][i].tint = tint
                    end
                end
            else
                error('unknown animation group: ' .. animation_group_key)
            end
        end



    end
end


-- taken from the recycling mod

local function get_prototype(base_type, name)
  for type_name in pairs(defines.prototypes[base_type]) do
    local prototypes = data.raw[type_name]
    if prototypes and prototypes[name] then
      return prototypes[name]
    end
  end
end

function utils.get_item_localised_name(name)
  local item = get_prototype("item", name)
  if not item then return end
  if item.localised_name then
    return item.localised_name
  end
  local prototype
  local type_name = "item"
  if item.place_result then
    prototype = get_prototype("entity", item.place_result)
    type_name = "entity"
  elseif item.place_as_equipment_result then
    prototype = get_prototype("equipment", item.place_as_equipment_result)
    type_name = "equipment"
  elseif item.place_as_tile then
    -- Tiles with variations don't have a localised name
    local tile_prototype = data.raw.tile[item.place_as_tile.result]
    if tile_prototype and tile_prototype.localised_name then
      prototype = tile_prototype
      type_name = "tile"
    end
  end
  return prototype and prototype.localised_name or {type_name.."-name."..name}
end

function utils.get_item_localised_description(name)
  local item = get_prototype("item", name)
  if not item then return end
  if item.localised_description then
    return item.localised_description
  end
  local prototype
  local type_name = "item"
  if item.place_result then
    prototype = get_prototype("entity", item.place_result)
    type_name = "entity"
  elseif item.place_as_equipment_result then
    prototype = get_prototype("equipment", item.place_as_equipment_result)
    type_name = "equipment"
  elseif item.place_as_tile then
    -- Tiles with variations don't have a localised name
    local tile_prototype = data.raw.tile[item.place_as_tile.result]
    if tile_prototype and tile_prototype.localised_description then
      prototype = tile_prototype
      type_name = "tile"
    end
  end
  return prototype and prototype.localised_description or {type_name.."-description."..name}
end

local function generate_recycling_recipe_icons_from_item(item)
  local icons = {}
  if item.icons == nil then
    icons =
    {
      {
        icon = "__quality__/graphics/icons/recycling.png"
      },
      {
        icon = item.icon,
        icon_size = item.icon_size,
        scale = (0.5 * defines.default_icon_size / (item.icon_size or defines.default_icon_size)) * 0.8,
      },
      {
        icon = "__quality__/graphics/icons/recycling-top.png"
      },
    }
  else
    icons =
    {
      {
        icon = "__quality__/graphics/icons/recycling.png"
      }
    }
    for i = 1, #item.icons do
      local icon = table.deepcopy(item.icons[i]) -- we are gonna change the scale, so must copy the table
      icon.scale = ((icon.scale == nil) and (0.5 * defines.default_icon_size / (icon.icon_size or defines.default_icon_size)) or icon.scale) * 0.8
      icon.shift = util.mul_shift(icon.shift, 0.8)
      icons[#icons + 1] = icon
    end
    icons[#icons + 1] =
    {
      icon = "__quality__/graphics/icons/recycling-top.png"
    }
  end
  return icons
end

local function add_recipe_values(structure, input, result)
  local result_count
  local input_result = nil
  for k,v in pairs(util.normalize_recipe_products(input)) do
    if v.type == "item" then
      if input_result then return end -- more than one result item
      if v.amount_min == v.amount_max then
        input_result = v.name
        result_count = v.amount_min
      end
    end
  end

  if not input_result then return end

  if not result_count then
    error("Recycling recipe "..input.name.." has no result count.")
  end

  local result_item = get_prototype("item", input_result)
  if not result_item then return end
  if not input.ingredients then return end

  structure.results = {}
  structure.ingredients = {{type = "item", name = input_result, amount = 1}}

  local multiplier = result_count
  structure.energy_required = (input.energy_required or 0.5) / 16

  local result_crafting_tint = {primary = {0.5,0.5,0.5,0.5}, secondary = {0.5,0.5,0.5,0.5}, tertiary = {0.5,0.5,0.5,0.5}, quaternary = {0.5,0.5,0.5,0.5}}

  for k, ingredient in pairs(input.ingredients) do
    if type(ingredient) ~= "table" then
      error("Recipe "..input.name.." has malformed ingredients: it should only contain tables (one per ingredient) but "..type(ingredient).." was found")
    end

    if ingredient.type ~= "fluid" then
      local final_name = ingredient[1] or ingredient.name
      local final_amount = ingredient[2] or ingredient.amount
      local final_probability = 4 * multiplier * (ingredient.result_count or 1)

      local remainder = final_amount % final_probability
      final_amount = final_amount / final_probability
      local final_extra_fraction = remainder / final_probability

      table.insert(structure.results, {type = "item", name = final_name, amount = final_amount, extra_count_fraction = final_extra_fraction})

    elseif ingredient.type == "fluid" then
      local flow_color = data.raw.fluid[ingredient.name].flow_color
      local normalized_flow_color = {(flow_color[1] or flow_color.r or 0), (flow_color[2] or flow_color.g or 0), (flow_color[3] or flow_color.b or 0)}
      if normalized_flow_color[1] > 1 or normalized_flow_color[2] > 1 or normalized_flow_color[3] > 1 then
        normalized_flow_color[1] = normalized_flow_color[1] / 255
        normalized_flow_color[2] = normalized_flow_color[2] / 255
        normalized_flow_color[3] = normalized_flow_color[3] / 255
      end
      result_crafting_tint.tertiary =
      {
        normalized_flow_color[1] + ((1 - normalized_flow_color[1])*0.5),
        normalized_flow_color[2] + ((1 - normalized_flow_color[2])*0.5),
        normalized_flow_color[3] + ((1 - normalized_flow_color[3])*0.5)
      }
      result_crafting_tint.quaternary = data.raw.fluid[ingredient.name].base_color
    end
  end

  structure.hidden = true
  structure.allow_decomposition = false
  structure.unlock_results = false

  result.name = input_result .. "-recycling"
  result.localised_name = {"recipe-name.recycling", utils.get_item_localised_name(input_result)}
  result.icon = nil
  result.icons = generate_recycling_recipe_icons_from_item(result_item)
  result.crafting_machine_tint = result_crafting_tint

  return next(structure.results)
end

local recipes = data.raw.recipe
function utils.generate_recycling_recipe(recipe)
    local recipe_subgroup = recipe.subgroup
    if not recipe_subgroup then
        for subtype,_ in pairs(defines.prototypes.item) do
            local subtype = data.raw[subtype]
            if recipe.main_product and subtype then
                local original_recipe = subtype[recipe.main_product]
                if original_recipe then
                    recipe_subgroup = original_recipe.subgroup
                    break
                end
            end
        end
    end
    local result =
    {
        type = "recipe",
        subgroup = recipe_subgroup,
        category = "recycling"
    }

    if recipe.result or recipe.results then
        if not add_recipe_values(result, recipe, result) then return end
    end

    if result.name then
        recipes[result.name] = result
    end
end

return utils