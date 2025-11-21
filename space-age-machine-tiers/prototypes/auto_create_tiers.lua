local utils = require("lib.utils")

local auto_create_tiers = {}

local cost_multiplier = utils.setting_cost_mult

local material_to_next_tier_map = utils.constants.material_to_next_tier_map

local science_material_to_next_tier_map = utils.constants.science_material_to_next_tier_map

local space_packs = utils.constants.space_packs

local pre_space_science_tiers = utils.constants.pre_space_science_tiers
local pre_space_science_additional = utils.constants.pre_space_science_additional

local all_space_pack_next = utils.constants.all_space_pack_next

local post_space_science_tiers = utils.constants.post_space_science_tiers

local space_next_pack_mapping = utils.constants.space_next_pack_mapping

local tech_to_sci_pack_map = utils.constants.tech_to_sci_pack_map

local entity_types = utils.constants.entity_types

---@param val any
---@return boolean (true if nil, '', or {})
local function isempty(val)
    return val == nil or val == '' or val == {}
end

---@param level integer
---@param entity data.EntityPrototype
---@param key string | table
---@param modifier number
---@param is_mult bool true means multiply, false means add
---@param floor bool should the result be rounded down (integer)
---@return nil
local function if_exist_modify(level, entity, key, modifier, is_mult, floor)
    ---@param the_entity table
    ---@param the_key string | table
    local function get_value(the_entity, the_key)
        if type(the_key) == "string" then
            return the_entity[the_key]
        end
        if type(the_key) ~= 'table' then
            error('received a non string or table value for the_key: '..tostring(the_key)..' of type '..type(the_key))
        end
        if #the_key == 0 then
            error("received an empty list for the_key")
        end

        local first_key = the_key[1]
        local rest_keys = {}
        for i = 2, #the_key do
            rest_keys[#rest_keys + 1] = the_key[i]
        end

        -- if this key doesn’t exist, bail out
        if the_entity[first_key] == nil then
            return nil
        end

        if #rest_keys == 0 then
            return the_entity[first_key]
        else
            return get_value(the_entity[first_key], rest_keys)
        end
    end

    ---@param the_entity table
    ---@param the_key string | table
    ---@param value any
    local function set_value(the_entity, the_key, value)
        if type(the_key) == "string" then
            the_entity[the_key] = value
            return the_entity
        end
        if #the_key == 0 then
            error("received an empty list for the_key")
        end

        local first_key = the_key[1]

        -- base case: final key
        if #the_key == 1 then
            the_entity[first_key] = value
            return the_entity
        end

        -- recursive case: must have a table at this point
        if type(the_entity[first_key]) ~= "table" then
            -- do nothing if missing (safe) OR create table if you prefer
            return the_entity
        end

        -- recurse down the rest of the keys
        local rest_keys = {}
        for i = 2, #the_key do
            rest_keys[#rest_keys + 1] = the_key[i]
        end
        set_value(the_entity[first_key], rest_keys, value)

        return the_entity
    end

    if get_value(entity, key) == nil then
        return
    end

    if type(get_value(entity, key)) == "string" then
        set_value(entity, key,
            utils.multiply_with_unit(get_value(entity, key), utils.get_level_multiplier_delta(level, modifier)))
    elseif is_mult then
        if floor then
            set_value(entity, key, math.floor(get_value(entity, key) * utils.get_level_multiplier_delta(level, modifier)))
        else
            set_value(entity, key, get_value(entity, key) * utils.get_level_multiplier_delta(level, modifier))
        end
    else
        if floor then
            set_value(entity, key, get_value(entity, key) + utils.get_level_linear_delta(level, modifier))
        else
            set_value(entity, key, math.floor(get_value(entity, key) + utils.get_level_linear_delta(level, modifier)))
        end
    end
end

---@param level integer
---@param name string
---@param entity data.EntityPrototype
---@return nil
local function make_machine_entity(level, name, entity)
    local new_machine = table.deepcopy(entity)
    if utils.setting_add_tier_icons and (new_machine.icon or new_machine.icons) then
        utils.add_tier_icon_to_proto(new_machine, level)
    end

    new_machine.name = utils.get_machine_name(level, name)
    new_machine.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine.localised_description = { "", utils.get_item_localised_description(name) }

    new_machine.minable.results = nil
    new_machine.minable.result = utils.get_machine_name(level, name)

    if_exist_modify(level, new_machine, 'max_health', utils.setting_health_mult, true, true)
    if_exist_modify(level, new_machine, 'crafting_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, 'energy_usage', utils.setting_energy_mult, true, true)
    if_exist_modify(level, new_machine, 'module_slots', utils.setting_module_mod, false, true)
    if_exist_modify(level, new_machine, 'mining_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, 'distribution_effectivity', utils.setting_beacon_dist_mult, true, false)
    if_exist_modify(level, new_machine, 'researching_speed', utils.setting_speed_mult, true, false)

    if_exist_modify(level, new_machine, 'inventory_size', utils.setting_storage_mult, true, false)
    if_exist_modify(level, new_machine, 'inventory_size_bonus', utils.setting_storage_mult, true, false)

    -- Special Effects (such as inbuilt productivity)
    for _, effect_name in ipairs({
        "consumption",
        "speed",
        "productivity",
        "pollution",
        "quality"
    }) do
        if_exist_modify(level, new_machine, {'effect_receiver','base_effect',effect_name}, utils.setting_special_effect_mult, true, false)
    end
    if_exist_modify(level, new_machine, 'science_pack_drain_rate_percent', 2/(1+utils.setting_special_effect_mult), true, true)
    if_exist_modify(level, new_machine, 'resource_drain_rate_percent', 2/(1+utils.setting_special_effect_mult), true, true)

    -- Fluid Volume
    for _, fluid_box_name in ipairs({ 'fluid_box', 'fuel_fluid_box', 'oxidizer_fluid_box' }) do
        if_exist_modify(level, new_machine, { fluid_box_name, 'volume' }, utils.setting_tank_mult, true, true)
    end

    if new_machine.max_performance then
        -- thruster efficiency and consumption
        if new_machine.max_performance.fluid_usage then
            new_machine.max_performance.fluid_usage = new_machine.max_performance.fluid_usage *
            utils.get_level_multiplier_delta(level, utils.setting_speed_mult)
        end
        if new_machine.max_performance.effectivity then
            new_machine.max_performance.effectivity = 1 -
            math.max(0,
                math.min(1,
                    (1 - new_machine.max_performance.effectivity) ^ ((level - 1) * utils.setting_thruster_performance_mult)))
        end
    end

    -- Reactor (Heating Tower):
    if_exist_modify(level, new_machine, { 'heat_buffer', 'specific_heat' }, math.sqrt(utils.setting_energy_mult), true,
        false)
    if_exist_modify(level, new_machine, { 'heat_buffer', 'max_temperature' }, math.sqrt(utils.setting_energy_mult), true,
        false)
    if_exist_modify(level, new_machine, { 'heat_buffer', 'max_transfer' }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, 'consumption', utils.setting_energy_mult, true, false)

    -- agricultural tower
    if new_machine.crane then
        if_exist_modify(level, new_machine, 'radius', utils.setting_agg_radius_mod, false, true)
        if_exist_modify(level, new_machine, {'crane','arm','turn_rate'}, utils.setting_speed_mult, true, false)
        if_exist_modify(level, new_machine, {'crane','arm','extension_speed'}, utils.setting_speed_mult, true, false)
        if_exist_modify(level, new_machine, {'crane','grappler','vertical_turn_rate'}, utils.setting_speed_mult, true, false)
        if_exist_modify(level, new_machine, {'crane','grappler','horizontal_turn_rate'}, utils.setting_speed_mult, true, false)
        if_exist_modify(level, new_machine, {'crane','grappler','extension_speed'}, utils.setting_speed_mult, true, false)
    end


    -- asteroid-collector
    if new_machine.arm_speed_base then
        if_exist_modify(level, new_machine, 'arm_speed_base', utils.setting_speed_mult, true, false)
        if_exist_modify(level, new_machine, 'arm_angular_speed_cap_base', utils.setting_speed_mult, true, false)
    end

    -- military
    if_exist_modify(level, new_machine, 'turret_rotation_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, 'rotation_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, 'preparing_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, 'attacking_speed', utils.setting_speed_mult, true, false)
    if_exist_modify(level, new_machine, { 'attack_parameters', 'range' }, math.sqrt(utils.setting_range_mult), true, true)
    if_exist_modify(level, new_machine, { 'attack_parameters', 'min_range' }, (2 / (1 + utils.setting_range_mult)), true,
        true)
    if_exist_modify(level, new_machine, { 'attack_parameters', 'cooldown' }, (2 / (1 + math.sqrt(utils.setting_speed_mult))),
        true, true)
    if_exist_modify(level, new_machine, { 'attack_parameters', 'damage_modifier' }, utils.setting_damage_mult, true,
        false)
    if_exist_modify(level, new_machine, { 'attack_parameters', 'ammo_type', 'energy_consumption' },
        utils.setting_energy_mult, true, false)

    -- Todo: figure out damage bonus ...

    -- lightning collector
    if_exist_modify(level, new_machine, 'range_elongation', utils.setting_range_mult, true, false)
    if_exist_modify(level, new_machine, 'efficiency', utils.setting_special_effect_mult, true, false)


    -- inserter
    if_exist_modify(level, new_machine, 'extension_speed', utils.setting_speed_mult, true, false)
    --(rotation speed already covered)

    -- radar
    if_exist_modify(level, new_machine, 'energy_per_sector', 2/(1+utils.setting_energy_mult), true, false)
    if_exist_modify(level, new_machine, 'energy_per_nearby_scan', 2/(1+utils.setting_energy_mult), true, false)
    if_exist_modify(level, new_machine, 'max_distance_of_sector_revealed', utils.setting_range_mult, true, true)
    if_exist_modify(level, new_machine, 'max_distance_of_nearby_sector_revealed', utils.setting_range_mult, true, true)


    -- Turbines
    if_exist_modify(level, new_machine, { 'energy_source', 'output_flow_limit', }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, 'max_fluid_usage', utils.setting_energy_mult, true, false)

    -- Burner Generator
    if_exist_modify(level, new_machine, 'max_power_output', utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, { 'burner', 'effectivity' }, (1+utils.setting_energy_mult)/2, true, false)

    -- Energy Settings
    if_exist_modify(level, new_machine, { 'energy_source', 'buffer_capacity', }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, { 'energy_source', 'input_flow_limit', }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, 'drain', 2/(1+utils.setting_energy_mult), true, false)


    local energy_source = new_machine["energy_source"]
    if energy_source then
        if energy_source["emissions_per_minute"] then
            for _, emission_type in ipairs(utils.constants.pollution_types) do
                emission = energy_source["emissions_per_minute"][emission_type]
                if emission and emission > 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission *
                    utils.get_level_multiplier_delta(level, utils.setting_pollution_mult))
                elseif emission and emission <= 0 then
                    energy_source["emissions_per_minute"][emission_type] = math.floor(emission *
                    utils.get_level_multiplier_delta(level, 1 / utils.setting_pollution_mult))
                end
            end
        end
        new_machine["energy_source"] = energy_source
    end


    data.extend({ new_machine })
end

---@param level integer
---@param name string
---@param item data.ItemPrototype
---@return nil
local function make_machine_item(level, name, item)
    local new_machine_item = table.deepcopy(item)
    if utils.setting_add_tier_icons and (new_machine_item.icon or new_machine_item.icons) then
        utils.add_tier_icon_to_proto(new_machine_item, level)
    end
    new_machine_item.icons = new_machine_item.icons -- TODO: code here
    new_machine_item.name = utils.get_machine_name(level, name)
    new_machine_item.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_item.localised_description = { "", utils.get_item_localised_description(name) }
    new_machine_item.place_result = utils.get_machine_name(level, name)
    if new_machine_item.order then
        new_machine_item.order = new_machine_item.order .. '-b'
    else
        new_machine_item.order = name .. '-b'
    end
    if not new_machine_item.subgroup then
        new_machine_item.subgroup = "production-machine"
    end
    data.extend({ new_machine_item })
end


--- TODO:  rewrite this unction
--- Break out material maps into their own functions
---@param recipe data.RecipePrototype
---@param current_level integer
---@param new_science_packs table
---@return nil
local function update_recipe_materials(recipe, current_level, new_science_packs)
    -- material_to_next_tier_map
    -- science_material_to_next_tier_map

    local current_new_science_packs = new_science_packs[current_level]

    if not current_new_science_packs then
        current_new_science_packs = {}
    end

    local material_mapping = table.deepcopy(material_to_next_tier_map)

    for _, sci_pack in ipairs(current_new_science_packs) do -- TODO: rework how this works to fix overwriting
        if science_material_to_next_tier_map[sci_pack] then
            for key, val in pairs(science_material_to_next_tier_map[sci_pack]) do
                material_mapping[key] = val
            end
        end
    end

    -- now look at the materials in the recipe, and update their name and amount if you can
    -- if not in mapping, then just scale it's cost
    local materials_changed = 0
    if recipe.ingredients then
        for i, ingredient in ipairs(recipe.ingredients) do
            local ingredient_name   = ingredient.name or ingredient[1]
            local ingredient_amount = ingredient.amount or ingredient[2]
            if material_mapping[ingredient_name] then -- in mapping, so updating material
                materials_changed = materials_changed + 1
                local new_mapping = material_mapping[ingredient_name]
                if recipe.ingredients[i].name then
                    recipe.ingredients[i].name = new_mapping.item
                    recipe.ingredients[i].amount = math.floor(cost_multiplier * new_mapping.ratio * ingredient_amount)
                else
                    recipe.ingredients[i][1] = new_mapping.item
                    recipe.ingredients[i][2] = math.floor(cost_multiplier * new_mapping.ratio * ingredient_amount)
                end
            else -- not in mapping, so just scale its cost
                if recipe.ingredients[i].name then
                    recipe.ingredients[i].amount = math.floor(cost_multiplier * ingredient_amount)
                else
                    recipe.ingredients[i][2] = math.floor(cost_multiplier * ingredient_amount)
                end
            end
        end
    end


    -- after that, add in materials if rules apply
    if material_mapping['add'] then
        local add_map    = material_mapping['add']
        local backup_map = material_mapping['backup']

        -- collect all mapped outputs (excluding "add"/"backup" keys)
        local mapped_outputs = {}
        for key, val in pairs(material_mapping) do
            if key ~= 'add' and key ~= 'backup' and type(val) == "table" and val.item then
                mapped_outputs[val.item] = true
            end
        end

        -- check if any mapped outputs exist in recipe
        local has_mapped_item = false
        for _, ingredient in ipairs(recipe.ingredients) do
            local ingredient_name = ingredient.name or ingredient[1]
            if mapped_outputs[ingredient_name] then
                has_mapped_item = true
                break
            end
        end

        -- decide whether we should insert
        if materials_changed == 0 or not has_mapped_item then
            -- compute average count of non-fluid items
            local total_amount, total_count = 0, 0
            for _, ingredient in ipairs(recipe.ingredients) do
                local ingredient_name   = ingredient.name or ingredient[1]
                local ingredient_amount = ingredient.amount or ingredient[2]
                local ingredient_type   = ingredient.type or "item"

                if ingredient_name and ingredient_type == "item" then
                    total_amount = total_amount + ingredient_amount
                    total_count = total_count + 1
                end
            end

            local average_amount = 0
            if total_count > 0 then
                average_amount = math.floor(total_amount / total_count)
            end

            -- choose which mapping to use: add or backup
            local target_map = add_map
            if materials_changed == 0 then
                for _, ingredient in ipairs(recipe.ingredients) do
                    local ingredient_name = ingredient.name or ingredient[1]
                    if ingredient_name == add_map.item then
                        if backup_map then
                            target_map = backup_map
                            break
                        else
                            target_map = nil -- skip entirely
                        end
                        break
                    end
                end
            end

            -- insert only if we found a valid target_map
            if target_map then
                table.insert(recipe.ingredients, {
                    type   = "item",
                    name   = target_map.item,
                    amount = math.floor(average_amount * target_map.ratio)
                })
            end
        end
    end

    -- Then loop through the ingredients and combine matching names
    if recipe.ingredients then
        local combined_map = {}

        -- collect into map (track type + amount)
        for _, ingredient in ipairs(recipe.ingredients) do
            local ingredient_name   = ingredient.name or ingredient[1]
            local ingredient_amount = ingredient.amount or ingredient[2]
            local ingredient_type   = ingredient.type or "item" -- array-style defaults to item

            if ingredient_name then
                if not combined_map[ingredient_name] then
                    combined_map[ingredient_name] = {
                        type = ingredient_type,
                        amount = ingredient_amount
                    }
                else
                    combined_map[ingredient_name].amount =
                        combined_map[ingredient_name].amount + ingredient_amount
                end
            end
        end

        -- rebuild ingredients list
        local new_list = {}
        for name, data in pairs(combined_map) do
            if data.amount > 0 then
                table.insert(new_list, {
                    type = data.type,
                    name = name,
                    amount = data.amount
                })
            end
        end

        recipe.ingredients = new_list
    end
end

---@param level integer
---@param name string
---@param recipe data.RecipePrototype
---@param new_science_packs table
---@return nil
local function make_machine_recipe(level, name, recipe, new_science_packs)
    --new_science_packs is table in format: {[level] = sci_packs}
    --      sci_packs being {sci_pack_name,...}

    local new_machine_recipe = table.deepcopy(recipe)
    if utils.setting_add_tier_icons and (new_machine_recipe.icon or new_machine_recipe.icons) then
        utils.add_tier_icon_to_proto(new_machine_recipe, level)
    end
    new_machine_recipe.name = utils.get_machine_name(level, name)

    new_machine_recipe.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_recipe.localised_description = { "", utils.get_item_localised_description(name) }

    if new_machine_recipe.energy_required then
        new_machine_recipe.energy_required = new_machine_recipe.energy_required * (cost_multiplier^(level-1))
    end
    new_machine_recipe.results[1].name = utils.get_machine_name(level, name)
    new_machine_recipe.main_product = utils.get_machine_name(level, name)


    -- looks at ingredients in recipe to:
    -- convert low tier materials to a higher tier if possible
    -- scales their amount (even if can't tier up material)
    for current_level = 2, level do
        update_recipe_materials(new_machine_recipe, current_level, new_science_packs)
    end


    -- add in the previous tier machine to the crafting recipe
    table.insert(new_machine_recipe.ingredients,
        { type = "item", name = utils.get_machine_name(level - 1, name), amount = 1 })

    utils.generate_recycling_recipe(new_machine_recipe)
    data.extend({ new_machine_recipe })
end


--- true if `sci_pack_name` exists in the `ingredients_list`
---@param ingredients_list array
---@param sci_pack_name string
---@return boolean
local function sci_pack_in_ingredients(ingredients_list, sci_pack_name)
    for _, item in ipairs(ingredients_list) do
        if item[1] == sci_pack_name then
            return true
        end
    end
    return false
end

--- generates pre-requisite science packs for a given tech_stack
---@param tech_stack [string|data.TechnologyPrototype]
---@param count integer
---@param sci_packs table
---@param visited table
---@return integer
---@return table
local function get_prerequisite_science_packs_from_tree(tech_stack, count, sci_packs, visited)
    utils.debug('get_prerequisite_science_packs_from_tree')


    visited = visited or {}
    sci_packs = sci_packs or {}

    while tech_stack and next(tech_stack) do
        local depth, node = table.unpack(table.remove(tech_stack, 1))

        -- node can be a proto table or a string name
        local tech_name, tech_proto
        if type(node) == "table" then
            tech_proto = node
            tech_name  = node.name
        else
            tech_name  = node
            tech_proto = data.raw.technology[tech_name]
        end

        -- avoid cycles
        if tech_name and visited[tech_name] then
            goto continue
        end
        if tech_name then visited[tech_name] = true end

        -- special mapping (planet discovery, etc.)
        if tech_name then
            local mapped = tech_to_sci_pack_map[tech_name]
            if mapped then
                -- walk backwards through pre_space_science_tiers to add all prior packs
                local function add_with_prereqs(pack, seen_back)
                    seen_back = seen_back or {}
                    if not pack or seen_back[pack] then return end
                    seen_back[pack] = true
                    if not utils.list_contains(sci_packs, pack) then table.insert(sci_packs, pack) end
                    for pre, m in pairs(pre_space_science_tiers) do
                        if m.item == pack then add_with_prereqs(pre, seen_back) end
                    end
                end
                add_with_prereqs(mapped)
            end
        end


        -- collect packs/count if this tech has a unit
        if tech_proto and tech_proto.unit then
            local unit = tech_proto.unit

            if unit.ingredients then
                for _, ing in ipairs(unit.ingredients) do
                    local pack = ing[1] or ing.name
                    if pack and not utils.list_contains(sci_packs, pack) then
                        table.insert(sci_packs, pack)
                    end
                end
            end

            if unit.count and unit.count > count then
                count = unit.count
            end
        end

        -- push prerequisites for traversal
        if tech_proto and tech_proto.prerequisites then
            for _, pre in ipairs(tech_proto.prerequisites) do
                -- push names; Factorio’s prototypes exist for prereqs
                table.insert(tech_stack, { depth + 1, pre })
            end
        end

        ::continue::
    end

    if next(sci_packs) == nil then
        return 750, {
            "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
            "production-science-pack", "utility-science-pack", "space-science-pack",
        }
    end

    return count, sci_packs
end
--- takes the new_tech and standardizes it into a regular tech, returning the science ingredients
---@param new_tech data.TechnologyPrototype
---@return table
local function preprocess_tier_1_science_packs(new_tech)
    -- turn new_tech into a standard research pack research and return it's ingredients
    utils.debug('preprocess_tier_1_science_packs for '..new_tech.name)


    -- if it's a trigger technology, then we need to create new science packs that its base tech `should` have
    if new_tech.research_trigger then
        utils.spam('Replacing research trigger')
        new_tech.research_trigger = nil
        local count, sci_packs = get_prerequisite_science_packs_from_tree({ { 0, new_tech } }, 10, {})
        utils.spam('pre-req sci-packs are: '..utils.jsonSerializeTable(sci_packs))
        new_tech.unit = { count = count, time = 60 }
        local ingredients_list = {}
        for _, sci_pack in ipairs(sci_packs) do
            table.insert(ingredients_list, { sci_pack, 1 })
        end
        new_tech.unit.ingredients = ingredients_list
    end

    if not new_tech.unit then -- if no unit for some reason, then add one
        new_tech.unit = { count = 200, time = 60 }
    end
    if not new_tech.unit.ingredients then -- if no ingredients, then add some
        new_tech.unit.ingredients = {{automation-science-pack, 1}}
    end

    return new_tech.unit.ingredients

end

---@param new_tech data.TechnologyPrototype
---@param sci_pack_name string
---@return boolean
local function does_tech_have_sci_pack(new_tech, sci_pack_name)
    -- returns true if `new_tech` has a science pack ingredient of `sci_pack_name`

    -- utils.spam('does_tech_have_sci_pack for ' ..new_tech.name .. ' for ' .. sci_pack_name)
    for i, ingredient in ipairs(new_tech.unit.ingredients) do
        if ingredient[1] == sci_pack_name then
            return true
        end
    end
    return false
end

---@param new_tech data.TechnologyPrototype
---@param sci_pack_name string
---@return boolean (true if successful)
local function try_add_sci_pack_to_ingredients(new_tech, sci_pack_name)
    -- tries to add the science pack name to the new tech's ingredients. True if successful, false if already there

    -- utils.spam('try_add_sci_pack_to_ingredients for ' ..new_tech.name .. ' for ' .. sci_pack_name)

    if does_tech_have_sci_pack(new_tech, sci_pack_name) then
        return false
    end
    table.insert(new_tech.unit.ingredients, {sci_pack_name, 1})
    return true
end

---@param new_tech data.TechnologyPrototype
---@return table (added packs)
local function fill_in_missing_link_sci_packs(new_tech)
    -- if a science has tiers 1 and 3 this will fill in 2. 
    -- Also addresses other gaps so highest tier will cause lower tiers to appear
    -- Does not address cross-stage missing packs
    utils.spam('fill_in_missing_link_sci_packs for '..new_tech.name)

    local added_packs = {}
    local function fill_for_single_tier(new_tech, tier_mapping, loops)
        if loops > 40 then
            utils.error('max loops exceeded in fill_in_missing_link_sci_packs!')
            return
        end
        local changed = false
        for k,v in pairs(tier_mapping) do
            if does_tech_have_sci_pack(new_tech, v.item) then
                if try_add_sci_pack_to_ingredients(new_tech,k) then
                    utils.spam('added '..k..' to ingredients')
                    table.insert(added_packs,k)
                    changed = true
                end
            end
        end
        if changed then
            utils.spam('science packs changed, so looping')
            -- utils.spam(utils.jsonSerializeTable(new_tech.unit.ingredients))
            fill_for_single_tier(new_tech, tier_mapping, loops + 1)
        end
    end

    for _, tier_mapping in ipairs({pre_space_science_tiers,post_space_science_tiers}) do
        fill_for_single_tier(new_tech, tier_mapping, 0)
    end

    utils.spam('added packs are '..utils.jsonSerializeTable(added_packs))
    return added_packs
end

---@param new_tech data.TechnologyPrototype
---@return table
local function fill_in_missing_pre_space_sci_packs(new_tech)
    -- adds every pre-space science pack to the tech if they don't already exist
    utils.spam('try_add_new_sci_pack_from_tier_mapping for '..new_tech.name)
    local added_packs = {}

    for k,v in pairs(pre_space_science_tiers) do
        if try_add_sci_pack_to_ingredients(new_tech,k) then
            utils.spam('added '..k..' as a missing link tech')
            table.insert(added_packs,k)
        end
        if try_add_sci_pack_to_ingredients(new_tech,v.item) then
            utils.spam('added '..v.item..' as a missing link tech')
            table.insert(added_packs,v.item)
        end
    end
    for _,k in ipairs(pre_space_science_additional) do
        if try_add_sci_pack_to_ingredients(new_tech,k) then
            utils.spam('added '..k..' as a missing link tech')
            table.insert(added_packs,k)
        end
    end
    utils.spam('added packs are '..utils.jsonSerializeTable(added_packs))
    return added_packs
end

---@param new_tech data.TechnologyPrototype
---@param tier_mapping table
---@return number
---@return string
local function try_add_new_sci_pack_from_tier_mapping(new_tech, tier_mapping)
    -- looks through the tier_mapping to try and add a next_pack to the new_tech
    -- return ratio, sci_pack_name. if unsuccessful, return 1.0, ''
    utils.spam('try_add_new_sci_pack_from_tier_mapping for '..new_tech.name)

    for k,v in pairs(tier_mapping) do
        if does_tech_have_sci_pack(new_tech,k) then
            if try_add_sci_pack_to_ingredients(new_tech, v.item) then
                return v.ratio, v.item
            end
        end
    end
    return 1.0, ''

end

---@param new_tech data.TechnologyPrototype
---@return number
---@return string
local function try_add_first_space_pack(new_tech)
    utils.spam('try_add_first_space_pack for '..new_tech.name)
    -- determine what the first space pack should be for this tech and tries to add it (shouldn't fail)
    -- return ratio, sci_pack_name. if unsuccessful, return 1.0, ''
    local prod_pack = does_tech_have_sci_pack(new_tech,'production-science-pack')
    local util_pack = does_tech_have_sci_pack(new_tech,'utility-science-pack')

    -- No space packs: choose starting one based on prod/util packs (to not make it all the same)
    if prod_pack and not util_pack then
        added_pack = 'metallurgic-science-pack'
        map = space_next_pack_mapping[added_pack]
    elseif not prod_pack and util_pack then
        added_pack = 'agricultural-science-pack'
        map = space_next_pack_mapping[added_pack]
    else
        added_pack = 'electromagnetic-science-pack'
        map = space_next_pack_mapping[added_pack]
    end
    ratio = map and (map.ratio or 1.0) or 1.0
    if not map then
        return 1.0, ''
    end
    if not try_add_sci_pack_to_ingredients(new_tech,added_pack) then
        return 1.0, ''
    end
    return ratio, added_pack
end

---@param level integer
---@param new_tech data.TechnologyPrototype
---@param new_science_packs_mapping table
---@return table
local function add_next_sci_pack(level, new_tech, new_science_packs_mapping)
    -- reads the current science ingredients to determine the next science pack that should be added. Adds the pack and normalizes things where needed
    -- updates new_science_packs_mapping with the current tier level's added packs
    utils.spam('add_next_sci_pack level '..level..' for '..new_tech.name)

    local added_packs = {}

    local next_sci_pack = ''
    local ratio = 1.0
    -- if it already has a space-pack in ingredients, then fill in any missing packs and go to space pack settings
    local num_space_packs = 0
    for i, ingredient in ipairs(new_tech.unit.ingredients) do
        if utils.list_contains(space_packs,ingredient[1]) then
            num_space_packs = num_space_packs + 1
        end
    end
    if num_space_packs > 0 then
        utils.spam('num_space_packs is > 0')
        -- if we have a space pack, then make sure the previous tier science packs are there
        -- then if only 1 space pack, add another
        -- if 2 or more space packs, we go onto post-space pack logic
        utils.list_extend(added_packs,fill_in_missing_pre_space_sci_packs(new_tech))
        if num_space_packs == 1 then -- one, so add another
            utils.spam('finding next space pack')
            for k,v in pairs(space_next_pack_mapping) do
                if does_tech_have_sci_pack(new_tech,k) then
                    ratio = v.ratio
                    try_add_sci_pack_to_ingredients(new_tech,v.item)
                    next_sci_pack = v.item
                    break
                end
            end
        else -- else, move on to next level (post space)
            utils.spam('moving onto post space packs')
            if not does_tech_have_sci_pack(new_tech, all_space_pack_next.item) then -- try the space to post transition
                ratio = all_space_pack_next.ratio
                try_add_sci_pack_to_ingredients(new_tech,all_space_pack_next.item)
                next_sci_pack = all_space_pack_next.item
            else -- try the post space mapping
                utils.list_extend(added_packs,fill_in_missing_link_sci_packs(new_tech))
                ratio, next_sci_pack = try_add_new_sci_pack_from_tier_mapping(new_tech, post_space_science_tiers)
            end
        end
    else -- else, we have no space packs, so do non-space pack logic
        -- we add a non-sci-pack (or first sci pack (see what old is doing to select new))
        utils.spam('pre-space-pack additions')
        utils.list_extend(added_packs,fill_in_missing_link_sci_packs(new_tech))
        ratio, next_sci_pack = try_add_new_sci_pack_from_tier_mapping(new_tech, pre_space_science_tiers)
        if isempty(next_sci_pack) then -- if we don't have a next science pack, then we need to add a space pack
            utils.spam('trying to add first space pack')
            ratio, next_sci_pack = try_add_first_space_pack(new_tech)
            utils.list_extend(added_packs,fill_in_missing_pre_space_sci_packs(new_tech)) -- fill in pre-space because we are transitioning out
        end
    end

    ratio = ratio * cost_multiplier -- apply the cost multiplier
    if isempty(next_sci_pack) then -- if all else fails, then just increase the cost and go on
        ratio = ratio * cost_multiplier
    end

    -- change the cost now that we have a ratio value
    new_tech.unit.count = math.floor(new_tech.unit.count * ratio)

    -- finally, return new_science_packs_mapping in the form it's expecting
    if not isempty(next_sci_pack) then
        new_science_packs_mapping[level] = {next_sci_pack}
    end
    for _, pack in pairs(added_packs) do
        if not new_science_packs_mapping[level] then
            new_science_packs_mapping[level] = {}
        end
        table.insert(new_science_packs_mapping[level], pack)
    end


    return new_science_packs_mapping
end

---@param level integer
---@param new_tech data.TechnologyPrototype
---@return table
local function generate_science_packs_for_tech(level, new_tech)
    utils.spam('generate_science_packs_for_tech level '..level..' for '..new_tech.name)
    -- expected return: new_science_packs:
    -- {"tier": { '', '', ...}}

    -- first, standardize science packs for the base tech (new_tech is a copy of it)
    local base_science_packs = preprocess_tier_1_science_packs(new_tech)
    utils.spam('base_science_packs from preprocess are '..utils.jsonSerializeTable(base_science_packs))

    -- second, add a new science pack per tier
    local new_science_packs_mapping = {}
    for i=2,level,1 do
        add_next_sci_pack(level,new_tech,new_science_packs_mapping)
    end

    -- finally, return the new packs (so recipe gen can take them into account)
    return new_science_packs_mapping

end

---@param level integer
---@param name string
---@param t1_technology data.TechnologyPrototype
---@return table
local function make_machine_technology(level, name, t1_technology)
    local new_machine_technology = table.deepcopy(t1_technology)
    local old_tech_name = new_machine_technology.name
    if utils.setting_add_tier_icons and (new_machine_technology.icon or new_machine_technology.icons) then
        utils.add_tier_icon_to_proto(new_machine_technology, level)
    end
    new_machine_technology.name = utils.get_machine_name(level, name)
    new_machine_technology.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_technology.localised_description = { "", utils.get_item_localised_name(name), { utils.mod_name .. '.suffix-upgrade' } }

    local new_science_packs = generate_science_packs_for_tech(level, new_machine_technology)

    -- utils.debug('new_science_packs are ' .. utils.jsonSerializeTable(new_science_packs))

    if level == 2 then
        new_machine_technology.prerequisites = { old_tech_name }
    else
        new_machine_technology.prerequisites = { utils.get_machine_name(level - 1, name) }
    end

    if new_science_packs[level] then
        for _, prereq in ipairs(new_science_packs[level]) do
            if not isempty(prereq) then
                table.insert(new_machine_technology.prerequisites, prereq)
            end
        end
    end


    new_machine_technology.effects = { { type = "unlock-recipe", recipe = utils.get_machine_name(level, name) } }


    data.extend({ new_machine_technology })

    utils.spam(new_machine_technology.name .. ' technology is: ' .. utils.jsonSerializeTable(new_machine_technology))

    return new_science_packs
end

---@param level integer
---@param name string
---@param entity data.EntityPrototype
---@param entity_type string
---@param item data.ItemPrototype
---@param technology data.TechnologyPrototype
---@param recipe data.RecipePrototype
local function add_new_machine(level, name, entity, entity_type, item, technology, recipe)
    utils.spam('name: '..utils.jsonSerializeTable(name))
    utils.spam('entity: '..utils.jsonSerializeTable(entity))
    utils.spam('item: '..utils.jsonSerializeTable(item))
    utils.spam('technology: '..utils.jsonSerializeTable(technology))
    utils.spam('recipe: '..utils.jsonSerializeTable(recipe))


    utils.debug('adding new machine: ' .. name .. '-' .. level)

    -- Make the Entity
    utils.debug('adding entity: ' .. name .. '-' .. level)
    make_machine_entity(level, name, entity)

    -- Make Item
    utils.debug('adding item: ' .. name .. '-' .. level)
    make_machine_item(level, name, item)

    -- Add it's Technology
    utils.debug('adding technology: ' .. name .. '-' .. level)
    new_science_packs = make_machine_technology(level, name, technology)

    -- Add it's Recipe
    utils.debug('adding recipe: ' .. name .. '-' .. level)
    make_machine_recipe(level, name, recipe, new_science_packs)
end



local recipes = data.raw.recipe
local items = data.raw.item
local technologies = data.raw.technology

---@param machine_name string
---@param backup_tech string
---@return string
---@return data.TechnologyPrototype
local function find_recipe_technology(machine_name, backup_tech)
    if technologies[machine_name] then
        return machine_name, technologies[machine_name]
    end
    for tech_name, tech_body in pairs(technologies) do
        if tech_body.effects then
            for _, effect in ipairs(tech_body.effects) do
                if effect.type == 'unlock-recipe' and effect.recipe == machine_name then
                    return tech_name, tech_body
                end
            end
        end
    end

    if backup_tech and technologies[backup_tech] then
        utils.debug('using backup technology mapping for machine: ' .. machine_name)
        return backup_tech, technologies[backup_tech]
    end

    utils.debug('failed to find technology for machine: ' .. machine_name)
    return '', {}
end


---@param machine_name string
---@param backup_tech string
function auto_create_tiers.create_machine_tiers(machine_name, backup_tech)
    utils.debug('Creating Machine Tiers For '..machine_name)
    
    local entity_type, machine_entity = utils.find_entity_by_name(machine_name)
    if not entity_type or entity_type == '' then
        utils.error('did not find entity definition for ' .. machine_name)
        return
    end
    local machine_recipe = recipes[machine_name]
    if not machine_recipe then
        utils.error('did not find recipe definition for ' .. machine_name)
        return
    end
    local machine_item = items[machine_name]
    if not machine_item then
        utils.error('did not find item definition for ' .. machine_name)
        return
    end

    local machine_technology_name, machine_technology = find_recipe_technology(machine_name, backup_tech)

    if machine_technology_name then
        utils.debug('found ' .. machine_name .. ' technology: ' .. machine_technology_name)
    else
        utils.error('did not find technology definition for ' .. machine_name)
        return
    end

    add_new_machine(2, machine_name, machine_entity, entity_type, machine_item, machine_technology, machine_recipe)
    add_new_machine(3, machine_name, machine_entity, entity_type, machine_item, machine_technology, machine_recipe)
end

---@param machine_name string
function auto_create_tiers.recreate_entities(machine_name)
    utils.debug('Recreating Machine Entities For '..machine_name)
    if machine_name == 'electric-lumber-mill' then -- skip manual ones
        goto recreate_entities_end
    end 

    local entity_type, base_machine_entity = utils.find_entity_by_name(utils.get_machine_name(1,machine_name))
    if not entity_type or entity_type == '' then
        utils.error('did not find entity definition for ' .. machine_name)
        return
    end
    for i=2,3,1 do
        -- Remove Current Entity
        --     find entity
        local tiered_name = utils.get_machine_name(i, machine_name)
        local old_entity_type, old_machine_entity = utils.find_entity_by_name(tiered_name)
        if not old_entity_type or old_entity_type == '' then
            utils.error('did not find entity definition for ' .. machine_name)
            return
        end

        --     save upgrade planner changes
        local fast_replace_group = old_machine_entity.fast_replaceable_group
        local next_upgrade = old_machine_entity.next_upgrade


        --     delete entity
        data.raw[old_entity_type][tiered_name] = null

        -- Remake the Entity
        utils.debug('adding entity: ' .. machine_name .. '-' .. i)
        make_machine_entity(i, machine_name, base_machine_entity)

        --    reapply upgrade planner changes
        local new_entity_type, new_machine_entity = utils.find_entity_by_name(tiered_name)
        if not new_entity_type or new_entity_type == '' then
            utils.error('did not find entity definition for ' .. machine_name)
            return
        end
        if fast_replace_group then
            new_machine_entity.fast_replaceable_group = fast_replace_group
        end
        if next_upgrade then
            new_machine_entity.next_upgrade = next_upgrade
        end

    end
    ::recreate_entities_end::
end


return auto_create_tiers
