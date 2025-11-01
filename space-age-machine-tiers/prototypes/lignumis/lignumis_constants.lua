local function lignumis_constants(utils)
    utils.constants.lignumis_machine_list = {
        'deep-miner',
        'desiccation-furnace',
        'lumber-mill',
        'gold-storage-tank',
    }

    if utils.setting_lignumis_add_electric_lumber_mills then
        table.insert(utils.constants.lignumis_machine_list,'electric-lumber-mill')
        table.insert(utils.constants.added_machine_tier_1,'electric-lumber-mill')
    end

    for _, name in ipairs(utils.constants.lignumis_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end

    table.insert(utils.constants.pollution_types,'noise')

    -- lignumis, has new sci-packs
    for k,v in pairs({
        ['wood-science-pack'] = {
            item='steam-science-pack', ratio=1.0
        },
        ['steam-science-pack'] = {
            item='automation-science-pack', ratio=2.0
        },
    }) do
        utils.constants.pre_space_science_tiers[k] = v
    end
end

return lignumis_constants