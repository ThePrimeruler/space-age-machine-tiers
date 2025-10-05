local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Maraxsis Machine Tiers')

local maraxsis_machine_list = utils.constants.maraxsis_machine_list

local backup_maraxsis_machine_tech_mapping = {
    ['maraxsis-hydro-plant']='maraxsis-hydro-plant',
    ['maraxsis-fishing-tower']='maraxsis-piscary',
    ['maraxsis-conduit']='maraxsis-conduit',
}


for _, machine_name in ipairs(maraxsis_machine_list) do

    -- local type, proto = utils.find_entity_by_name(machine_name)
    -- utils.debug(machine_name..' type is '..type)
    -- utils.debug(utils.jsonSerializeTable(proto,machine_name))


    auto_create_tiers.create_machine_tiers(machine_name,backup_maraxsis_machine_tech_mapping[machine_name])

end

