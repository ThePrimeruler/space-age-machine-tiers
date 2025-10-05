local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")


local data_group = "assembling-machine"

---@param level number integer
local function get_biochamber_name(level)
    if level <= 1 then
        return 'biochamber'
    end
    return utils.mod_name..'-biochamber-'..level
end
---@param level number integer
local function get_biochamber_icon(level)
    return utils.mod_path.."/graphics/icons/Biochamber.png"
end



local biochamber = table.deepcopy(data.raw[data_group][get_biochamber_name(1)])
if not biochamber then
    error(utils.mod_name..": biochamber prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(biochamber,'biochamber'))





---@param level number integer
local function make_biochamber_item(level)
    data:extend({
    {
        type = "item",
        name = get_biochamber_name(level),
        icon = get_biochamber_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["biochamber"].subgroup,
        order = data.raw.item["biochamber"].order.."-b",
        place_result = get_biochamber_name(level),
        stack_size = 20,
        pick_sound = item_sounds.wire_inventory_pickup,
        drop_sound = item_sounds.wire_inventory_move,
        default_import_location = "gleba",
        weight = 50000,
        inventory_move_sound = item_sounds.wire_inventory_move,
    }
    })
end

---@param level number integer
local function make_biochamber_entity(level)
    -- Add
    local new_biochamber = table.deepcopy(biochamber)
    new_biochamber.name = get_biochamber_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_biochamber_name(level), amount=1}} }
    new_biochamber.crafting_speed = new_biochamber.crafting_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    local energy_source = new_biochamber["energy_source"]
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
    new_biochamber.energy_source = energy_source
    new_biochamber.energy_usage = utils.multiply_with_unit(new_biochamber.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_biochamber.max_health = math.floor(new_biochamber.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_biochamber.module_slots = new_biochamber.module_slots+utils.get_level_linear_delta(level,utils.setting_module_mod)
    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_biochamber,utils.get_tint(level),'biochamber')

    data:extend({new_biochamber})
end

---@param level number integer
local function make_biochamber_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_biochamber_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "biochamber",   amount = 1},
                {type = "item", name = "advanced-circuit",   amount = 15},
                {type = "item", name = "tungsten-plate",   amount = 10},
                {type = "item", name = "landfill",   amount = 5},
                {type = "item", name = "bioflux",   amount = 10},
            },
            results = {
                {type = "item", name = get_biochamber_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 1000, max = 2000}},
            main_product = get_biochamber_name(level),
            category = "organic"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_biochamber_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_biochamber_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 5},
                {type = "item", name = "processing-unit",   amount = 15},
                {type = "item", name = "tungsten-plate",   amount = 15},
                {type = "item", name = "landfill",   amount = 5},
                {type = "item", name = "bioflux",   amount = 20},
            },
            results = {
                {type = "item", name = get_biochamber_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 1000, max = 2000}},
            main_product = get_biochamber_name(level),
            category = "organic"
        }
    else
        error(utils.mod_name..': make_biochamber_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_biochamber_technology(level)
    local technology = {
            type = "technology",
            name = get_biochamber_name(level),
            icon = get_biochamber_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_biochamber_name(level)
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
                {"metallurgic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            'metallurgic-science-pack','biochamber'
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
            get_biochamber_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_biochamber_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_biochamber(level)
    utils.debug('adding new biochamber: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_biochamber_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_biochamber_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_biochamber_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_biochamber_technology(level)
end





add_new_biochamber(2)
add_new_biochamber(3)

