local function aop_constants(utils)
    utils.constants.aop_machine_list = {
        "aop-arc-furnace",
        "aop-atomic-enricher",
        "aop-biochemical-facility",
        "aop-electromechanic-facility",
        "aop-greenhouse",
        "aop-hydraulic-plant",
        "aop-lumber-mill",
        "aop-petrochemical-facility",
        "aop-quantum-assembler",
        "aop-quantum-computer",
        "aop-quantum-stabilizer",
        "aop-scrubber",
        "aop-smeltery",
        "aop-salvager",
        "aop-advanced-assembling-machine",
        "aop-core-miner",
        "aop-armory",
        "aop-mineral-synthesizer",
        "aop-biomass-reactor",
        "aop-transmitter",
    }

    if mods['lignumis'] and (settings.startup['aop-merge-hydro'] and settings.startup['aop-merge-hydro'].value) then
        -- utils.info('Removing the Age Of Production Lumber Mill Upgrades Because Lignumis Is Installed')
        utils.table_remove_by_value(utils.constants.aop_machine_list,'aop-lumber-mill')
    end

    if mods['maraxsis'] and (settings.startup['aop-merge-lignumis-lumber-mill'] and settings.startup['aop-merge-lignumis-lumber-mill'].value) then
        -- utils.info('Removing the Age Of Production Hydraulic Plant Upgrades Because Maraxsis Is Installed')
        utils.table_remove_by_value(utils.constants.aop_machine_list,'aop-hydraulic-plant')
    end

    for _, name in ipairs(utils.constants.aop_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end
end

return aop_constants