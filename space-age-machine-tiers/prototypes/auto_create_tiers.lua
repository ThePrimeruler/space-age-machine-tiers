local utils = require("lib.utils")

local auto_create_tiers = {}

local cost_multiplier = utils.setting_recipe_cost_mult

local material_to_next_tier_map = utils.constants.material_to_next_tier_map

local science_material_to_next_tier_map = utils.constants.science_material_to_next_tier_map

local space_packs = utils.constants.space_packs

local science_to_next_tier_map = utils.constants.science_to_next_tier_map

local space_next_pack_mapping = utils.constants.space_next_pack_mapping

local tech_to_sci_pack_map = utils.constants.tech_to_sci_pack_map

local entity_types = utils.constants.entity_types


---@param level number int
---@param entity table
---@param key string | table
---@param modifier number
---@param is_mult bool
---@param floor bool
local function if_exist_modify(level, entity, key, modifier, is_mult, floor)
    ---@param the_entity table
    ---@param the_key string | table
    local function get_value(the_entity, the_key)
        if type(the_key) == "string" then
            return the_entity[the_key]
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


local function make_machine_entity(level, name, entity)
    local new_machine = table.deepcopy(entity)

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

    -- inserter
    if_exist_modify(level, new_machine, 'extension_speed', utils.setting_speed_mult, true, false)
    --(rotation speed already covered)

    -- Turbines
    if_exist_modify(level, new_machine, { 'energy_source', 'output_flow_limit', }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, 'max_fluid_usage', utils.setting_energy_mult, true, false)

    -- Energy Settings
    if_exist_modify(level, new_machine, { 'energy_source', 'buffer_capacity', }, utils.setting_energy_mult, true, false)
    if_exist_modify(level, new_machine, { 'energy_source', 'input_flow_limit', }, utils.setting_energy_mult, true, false)

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

local function make_machine_item(level, name, item)
    local new_machine_item = table.deepcopy(item)
    new_machine_item.name = utils.get_machine_name(level, name)
    new_machine_item.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_item.localised_description = { "", utils.get_item_localised_description(name) }
    new_machine_item.place_result = utils.get_machine_name(level, name)
    if new_machine_item.order then
        new_machine_item.order = new_machine_item.order .. '-b'
    else
        new_machine_item.order = name .. '-b'
    end
    data.extend({ new_machine_item })
end



