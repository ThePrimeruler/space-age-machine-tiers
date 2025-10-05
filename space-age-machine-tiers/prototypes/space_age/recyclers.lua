local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")

local data_group = "furnace"

---@param level number integer
local function get_recycler_name(level)
    if level <= 1 then
        return 'recycler'
    end
    return utils.mod_name..'-recycler-'..level
end
---@param level number integer
local function get_recycler_icon(level)
    return utils.mod_path.."/graphics/icons/Recycler.png"
end



local recycler = table.deepcopy(data.raw[data_group][get_recycler_name(1)])
if not recycler then
    error(utils.mod_name..": recycler prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(recycler,'recycler'))




---@param level number integer
local function make_recycler_item(level)
    data:extend({
    {
        type = "item",
        name = get_recycler_name(level),
        icon = get_recycler_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["recycler"].subgroup,
        order = data.raw.item["recycler"].order.."-b",
        place_result = get_recycler_name(level),
        stack_size = 20,
        pick_sound = item_sounds.metal_large_inventory_pickup,
        drop_sound = item_sounds.metal_large_inventory_move,
        default_import_location = "fulgora",
        weight = 100000,
        inventory_move_sound = item_sounds.metal_large_inventory_move,
    }
    })
end

---@param level number integer
local function make_recycler_entity(level)
    -- Add
    local new_recycler = table.deepcopy(recycler)
    new_recycler.name = get_recycler_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_recycler_name(level), amount=1}} }
    new_recycler.crafting_speed = new_recycler.crafting_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    local energy_source = new_recycler["energy_source"]
    if energy_source then
        if energy_source["emissions_per_minute"] then
            for _, emission_type in ipairs(utils.constants.pollution_types) do
                emission = energy_source["emissions_per_minute"][emission_type]
                if emission and emission > 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,utils.setting_pollution_mult)) 
                elseif emission and emission <= 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,1/utils.setting_pollution_mult)) 
                end
            end
        end
    end
    new_recycler.energy_source = energy_source
    new_recycler.energy_usage = utils.multiply_with_unit(new_recycler.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_recycler.max_health = math.floor(new_recycler.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_recycler.module_slots = new_recycler.module_slots+utils.get_level_linear_delta(level,utils.setting_module_mod)
    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_recycler,utils.get_tint(level),'recycler')

    data:extend({new_recycler})
end

---@param level number integer
local function make_recycler_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_recycler_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "recycler",   amount = 1},
                {type = "item", name = "electronic-circuit",   amount = 25},
                {type = "item", name = "refined-concrete",   amount = 20},
                {type = "item", name = "carbon-fiber",   amount = 10}
            },
            results = {
                {type = "item", name = get_recycler_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            main_product = get_recycler_name(level),
            category = "electromagnetics"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_recycler_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_recycler_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 5},
                {type = "item", name = "carbon-fiber",   amount = 15},
                {type = "item", name = "refined-concrete",   amount = 30},
                {type = "item", name = "tungsten-carbide",   amount = 10}
                
            },
            results = {
                {type = "item", name = get_recycler_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            main_product = get_recycler_name(level),
            category = "electromagnetics"
        }
    else
        error(utils.mod_name..': make_recycler_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_recycler_technology(level)
    local technology = {
            type = "technology",
            name = get_recycler_name(level),
            icon = get_recycler_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_recycler_name(level)
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
                {"agricultural-science-pack", 1},
                {"electromagnetic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            'agricultural-science-pack','recycling'
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
            get_recycler_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_recycler_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_recycler(level)
    utils.debug('adding new recycler: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_recycler_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_recycler_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_recycler_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_recycler_technology(level)
end


add_new_recycler(2)
add_new_recycler(3)
