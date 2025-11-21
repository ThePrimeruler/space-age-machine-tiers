local function base_game_constants(utils)
    utils.constants.base_game_machine_list = {
        'beacon',
        'radar'
    }
    for _, name in ipairs(utils.constants.base_game_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end


end

return base_game_constants