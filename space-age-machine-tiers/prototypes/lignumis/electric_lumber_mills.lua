local item_sounds = require("__base__.prototypes.item_sounds")
local utils = require("lib.utils")


local data_group = "assembling-machine"

---@param level number integer
local function get_electric_lumber_mill_name(level)
    return utils.mod_name..'-electric-lumber-mill-'..level
end

local base_lumber_mill_name = 'lumber-mill'

local base_lumber_mill = table.deepcopy(data.raw[data_group][base_lumber_mill_name])
if not base_lumber_mill then
    error(utils.mod_name..": "..base_lumber_mill_name.." prototype not found.")
end
-- utils.debug(utils.jsonSerializeTable(base_lumber_mill,base_lumber_mill_name))


-- GET BASE LUMBER MILL THINGS
local recipes = data.raw.recipe
local items = data.raw.item
local technologies = data.raw.technology

local base_lumber_mill_recipe = recipes[base_lumber_mill_name]
if not base_lumber_mill_recipe then
    error('did not find recipe definition for '..base_lumber_mill_name)
end
local base_lumber_mill_item = items[base_lumber_mill_name]
if not base_lumber_mill_item then
    error('did not find item definition for '..base_lumber_mill_name)
end



local backup_lignumis_machine_tech_mapping = {
    [base_lumber_mill_name] = base_lumber_mill_name
}
---@param machine_name string
local function find_recipe_technology(machine_name)
    if technologies[machine_name] then
        return machine_name, technologies[machine_name]
    end
    for tech_name,tech_body in pairs(technologies) do
        if tech_body.effects then
            for _, effect in ipairs(tech_body.effects) do
                if effect.type == 'unlock-recipe' and effect.recipe == machine_name then
                    return tech_name, tech_body
                end
            end
        end
    end
    if backup_lignumis_machine_tech_mapping[machine_name] and technologies[backup_lignumis_machine_tech_mapping[machine_name]] then
        utils.debug('using backup technology mapping for machine: '..machine_name)
        return backup_lignumis_machine_tech_mapping[machine_name], technologies[backup_lignumis_machine_tech_mapping[machine_name]]
    end

    utils.debug('failed to find technology for machine: '..machine_name)
    return '', {}
end

base_lumber_mill_technology_name, base_lumber_mill_technology = find_recipe_technology(base_lumber_mill_name)

if base_lumber_mill_technology_name then
    utils.debug('found '..base_lumber_mill_name..' technology: '..base_lumber_mill_technology_name)
else
    error('did not find technology definition for '..base_lumber_mill_name)
end


-- Functions To Create New Tiers

local function if_exist_modify(level,entity,key,modifier,is_mult)
    if not entity[key] then
        return
    end
    
    if type(entity[key])=="string" then
        entity[key] = utils.multiply_with_unit(entity[key],utils.get_level_multiplier_delta(level,modifier))
    elseif is_mult then
        entity[key] = entity[key] * utils.get_level_multiplier_delta(level,modifier)
    else
        entity[key] = entity[key] + utils.get_level_linear_delta(level,modifier)
    end
end



---@param level number integer
local function make_electric_lumber_mill_item(level, name, item)
    local new_machine_item = table.deepcopy(item)
    new_machine_item.name = get_electric_lumber_mill_name(level)
    new_machine_item.localised_name = {"", {utils.mod_name..'.prefix-electric'}, utils.get_item_localised_name(name), ''.. (level>1 and (' '..level) or '') }
    new_machine_item.localised_description = {"", utils.get_item_localised_description(name) }
    new_machine_item.place_result = get_electric_lumber_mill_name(level)
    new_machine_item.order = data.raw.item[base_lumber_mill_name].order.."-b",
    data.extend({new_machine_item})
end

---@param level number integer
local function make_electric_lumber_mill_entity(level, name, entity)
    local new_machine = table.deepcopy(entity)

    new_machine.name = get_electric_lumber_mill_name(level)
    new_machine.localised_name = {"", {utils.mod_name..'.prefix-electric'}, utils.get_item_localised_name(name), ''.. (level>1 and (' '..level) or '') }
    new_machine.localised_description = {"", utils.get_item_localised_description(name) }

    new_machine.minable.result = get_electric_lumber_mill_name(level)

    if_exist_modify(level,new_machine,'max_health',utils.setting_health_mult,true)
    if_exist_modify(level,new_machine,'crafting_speed',utils.setting_speed_mult,true)
    if_exist_modify(level,new_machine,'energy_usage',utils.setting_energy_mult,true)
    if_exist_modify(level,new_machine,'module_slots',utils.setting_module_mod,false)
    if_exist_modify(level,new_machine,'mining_speed',utils.setting_speed_mult,true)
    if_exist_modify(level,new_machine,'researching_speed',utils.setting_speed_mult,true)

    local energy_source = new_machine["energy_source"]
    if energy_source then
        if energy_source["emissions_per_minute"] then
            for _, emission_type in ipairs({'pollution','spores'}) do
                emission = energy_source["emissions_per_minute"][emission_type]
                if emission and emission > 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,utils.setting_pollution_mult)) 
                elseif emission and emission <= 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,1/utils.setting_pollution_mult)) 
                end
            end
        end
        new_machine["energy_source"] = energy_source
    end


    data.extend({new_machine})
end

