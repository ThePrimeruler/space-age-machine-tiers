local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")

local data_group = "lightning-attractor"

---@param level number integer
local function get_lightning_rod_name(level)
    if level <= 1 then
        return 'lightning-rod'
    end
    return utils.mod_name..'-lightning-rod-'..level
end
---@param level number integer
local function get_lightning_rod_icon(level)
    return utils.mod_path.."/graphics/icons/Lightning_rod.png"
end



local lightning_rod = table.deepcopy(data.raw[data_group][get_lightning_rod_name(1)])
if not lightning_rod then
    error(utils.mod_name..": lightning_rod prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(lightning_rod,'lightning_rod'))




---@param level number integer
local function make_lightning_rod_item(level)
    data:extend({
    {
        type = "item",
        name = get_lightning_rod_name(level),
        icon = get_lightning_rod_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["lightning-rod"].subgroup,
        order = data.raw.item["lightning-rod"].order.."-b",
        place_result = get_lightning_rod_name(level),
        stack_size = 50,
        pick_sound = item_sounds.electric_small_inventory_pickup,
        drop_sound = item_sounds.electric_small_inventory_move,
        default_import_location = "fulgora",
        weight = 20000,
        inventory_move_sound = item_sounds.electric_small_inventory_move,
    }
    })
end

---@param level number integer
local function make_lightning_rod_entity(level)
    -- Add
    local new_lightning_rod = table.deepcopy(lightning_rod)
    new_lightning_rod.name = get_lightning_rod_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_lightning_rod_name(level), amount=1}} }
    local energy_source = new_lightning_rod["energy_source"]
    energy_source['buffer_capacity'] = utils.multiply_with_unit(energy_source['buffer_capacity'],utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    energy_source['output_flow_limit'] = utils.multiply_with_unit(energy_source['output_flow_limit'],utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    energy_source['drain'] = utils.multiply_with_unit(energy_source['drain'],utils.get_level_multiplier_delta(level,2/(1+utils.setting_energy_mult)))


    new_lightning_rod.energy_source = energy_source
    -- new_lightning_rod.energy_usage = utils.multiply_with_unit(new_lightning_rod.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_lightning_rod.max_health = math.floor(new_lightning_rod.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_lightning_rod.range_elongation = math.floor(new_lightning_rod.range_elongation*utils.get_level_multiplier_delta(level,utils.setting_range_mult))
    
    -- Add Tint --> no tint for now
    -- utils.debug('adding entity: adding tint: '..level)
    -- utils.add_tint_to_entity(new_lightning_rod,utils.get_tint(level),'lightning_rod')

    data:extend({new_lightning_rod})
end

---@param level number integer
local function make_lightning_rod_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_lightning_rod_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "lightning-rod",   amount = 1},
                {type = "item", name = "refined-concrete",   amount = 10},
                {type = "item", name = "tungsten-plate",   amount = 10},
                {type = "item", name = "battery",   amount = 10},
            },
            results = {
                {type = "item", name = get_lightning_rod_name(level), amount = 1}
            },
            allow_productivity = false,
            main_product = get_lightning_rod_name(level),
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            category = "electromagnetics"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_lightning_rod_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_lightning_rod_name(level-1),   amount = 1},
                {type = "item", name = "refined-concrete",   amount = 15},
                {type = "item", name = "tungsten-plate",   amount = 10},
                {type = "item", name = "lithium-plate",   amount = 5},
            },
            results = {
                {type = "item", name = get_lightning_rod_name(level), amount = 1}
            },
            allow_productivity = false,
            main_product = get_lightning_rod_name(level),
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            category = "electromagnetics"
        }
    else
        error(utils.mod_name..': make_lightning_rod_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_lightning_rod_technology(level)
    local technology = {
            type = "technology",
            name = get_lightning_rod_name(level),
            icon = get_lightning_rod_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_lightning_rod_name(level)
                },
            },
            prerequisites = {},
            unit = {}
        }

    if level == 2 then
        technology.unit = {
            count = 750,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1},
                {"metallurgic-science-pack", 1},
                {"electromagnetic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            'electromagnetic-science-pack','metallurgic-science-pack'
        }

    elseif level == 3 then
        technology.unit = {
            count = 1500,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1},
                {"metallurgic-science-pack", 1},
                {"electromagnetic-science-pack", 1},
                {"agricultural-science-pack", 1},
                {"cryogenic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            get_lightning_rod_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_lightning_rod_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_lightning_rod(level)
    utils.debug('adding new lightning_rod: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_lightning_rod_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_lightning_rod_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_lightning_rod_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_lightning_rod_technology(level)
end


add_new_lightning_rod(2)
add_new_lightning_rod(3)
