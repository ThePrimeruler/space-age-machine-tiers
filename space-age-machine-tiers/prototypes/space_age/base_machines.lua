local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Base Machine Tiers')

local space_age_machine_list = utils.constants.space_age_machine_list

local backup_machine_tech_mapping = {
    ['agricultural-tower'] = 'agricultural-tower',
    ['big-mining-drill'] = 'big-mining-drill',
    ['biochamber'] = 'biochamber',
    ['biolab'] = 'biolab',
    ['cryogenic-plant'] = 'cryogenic-plant',
    ['electromagnetic-plant'] = 'electromagnetic-plant',
    ['foundry'] = 'foundry',
    ['lightning-collector'] = 'lightning-collector',
    ['lightning-rod'] = 'lightning-rod',
    ['recycler'] = 'recycler',
    ['stack-inserter'] = 'stack-inserter',
    ['heating-tower'] = 'heating-tower',
}

for _, machine_name in ipairs(space_age_machine_list) do

    auto_create_tiers.create_machine_tiers(machine_name,backup_machine_tech_mapping[machine_name])

end
