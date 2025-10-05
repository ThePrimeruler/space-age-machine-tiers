local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Muluna Machine Tiers')

local muluna_machine_list = utils.constants.muluna_machine_list

local backup_muluna_machine_tech_mapping = {
    ['crusher-2'] = 'crusher-2',
    -- ['cryolab'] = 'cryolab',
    -- ['muluna-greenhouse'] = 'muluna-greenhouse',
    -- ['muluna-greenhouse-wood'] = 'muluna-greenhouse-wood',
    ['muluna-advanced-boiler'] = 'muluna-advanced-boiler',
    ['muluna-cycling-steam-turbine'] = 'muluna-cycling-steam-turbine',
    -- ['muluna-vacuum-heating-tower'] = 'muluna-vacuum-heating-tower',
    ['muluna-steam-crusher'] = 'muluna-steam-crusher',
}


for _, machine_name in ipairs(muluna_machine_list) do

    auto_create_tiers.create_machine_tiers(machine_name,backup_muluna_machine_tech_mapping[machine_name])

    ::continue::
end

