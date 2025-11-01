local utils = require("lib.utils")

-- NOTE: Entity Definitions are deleted and recreated in the data-final-fixes stage, so may have to update changes made here there if relying on entity changes


-- Update the upgrade_planner

    -- handle electric_lumber_mill edge case
if utils.do_lignumis and utils.setting_lignumis_add_electric_lumber_mills then
    -- make lumber-mills and electric-lumber-mills share the same upgrade planner state
    local lumber_mill = 'lumber-mill'
    local fast_replaceable_group = utils.get_machine_name(1,lumber_mill)
    local lumber_mill_entity_type, lumber_mill_entity = utils.find_entity_by_name(lumber_mill)
    if not lumber_mill_entity_type or lumber_mill_entity_type=='' then
        utils.error('did not find entity definition for  "'..tostring(lumber_mill)..'"')
        goto continue
    end

    local electric_lumber_mill = 'electric-lumber-mill'
    local electric_lumber_mill_entity_type, electric_lumber_mill_entity = utils.find_entity_by_name(utils.get_machine_name(1,(electric_lumber_mill)))
    if not electric_lumber_mill_entity_type or electric_lumber_mill_entity_type=='' then
        utils.error('did not find entity definition for  "'..tostring(electric_lumber_mill)..'"')
        goto continue
    end

    if lumber_mill_entity["fast_replaceable_group"] then
        fast_replaceable_group = lumber_mill_entity["fast_replaceable_group"]
    end

    -- finally, update the fast replace groups
    data.raw[lumber_mill_entity_type][utils.get_machine_name(1,lumber_mill)]["fast_replaceable_group"] = fast_replaceable_group
    data.raw[electric_lumber_mill_entity_type][utils.get_machine_name(1,electric_lumber_mill)]["fast_replaceable_group"] = fast_replaceable_group


    ::continue::
end



local function update_upgrade_planner_data(name, entity_type)

    local fast_replaceable_group = utils.get_machine_name(1,name)
    utils.debug('t1 name: '..fast_replaceable_group)
    -- utils.debug('entity_type raw value: "' .. tostring(entity_type) .. '"')
    -- utils.debug('data.raw[entity_type]: '..tostring(data.raw[entity_type]))
    local tier1 = data.raw[entity_type][utils.get_machine_name(1,name)]

    if not tier1 then
        error('tier1 is not valid!!')
    end
    if not data.raw[entity_type][utils.get_machine_name(2,name)] then
        utils.error('tier2 is not valid, skipping')
        return
    end

    if tier1["fast_replaceable_group"] then
        fast_replaceable_group = tier1["fast_replaceable_group"]
    end

    utils.debug(tostring(name)..' fast_replaceable_group is '..tostring(fast_replaceable_group))

    -- put them in the same group (fast_replaceable_group means you can select them in the upgrade planner from eachother)
    tier1["fast_replaceable_group"] = fast_replaceable_group
    data.raw[entity_type][utils.get_machine_name(2,name)]["fast_replaceable_group"] = fast_replaceable_group
    data.raw[entity_type][utils.get_machine_name(3,name)]["fast_replaceable_group"] = fast_replaceable_group


    -- define the 'next upgrade' (next upgrade defines the auto-upgrade behavior)
    local tier1_item = data.raw.item[utils.get_machine_name(1,name)]
    if tier1.hidden then
        utils.warning("not adding next_upgrade to " .. name .. " because it is hidden.")
    elseif tier1_item and tier1_item.hidden then
        utils.warning("not adding next_upgrade to " .. name .. " because its item is hidden.")
    elseif tier1.next_upgrade then
        utils.info("not adding next_upgrade to " .. name .. " because it already has an upgrade.")
    else
        tier1["next_upgrade"] = utils.get_machine_name(2,name)
    end
    data.raw[entity_type][utils.get_machine_name(2,name)]["next_upgrade"] = utils.get_machine_name(3,name)

end



local machine_list = utils.constants.every_machine_list

for _, machine_name in ipairs(machine_list) do
    local real_name = utils.get_machine_name(1,machine_name)
    utils.debug('checking "' .. tostring(real_name) .. '"')
    local entity_type, machine_entity = utils.find_entity_by_name(real_name)
    utils.debug('entity_type is: "' .. tostring(entity_type) .. '"')
    -- utils.debug('entity_type length: ' .. tostring(#entity_type or 'nil'))
    if not entity_type or entity_type=='' then
        utils.error('did not find entity definition for  "'..tostring(real_name)..'"')
        goto continue
    end

    utils.debug('updating upgrade planner data: "'..tostring(machine_name)..'"')
    update_upgrade_planner_data(machine_name, entity_type)

    ::continue::
end




