local function military_constants(utils)
    utils.constants.military_machine_list = {
        'gun-turret',
        'laser-turret',
        'flamethrower-turret',
        -- 'artillery-turret',
        'rocket-turret',
        'tesla-turret',
    }
    for _, name in ipairs(utils.constants.military_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end

    -- add the turrets to their upgrade group
    table.insert(utils.constants.physical_projectile_research_list,'gun-turret')
    table.insert(utils.constants.refined_flammables_research_list,'flamethrower-turret')


end

return military_constants