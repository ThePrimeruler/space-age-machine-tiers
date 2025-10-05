local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Space Platform Machine Tiers')

local space_platform_machine_list = utils.constants.space_platform_machine_list

local backup_space_platform_machine_tech_mapping = {
    ['thruster'] = 'space-platform-thruster',
    ['crusher'] = 'space-platform',
    ['asteroid-collector'] = 'space-platform',
    ['cargo-bay'] = 'space-platform',
    ['rocket-silo'] = 'rocket-silo',
}

for _, machine_name in ipairs(space_platform_machine_list) do

    -- local type, proto = utils.find_entity_by_name(machine_name)
    -- utils.debug(machine_name..' type is '..type)
    -- utils.debug(utils.jsonSerializeTable(proto,machine_name))

    auto_create_tiers.create_machine_tiers(machine_name,backup_space_platform_machine_tech_mapping[machine_name])

end
