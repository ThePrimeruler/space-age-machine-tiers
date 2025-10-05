local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")

local data_group = "assembling-machine"


---@param level number integer
local function get_electromagnetic_plant_name(level)
    if level <= 1 then
        return 'electromagnetic-plant'
    end
    return utils.mod_name..'-electromagnetic-plant-'..level
end
---@param level number integer
local function get_electromagnetic_plant_icon(level)
    return utils.mod_path.."/graphics/icons/Electromagnetic_plant.png"
end



local electromagnetic_plant = table.deepcopy(data.raw[data_group][get_electromagnetic_plant_name(1)])
if not electromagnetic_plant then
    error(utils.mod_name..": electromagnetic-plant prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(electromagnetic_plant,'electromagnetic-plant'))



---@param level number integer
local function make_electromagnetic_plant_item(level)
    data:extend({
    {
        type = "item",
        name = get_electromagnetic_plant_name(level),
        icon = get_electromagnetic_plant_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["electromagnetic-plant"].subgroup,
        order = data.raw.item["electromagnetic-plant"].order.."-b",
        place_result = get_electromagnetic_plant_name(level),
        stack_size = 20,
        pick_sound = item_sounds.electric_large_inventory_pickup,
        drop_sound = item_sounds.electric_large_inventory_move,
        default_import_location = "fulgora",
        weight = 100000,
        inventory_move_sound = item_sounds.electric_large_inventory_move,
    }
    })
end

---@param level number integer
local function make_electromagnetic_plant_entity(level)
    -- Add
    local new_electromagnetic_plant = table.deepcopy(electromagnetic_plant)
    new_electromagnetic_plant.name = get_electromagnetic_plant_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_electromagnetic_plant_name(level), amount=1}} }
    new_electromagnetic_plant.crafting_speed = new_electromagnetic_plant.crafting_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    local energy_source = new_electromagnetic_plant["energy_source"]
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
    new_electromagnetic_plant.energy_source = energy_source
    new_electromagnetic_plant.energy_usage = utils.multiply_with_unit(new_electromagnetic_plant.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_electromagnetic_plant.max_health = math.floor(new_electromagnetic_plant.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_electromagnetic_plant.module_slots = new_electromagnetic_plant.module_slots+utils.get_level_linear_delta(level,utils.setting_module_mod)
    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_electromagnetic_plant,utils.get_tint(level),'electromagnetic_plant')

    data:extend({new_electromagnetic_plant})
end

---@param level number integer
local function make_electromagnetic_plant_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_electromagnetic_plant_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "electromagnetic-plant",   amount = 1},
                {type = "item", name = "electronic-circuit",   amount = 45},
                {type = "item", name = "supercapacitor",   amount = 10},
                {type = "item", name = "stone-brick",   amount = 40},
                {type = "item", name = "carbon-fiber",   amount = 20},
                {type = "fluid", name = "electrolyte", amount = 20}
            },
            results = {
                {type = "item", name = get_electromagnetic_plant_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            main_product = get_electromagnetic_plant_name(level),
            category = "electromagnetics"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_electromagnetic_plant_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_electromagnetic_plant_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 15},
                {type = "item", name = "supercapacitor",   amount = 10},
                {type = "item", name = "stone-brick",   amount = 40},
                {type = "item", name = "carbon-fiber",   amount = 20},
                {type = "fluid", name = "electrolyte", amount = 20},
                {type = "fluid", name = "fluoroketone-cold", amount = 10}
            },
            results = {
                {type = "item", name = get_electromagnetic_plant_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
            main_product = get_electromagnetic_plant_name(level),
            category = "electromagnetics"
        }
    else
        error(utils.mod_name..': make_electromagnetic_plant_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_electromagnetic_plant_technology(level)
    local technology = {
            type = "technology",
            name = get_electromagnetic_plant_name(level),
            icon = get_electromagnetic_plant_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_electromagnetic_plant_name(level)
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
            'agricultural-science-pack','electromagnetic-plant'
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
            get_electromagnetic_plant_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_electromagnetic_plant_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_electromagnetic_plant(level)
    utils.debug('adding new electromagnetic_plant: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_electromagnetic_plant_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_electromagnetic_plant_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_electromagnetic_plant_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_electromagnetic_plant_technology(level)
end



add_new_electromagnetic_plant(2)
add_new_electromagnetic_plant(3)
