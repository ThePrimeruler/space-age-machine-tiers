local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Military Tiers')

local military_machine_list = utils.constants.military_machine_list

local backup_military_machine_tech_mapping = {
    ['gun-turret'] = 'gun-turret',
    ['laser-turret'] = 'laser-turret',
    ['flamethrower-turret'] = 'flamethrower-turret',
    -- ['artillery-turret'] = 'artillery-turret',
    ['rocket-turret'] = 'rocket-turret',
    ['tesla-turret'] = 'tesla-turret',
}

for _, machine_name in ipairs(military_machine_list) do

    -- local type, proto = utils.find_entity_by_name(machine_name)
    -- utils.debug(machine_name..' type is '..type)
    -- utils.debug(utils.jsonSerializeTable(proto,machine_name))

    auto_create_tiers.create_machine_tiers(machine_name,backup_military_machine_tech_mapping[machine_name])

end