local function update_recipe_materials(recipe, current_level, new_science_packs)
    -- material_to_next_tier_map
    -- science_material_to_next_tier_map

    local current_new_science_packs = new_science_packs[current_level]

    if not current_new_science_packs then
        current_new_science_packs = {}
    end

    local material_mapping = table.deepcopy(material_to_next_tier_map)

    for _, sci_pack in ipairs(current_new_science_packs) do
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
                        else
                            target_map = nil -- skip entirely
                        end
                        break
                    end
                end
            end

            -- insert only if we found a valid target_map
            if target_map then
                local final_amount = math.max(average_amount, target_map.ratio)
                table.insert(recipe.ingredients, {
                    type   = "item",
                    name   = target_map.item,
                    amount = final_amount
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

local function make_machine_recipe(level, name, recipe, new_science_packs)
    --new_science_packs is table in format: {[level] = sci_packs}
    --      sci_packs being {sci_pack_name,...}

    local new_machine_recipe = table.deepcopy(recipe)
    new_machine_recipe.name = utils.get_machine_name(level, name)

    new_machine_recipe.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_recipe.localised_description = { "", utils.get_item_localised_description(name) }

    if new_machine_recipe.energy_required then
        new_machine_recipe.energy_required = new_machine_recipe.energy_required * cost_multiplier
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


local function add_mapped_pack(sci_packs, mapped)
    if not mapped then return end
    if type(mapped) == "table" then
        for _, p in ipairs(mapped) do
            if p and not utils.list_contains(sci_packs, p) then
                table.insert(sci_packs, p)
            end
        end
    else
        if not utils.list_contains(sci_packs, mapped) then
            table.insert(sci_packs, mapped)
        end
    end
end


local function get_prerequisite_science_packs(tech_stack, count, sci_packs, visited)
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
                -- walk backwards through science_to_next_tier_map to add all prior packs
                local function add_with_prereqs(pack, seen_back)
                    seen_back = seen_back or {}
                    if not pack or seen_back[pack] then return end
                    seen_back[pack] = true
                    if not utils.list_contains(sci_packs, pack) then table.insert(sci_packs, pack) end
                    for pre, m in pairs(science_to_next_tier_map) do
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

local function advance_packs_once(current_packs)
    local new_packs = {}
    local seen = {}
    local ratio = 1.0

    for pack, _ in pairs(current_packs) do
        local cursor = science_to_next_tier_map[pack]

        -- skip forward through already owned packs
        while cursor and current_packs[cursor.item] do
            cursor = science_to_next_tier_map[cursor.item]
        end

        -- now cursor points at the first missing pack in this chain
        while cursor and not seen[cursor.item] and not current_packs[cursor.item] do
            new_packs[cursor.item] = true
            seen[cursor.item] = true
            ratio = math.max(ratio, cursor.ratio or 1.0)
            -- advance further, in case multiple tiers are missing in a row
            cursor = science_to_next_tier_map[cursor.item]
            -- stop early if the next in the chain is already owned
            while cursor and current_packs[cursor.item] do
                cursor = science_to_next_tier_map[cursor.item]
            end
        end
    end

    return new_packs, ratio
end


local function find_next_science_pack(level, new_technology, new_science_packs, current_level)
    -- Looks at the Level 1 (Tier1)'s technologies and tries to find the `next` techpack to add the technology for the current tier
    -- First Gets The Techpacks of the base technology
    -- Then Sees if it can get a new tech from `science_to_next_tier_map`
    -- If it can't find one, then that means we need to check space packs to see if we should add one instead
    -- If we can't find a techpack, it instead just increases the cost


    -- if it's a trigger technology, then we need to create new science packs that its base tech `should` have
    if new_technology.research_trigger then
        new_technology.research_trigger = nil
        local count, sci_packs = get_prerequisite_science_packs({ { 0, new_technology } }, 10, {})
        new_technology.unit = { count = count, time = 60 }
        local ingredients_list = {}
        for _, sci_pack in ipairs(sci_packs) do
            table.insert(ingredients_list, { sci_pack, 1 })
        end
        new_technology.unit.ingredients = ingredients_list

        -- record what Tier-1 uses
        new_science_packs[current_level] = sci_packs
    end

    if current_level > level then
        return new_science_packs
    end

    -- Collect current packs and convert to a lookup for faster membership
    local current_packs = {}
    for _, ing in ipairs(new_technology.unit.ingredients) do
        local pack = ing[1] or ing.name
        current_packs[pack] = true
    end

    -- go through the initial mapping (also find skipped sci-packs)
    local next_packs, ratio = advance_packs_once(current_packs)

    -- utils.debug('advance_packs_once next_packs response: '..utils.jsonSerializeTable(next_packs))


    if next(next_packs) == nil then
        local added_pack
        local map
        local prod_pack = current_packs['production-science-pack']
        local util_pack = current_packs['utility-science-pack']

        -- Count how many space packs we already have
        local space_pack_count = 0
        for _, sp in ipairs(space_packs) do
            if current_packs[sp] then
                space_pack_count = space_pack_count + 1
            end
        end


        -- if we have enough space (max of two before moving on) science packs, add higher tier
        if space_pack_count > 1 then
            -- Try the special all_space mapping (see if you can add cryogenic if we have enough pre-requisites)
            map = science_to_next_tier_map['all_space']
            if map and not current_packs[map.item] then
                added_pack = map.item
                ratio = map.ratio or 1.0
            end
        elseif space_pack_count == 0 then
            -- No space packs: choose starting one based on prod/util packs
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
        else
            -- Exactly 1 space pack: continue its progression
            for pack, _ in pairs(current_packs) do
                map = space_next_pack_mapping[pack]
                if map and not current_packs[map.item] then
                    added_pack = map.item
                    ratio = map.ratio or 1.0
                    break
                end
            end
        end

        if added_pack then
            next_packs[added_pack] = true
        end
    end

    -- Adjust count and add pack(s)
    if next(next_packs) ~= nil then
        new_science_packs[current_level] = {}
        for pack, _ in pairs(next_packs) do
            table.insert(new_technology.unit.ingredients, { pack, 1 })
            table.insert(new_science_packs[current_level], pack)
        end
    else
        new_science_packs[current_level] = {}
    end

    new_technology.unit.count = math.floor(new_technology.unit.count * cost_multiplier * ratio)

    -- Recurse to next lower level
    return find_next_science_pack(level, new_technology, new_science_packs, current_level + 1)
end


local function make_machine_technology(level, name, t1_technology)
    local new_machine_technology = table.deepcopy(t1_technology)
    local old_tech_name = new_machine_technology.name
    new_machine_technology.name = utils.get_machine_name(level, name)
    new_machine_technology.localised_name = { "", utils.get_item_localised_name(name), ' ' .. level }
    new_machine_technology.localised_description = { "", utils.get_item_localised_name(name), { utils.mod_name .. '.suffix-upgrade' } }


    local new_science_packs = find_next_science_pack(level, new_machine_technology, {}, 2) -- Needs To Be Before The prerequisites Update

    -- utils.debug('new_science_packs are ' .. utils.jsonSerializeTable(new_science_packs))

    if level == 2 then
        new_machine_technology.prerequisites = { old_tech_name }
    else
        new_machine_technology.prerequisites = { utils.get_machine_name(level - 1, name) }
    end

    if new_science_packs[level] then
        for _, prereq in ipairs(new_science_packs[level]) do
            table.insert(new_machine_technology.prerequisites, prereq)
        end
    end


    new_machine_technology.effects = { { type = "unlock-recipe", recipe = utils.get_machine_name(level, name) } }


    data.extend({ new_machine_technology })

    return new_science_packs
end

local function add_new_machine(level, name, entity, entity_type, item, technology, recipe)
    -- utils.debug('name: '..utils.jsonSerializeTable(name))
    -- utils.debug('entity: '..utils.jsonSerializeTable(entity))
    -- utils.debug('item: '..utils.jsonSerializeTable(item))
    -- utils.debug('technology: '..utils.jsonSerializeTable(technology))
    -- utils.debug('recipe: '..utils.jsonSerializeTable(recipe))


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



function auto_create_tiers.create_machine_tiers(machine_name, backup_tech)
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


return auto_create_tiers
