local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")


local data_group = "agricultural-tower"

---@param level number integer
local function get_agricultural_tower_name(level)
    if level <= 1 then
        return 'agricultural-tower'
    end
    return utils.mod_name..'-agricultural-tower-'..level
end
---@param level number integer
local function get_agricultural_tower_icon(level)
    return utils.mod_path.."/graphics/icons/Agricultural_tower.png"
end

local agricultural_tower = table.deepcopy(data.raw[data_group][get_agricultural_tower_name(1)])
if not agricultural_tower then
    error(utils.mod_name..": agricultural-tower prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(agricultural_tower,'agricultural_tower'))






---@param level number integer
local function make_agricultural_tower_item(level)
    data:extend({
    {
        type = "item",
        name = get_agricultural_tower_name(level),
        icon = get_agricultural_tower_icon(level),
        icon_size = 64,
        subgroup = data.raw.item["agricultural-tower"].subgroup,
        order = data.raw.item["agricultural-tower"].order.."-b",
        place_result = get_agricultural_tower_name(level),
        stack_size = 20,
        pick_sound = item_sounds.mechanical_large_inventory_pickup,
        drop_sound = item_sounds.mechanical_large_inventory_move,
        default_import_location = "gleba",
        weight = 50000,
        inventory_move_sound = item_sounds.mechanical_large_inventory_move,
    }
    })
end

---@param level number integer
local function make_agricultural_tower_entity(level)
    -- Add
    local new_agricultural_tower = table.deepcopy(agricultural_tower)
    new_agricultural_tower.name = get_agricultural_tower_name(level)
    minable = { mining_time = 0.3, result = {{type="item", name=get_agricultural_tower_name(level), amount=1}} }
    -- new_agricultural_tower.crafting_speed = new_agricultural_tower.crafting_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    local energy_source = new_agricultural_tower["energy_source"]
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
    new_agricultural_tower.energy_source = energy_source
    new_agricultural_tower.energy_usage = utils.multiply_with_unit(new_agricultural_tower.energy_usage,utils.get_level_multiplier_delta(level,utils.setting_energy_mult))
    new_agricultural_tower.max_health = math.floor(new_agricultural_tower.max_health*utils.get_level_multiplier_delta(level,utils.setting_health_mult))
    new_agricultural_tower.radius = new_agricultural_tower.radius+utils.get_level_linear_delta(level,utils.setting_agg_radius_mod)
    new_agricultural_tower.input_inventory_size = new_agricultural_tower.input_inventory_size+math.min(3,utils.get_level_linear_delta(level,utils.setting_agg_radius_mod))
    local crane = new_agricultural_tower.crane
    crane.speed.arm.turn_rate = crane.speed.arm.turn_rate*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    crane.speed.arm.extension_speed = crane.speed.arm.extension_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    crane.speed.grappler.vertical_turn_rate = crane.speed.grappler.vertical_turn_rate*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    crane.speed.grappler.horizontal_turn_rate = crane.speed.grappler.horizontal_turn_rate*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    crane.speed.grappler.extension_speed = crane.speed.grappler.extension_speed*utils.get_level_multiplier_delta(level,utils.setting_speed_mult)
    new_agricultural_tower.crane = crane

    -- Add Tint
    utils.debug('adding entity: adding tint: '..level)
    utils.add_tint_to_entity(new_agricultural_tower,utils.get_tint(level),'agricultural_tower')

    data:extend({new_agricultural_tower})
end

---@param level number integer
local function make_agricultural_tower_recipe(level)
    local recipe = {}
    if level == 2 then
        recipe = {
            type = "recipe",
            name = get_agricultural_tower_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = "agricultural-tower",   amount = 1},
                {type = "item", name = "advanced-circuit",   amount = 15},
                {type = "item", name = "tungsten-plate",   amount = 10},
                {type = "item", name = "concrete",   amount = 20},
            },
            results = {
                {type = "item", name = get_agricultural_tower_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 1000, max = 2000}},
            main_product = get_agricultural_tower_name(level),
            category = "organic"
        }
    elseif level == 3 then
        recipe = {
            type = "recipe",
            name = get_agricultural_tower_name(level),
            enabled = false,
            energy_required = 45,
            ingredients = {
                {type = "item", name = get_agricultural_tower_name(level-1),   amount = 1},
                {type = "item", name = "quantum-processor",   amount = 5},
                {type = "item", name = "processing-unit",   amount = 15},
                {type = "item", name = "tungsten-plate",   amount = 15},
                {type = "item", name = "refined-concrete",   amount = 20},
            },
            results = {
                {type = "item", name = get_agricultural_tower_name(level), amount = 1}
            },
            allow_productivity = false,
            surface_conditions = {{property = "pressure", min = 1000, max = 2000}},
            main_product = get_agricultural_tower_name(level),
            category = "organic"
        }
    else
        error(utils.mod_name..': make_agricultural_tower_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_agricultural_tower_technology(level)
    local technology = {
            type = "technology",
            name = get_agricultural_tower_name(level),
            icon = get_agricultural_tower_icon(level),
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_agricultural_tower_name(level)
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
            'metallurgic-science-pack','agriculture'
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
            get_agricultural_tower_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_agricultural_tower_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end

---@param level number integer
local function add_new_agricultural_tower(level)
    utils.debug('adding new agricultural_tower: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_agricultural_tower_entity(level)

    -- Make Item
    utils.debug('adding item: '..level)
    make_agricultural_tower_item(level)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_agricultural_tower_recipe(level)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_agricultural_tower_technology(level)
end



add_new_agricultural_tower(2)
add_new_agricultural_tower(3)


