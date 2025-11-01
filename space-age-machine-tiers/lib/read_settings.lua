local function read_settings(utils)
    if utils == nil then
        error('read_settings: utils is nil')
    end

    ---@type boolean 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_use_tints = settings.startup[utils.mod_name.."-use-tints"].value
    ---@type number float 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_cost_mult = settings.startup[utils.mod_name.."-cost-multiplier"].value



    ---@type boolean 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_do_space_platform_tiers = settings.startup[utils.mod_name.."-do-space-platform-tiers"].value
    ---@type boolean 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_do_military_tiers = settings.startup[utils.mod_name.."-do-military-tiers"].value



    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_speed_mult = settings.startup[utils.mod_name.."-speed-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_energy_mult = settings.startup[utils.mod_name.."-energy-usage-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_pollution_mult = settings.startup[utils.mod_name.."-pollution-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_health_mult = settings.startup[utils.mod_name.."-health-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_range_mult = settings.startup[utils.mod_name.."-range-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_tank_mult = settings.startup[utils.mod_name.."-tank-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_storage_mult = settings.startup[utils.mod_name.."-storage-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_beacon_dist_mult = settings.startup[utils.mod_name.."-beacon-distribution-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_thruster_performance_mult = settings.startup[utils.mod_name.."-thruster-performance-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_damage_mult = settings.startup[utils.mod_name.."-damage-multiplier-per-tier"].value
    ---@type number float
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_special_effect_mult = settings.startup[utils.mod_name.."-special-effect-multiplier-per-tier"].value




    ---@type number integer 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_module_mod = settings.startup[utils.mod_name.."-module-slots-per-tier"].value
    ---@type number integer 
    ---@diagnostic disable-next-line: assign-type-mismatch
    utils.setting_agg_radius_mod = settings.startup[utils.mod_name.."-agg-radius-per-tier"].value


    if mods["boblogistics"] then
        if settings.startup[utils.mod_name.."-fix-bob-turbo-belts"].value then
            utils.fix_bob_turbo_belts = true
        end
    end

    if mods["Age-of-Production"] then
        if settings.startup[utils.mod_name.."-add-aop-machines"].value then
            utils.do_aop = true
        end
    end
    if mods["lignumis"] then
        if settings.startup[utils.mod_name.."-add-lignumis-machines"].value then
            utils.do_lignumis = true
        end
        ---@type boolean 
        ---@diagnostic disable-next-line: assign-type-mismatch
        utils.setting_lignumis_add_electric_lumber_mills = settings.startup[utils.mod_name.."-lignumis-add-electric-lumber-mills"].value
    end
    if mods["planet-muluna"] then
        if settings.startup[utils.mod_name.."-add-muluna-machines"].value then
            utils.do_muluna = true
        end
    end

    if mods["maraxsis"] then
        if settings.startup[utils.mod_name.."-add-maraxsis-machines"].value then
            utils.do_maraxsis = true
        end
    end

end

return read_settings