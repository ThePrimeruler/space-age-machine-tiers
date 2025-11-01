local function space_platform_constants(utils)
    utils.constants.space_age_machine_list = {
        'agricultural-tower',
        'big-mining-drill',
        'biochamber',
        'biolab',
        'cryogenic-plant',
        'electromagnetic-plant',
        'foundry',
        'lightning-collector',
        'lightning-rod',
        'recycler',
        'stack-inserter',
        'heating-tower',
        'fusion-generator',
        'fusion-reactor',
    }
    for _, name in ipairs(utils.constants.space_age_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end
end

return space_platform_constants