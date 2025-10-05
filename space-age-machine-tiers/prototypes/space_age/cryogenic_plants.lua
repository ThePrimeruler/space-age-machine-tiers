local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")


local data_group = "assembling-machine"

---@param level number integer
local function get_cryogenic_plant_name(level)
    if level <= 1 then
        return 'cryogenic-plant'
    end
    return utils.mod_name..'-cryogenic-plant-'..level
end
---@param level number integer
local function get_cryogenic_plant_icon(level)
    return utils.mod_path.."/graphics/icons/Cryogenic_plant.png"
end



local cryogenic_plant = table.deepcopy(data.raw[data_group][get_cryogenic_plant_name(1)])
if not cryogenic_plant then
    error(utils.mod_name..": cryogenic-plant prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(cryogenic_plant,'cryogenic-plant'))





---@param level number integer
local function make_cryogenic_plant_item(level)
    data:extend({
    {
        type = "item",
        name = get_cryogenic_plant_name(level),
        icon = get_cryogenic_plant_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["cryogenic-plant"].subgroup,
        order = data.raw.item["cryogenic-plant"].order.."-b",
        place_result = get_cryogenic_plant_name(level),
        stack_size = 20,
        pick_sound = item_sounds.metal_large_inventory_pickup,
        drop_sound = item_sounds.metal_large_inventory_move,
        default_import_location = "aquilo",
        weight = 200000,
        inventory_move_sound = item_sounds.metal_large_inventory_move,
    }
    })
end

---@param level number integer
local function make_cryogenic_plant_entity(level)
    -- Add
    local new_cryogenic_plant = table.deepcopy(cryogenic_plant)
    new_cryogenic_plant.name = get_cryogenic_plant_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_cryogenic_plant_name(level), amount=1}} }
    new_cryogenic_plant.crafting_speed = new_cryogenic_plant.crafting_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    local energy_source = new_cryogenic_plant["energy_source"]
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
    new_cryogenic_plant.energy_source = energy_source
    new_cryogenic_plant.energy_usage = utils.multiply_with_unit(new_cryogenic_plant.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_cryogenic_plant.max_health = math.floor(new_cryogenic_plant.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_cryogenic_plant.module_slots = new_cryogenic_plant.module_slots+utils.get_level_linear_delta(level,utils.setting_module_mod)
    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_cryogenic_plant,utils.get_tint(level),'cryogenic_plant')

    data:extend({new_cryogenic_plant})
end

---@param level number integer
local function make_cryogenic_plant_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_cryogenic_plant_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "cryogenic-plant",   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 15},
                {type = "item", name = "supercapacitor",   amount = 20},
                {type = "item", name = "refined-concrete",   amount = 50},
                {type = "item", name = "tungsten-plate",   amount = 20},
                {type = "fluid", name = "fluoroketone-cold", amount = 20},
            },
            results = {
                {type = "item", name = get_cryogenic_plant_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", max = 600}},
            main_product = get_cryogenic_plant_name(level),
            category = "cryogenics"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_cryogenic_plant_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_cryogenic_plant_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 25},
                {type = "item", name = "supercapacitor",   amount = 25},
                {type = "item", name = "refined-concrete",   amount = 50},
                {type = "item", name = "tungsten-carbide",   amount = 25},
                {type = "item", name = "carbon-fiber",   amount = 25},
                {type = "fluid", name = "fluoroketone-hot", amount = 20},
            },
            results = {
                {type = "item", name = get_cryogenic_plant_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", max = 600}},
            main_product = get_cryogenic_plant_name(level),
            category = "cryogenics"
        }
    else
        error(utils.mod_name..': make_cryogenic_plant_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_cryogenic_plant_technology(level)
    local technology = {
            type = "technology",
            name = get_cryogenic_plant_name(level),
            icon = get_cryogenic_plant_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_cryogenic_plant_name(level)
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
                {"agricultural-science-pack", 1},
                {"cryogenic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            'cryogenic-science-pack','cryogenic-plant'
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
                {"promethium-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            get_cryogenic_plant_name(level-1), 'promethium-science-pack'
        }
    else
        error(utils.mod_name..': make_cryogenic_plant_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_cryogenic_plant(level)
    utils.debug('adding new cryogenic_plant: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_cryogenic_plant_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_cryogenic_plant_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_cryogenic_plant_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_cryogenic_plant_technology(level)
end


add_new_cryogenic_plant(2)
add_new_cryogenic_plant(3)
