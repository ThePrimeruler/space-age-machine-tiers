local function space_platform_constants(utils)
    utils.constants.space_platform_machine_list = {
        'thruster',
        'crusher',
        'asteroid-collector',
        'cargo-bay',
        'rocket-silo',
    }
    for _, name in ipairs(utils.constants.space_platform_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end
end

return space_platform_constants