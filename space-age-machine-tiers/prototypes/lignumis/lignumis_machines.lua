local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Lignumis Machine Tiers')

local lignumis_machine_list = utils.constants.lignumis_machine_list

local backup_lignumis_machine_tech_mapping = {
    ['deep-miner'] = 'deep-miner',
    ['desiccation-furnace'] = 'gold-fluid-handling',
    ['lumber-mill'] = 'lumber-mill',
    ['gold-storage-tank'] = 'gold-fluid-handling',
}


for _, machine_name in ipairs(lignumis_machine_list) do
    if machine_name == 'electric-lumber-mill' then
        goto continue
    end

    auto_create_tiers.create_machine_tiers(machine_name,backup_lignumis_machine_tech_mapping[machine_name])

    ::continue::
end