---@param level number integer
local function make_electric_lumber_mill_recipe(level, name, old_recipe)
    local recipe = {
        type = "recipe",
        energy_required = math.floor(old_recipe.energy_required * utils.get_level_multiplier_delta(level,1.5)),
        name = get_electric_lumber_mill_name(level),
        enabled = false,
        allow_productivity = false,
        surface_conditions = {{property = "pressure", min = 1000, max = 2000}},
        main_product = get_electric_lumber_mill_name(level),
        results = {
            {type = "item", name = get_electric_lumber_mill_name(level), amount = 1}
        },
        category = "organic"
    }
    if level == 1 then
        recipe.ingredients = {
            {type = "item", name = base_lumber_mill_name, amount = 1},
            { type = "item", name = "stone-brick", amount = 40 },
            { type = "item", name = "iron-gear-wheel", amount = 20 },
            { type = "item", name = "pipe", amount = 10 },
            { type = "item", name = "electronic-circuit", amount = 10 },
        }
    elseif level == 2 then
        recipe.ingredients = {
            {type = "item", name = get_electric_lumber_mill_name(level-1), amount = 1},
            { type = "item", name = "concrete", amount = 35 },
            { type = "item", name = "iron-gear-wheel", amount = 40 },
            { type = "item", name = "pipe", amount = 20 },
            { type = "item", name = "advanced-circuit", amount = 10 },
        }
    elseif level == 3 then
        recipe.ingredients = {
            {type = "item", name = get_electric_lumber_mill_name(level-1), amount = 1},
            { type = "item", name = "refined-concrete", amount = 55 },
            { type = "item", name = "iron-gear-wheel", amount = 45 },
            { type = "item", name = "pipe", amount = 25 },
            { type = "item", name = "processing-unit", amount = 10 },
        }
    else
        error(utils.mod_name..': make_lumber_mill_recipe: unknown level: '..level )
    end

    utils.generate_recycling_recipe(recipe)
    data:extend({
        recipe
    })
end

---@param level number integer
local function make_electric_lumber_mill_technology(level, name, old_technology)
    local technology = {
            type = "technology",
            name = get_electric_lumber_mill_name(level),
            icon = old_technology.icon,
            icon_size = 256,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = get_electric_lumber_mill_name(level)
                },
            },
            prerequisites = {},
            unit = {},
            localised_name = {"", {utils.mod_name..'.prefix-electric'}, utils.get_item_localised_name(name), ''.. (level>1 and (' '..level) or '') },
            localised_description = {"", utils.get_item_localised_description(name) },
        }
    if level == 1 then
        technology.unit = {
            count = 750,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            old_technology.name, 'steam-power'
        }
    elseif level == 2 then
        technology.unit = {
            count = 1000,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1},
                {"agricultural-science-pack", 1},
            },
            time = 60
        }
        technology.prerequisites = {
            get_electric_lumber_mill_name(level-1),'agriculture'
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
            get_electric_lumber_mill_name(level-1), 'cryogenic-science-pack'
        }
    else
        error(utils.mod_name..': make_lumber_mill_technology: unknown level: '..level )
    end
    data:extend({
        technology
    })
end


local function update_base_lumber_mill()
    local new_machine = base_lumber_mill
    local name = base_lumber_mill_name
    local level = 1.5

    new_machine.name = get_electric_lumber_mill_name(level)
    new_machine.localised_name = {"", {utils.mod_name..'.prefix-electric'}, utils.get_item_localised_name(name), ''.. (level>1 and (' '..level) or '') }
    new_machine.localised_description = {"", utils.get_item_localised_description(name) }
    new_machine.minable.result = get_electric_lumber_mill_name(level)

    -- change some settings
    if_exist_modify(level,new_machine,'crafting_speed',utils.setting_speed_mult,true)

    local energy_source = new_machine["energy_source"]

    -- make electric instead of burner
    energy_source['fuel_categories'] = nil
    energy_source['effectivity'] = nil
    energy_source['fuel_inventory_size'] = nil
    energy_source['type'] = 'electric'
    energy_source['usage_priority'] = 'secondary-input'
    -- update 'pollution'
    local energy_source = new_machine["energy_source"]
    if energy_source then
        if energy_source["emissions_per_minute"] then
            for _, emission_type in ipairs(utils.constants.pollution_types) do
                emission = energy_source["emissions_per_minute"][emission_type]
                if emission == 'pollution' then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(energy_source["emissions_per_minute"][emission_type] * .4)
                elseif emission == 'noise' then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(energy_source["emissions_per_minute"][emission_type] * .7)
                else
                    if emission and emission > 0 then
                        energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,utils.setting_pollution_mult)) 
                    elseif emission and emission <= 0 then
                        energy_source["emissions_per_minute"][emission_type] = math.floor(emission * utils.get_level_multiplier_delta(level,1/utils.setting_pollution_mult)) 
                    end
                end
            end
        end
        new_machine["energy_source"] = energy_source
    end


    base_lumber_mill = new_machine
end


---@param level number integer
local function add_new_electric_lumber_mill(level)
    utils.debug('adding new electric_lumber_mill: '..level)

    -- Make the Entity
    utils.debug('adding entity: '..level)
    make_electric_lumber_mill_entity(level, base_lumber_mill_name, base_lumber_mill)

    -- Make Item
    utils.debug('adding item: '..level)
    make_electric_lumber_mill_item(level, base_lumber_mill_name, base_lumber_mill_item)

    -- Add it's Recipe
    utils.debug('adding recipe: '..level)
    make_electric_lumber_mill_recipe(level, base_lumber_mill_name, base_lumber_mill_recipe)

    -- Add it's Technology
    utils.debug('adding technology: '..level)
    make_electric_lumber_mill_technology(level, base_lumber_mill_name, base_lumber_mill_technology)
end


update_base_lumber_mill()
add_new_electric_lumber_mill(1)
add_new_electric_lumber_mill(2)
add_new_electric_lumber_mill(3)


