local function muluna_constants(utils)
    utils.constants.muluna_machine_list = {
        'crusher-2',
        -- 'cryolab',
        'muluna-advanced-boiler',
        'muluna-cycling-steam-turbine',
        -- 'muluna-vacuum-heating-tower',
        'muluna-steam-crusher',
        -- 'muluna-greenhouse-wood',

    }
    for _, name in ipairs(utils.constants.muluna_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end
end

return muluna_constants