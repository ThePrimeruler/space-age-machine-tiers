local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")


local data_group = "mining-drill"

---@param level number integer
local function get_drill_name(level)
    if level <= 1 then
        return 'big-mining-drill'
    end
    return utils.mod_name..'-big-mining-drill-'..level
end
---@param level number integer
local function get_drill_icon(level)
    return utils.mod_path.."/graphics/icons/Big_mining_drill.png"
end



local big_drill = table.deepcopy(data.raw[data_group][get_drill_name(1)])
if not big_drill then
    error(utils.mod_name..": big-mining-drill prototype not found.")
end




---@param level number integer
local function make_drill_item(level)
    data:extend({
    {
        type = "item",
        name = get_drill_name(level),
        icon = get_drill_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["big-mining-drill"].subgroup,
        order = data.raw.item["big-mining-drill"].order.."-b",
        place_result = get_drill_name(level),
        stack_size = 20,
        pick_sound = item_sounds.drill_inventory_pickup,
        drop_sound = item_sounds.drill_inventory_move,
        default_import_location = "vulcanus",
        weight = 200000,
        inventory_move_sound = item_sounds.drill_inventory_move,
    }
    })
end

---@param level number integer
local function make_drill_entity(level)
    -- Add
    local new_drill = table.deepcopy(big_drill)
    new_drill.name = get_drill_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_drill_name(level), amount=1}} }
    new_drill.mining_speed = new_drill.mining_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)


    local energy_source = new_drill["energy_source"]
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
    new_drill.energy_source = energy_source
    new_drill.energy_usage = utils.multiply_with_unit(new_drill.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_drill.max_health = math.floor(new_drill.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_drill.module_slots = new_drill.module_slots+utils.get_level_linear_delta(level,utils.setting_module_mod)
    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_drill,utils.get_tint(level),'big_drill')

    data:extend({new_drill})
end

---@param level number integer
local function make_drill_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_drill_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "big-mining-drill",   amount = 1},
                {type = "item", name = "processing-unit",   amount = 15},
                {type = "item", name = "superconductor",   amount = 5},
                {type = "fluid", name = "molten-iron", amount = 250},
                {type = "fluid", name = "molten-copper", amount = 250},
            },
            results = {
                {type = "item", name = get_drill_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 4000, max = 4000}},
            main_product = get_drill_name(level),
            category = "metallurgy"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_drill_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_drill_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 15},
                {type = "item", name = "carbon-fiber",   amount = 15},
                {type = "fluid", name = "molten-iron", amount = 500},
                {type = "fluid", name = "molten-copper", amount = 500},
            },
            results = {
                {type = "item", name = get_drill_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 4000, max = 4000}},
            main_product = get_drill_name(level),
            category = "metallurgy"
        }
    else
        error(utils.mod_name..': make_drill_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_drill_technology(level)
    local technology = {
            type = "technology",
            name = get_drill_name(level),
            icon = get_drill_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_drill_name(level)
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
            'electromagnetic-science-pack','big-mining-drill'
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
            get_drill_name(level-1), 'cryogenic-science-pack', 'carbon-fiber'
        }
    else
        error(utils.mod_name..': make_drill_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_drill(level)
    utils.debug('adding new drill: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_drill_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_drill_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_drill_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_drill_technology(level)
end



add_new_drill(2)
add_new_drill(3)