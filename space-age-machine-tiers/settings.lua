local utils = require("lib.utils")


if mods["boblogistics"] then
    data:extend({
    -- Startup settings
        {
            type = "bool-setting",
            name = utils.mod_name.."-fix-bob-turbo-belts",
            setting_type = "startup",
            default_value = true,
            order = "a-a",
        },
    })
end
if mods["Age-of-Production"] then
    data:extend({
    -- Startup settings
        {
            type = "bool-setting",
            name = utils.mod_name.."-add-aop-machines",
            setting_type = "startup",
            default_value = true,
            order = "a-mod",
        },
    })
end
if mods["lignumis"] then
    data:extend({
    -- Startup settings
        {
            type = "bool-setting",
            name = utils.mod_name.."-add-lignumis-machines",
            setting_type = "startup",
            default_value = true,
            order = "a-mod",
        },
        {
            type = "bool-setting",
            name = utils.mod_name.."-lignumis-add-electric-lumber-mills",
            setting_type = "startup",
            default_value = true,
            order = "a-mod",
        },
    })
end
if mods["planet-muluna"] then
    data:extend({
    -- Startup settings
        {
            type = "bool-setting",
            name = utils.mod_name.."-add-muluna-machines",
            setting_type = "startup",
            default_value = true,
            order = "a-mod",
        },
    })
end
if mods["maraxsis"] then
    data:extend({
    -- Startup settings
        {
            type = "bool-setting",
            name = utils.mod_name.."-add-maraxsis-machines",
            setting_type = "startup",
            default_value = true,
            order = "a-mod",
        },
    })
end

data:extend({
-- Startup settings

    {
        type = "bool-setting",
        name = utils.mod_name.."-use-tints",
        setting_type = "startup",
        default_value = false,
        order = "a-a",
    },
    {
        type = "bool-setting",
        name = utils.mod_name.."-do-space-platform-tiers",
        setting_type = "startup",
        default_value = true,
        order = "a-b",
    },
    {
        type = "bool-setting",
        name = utils.mod_name.."-do-military-tiers",
        setting_type = "startup",
        default_value = true,
        order = "a-b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-cost-multiplier",
        setting_type = "startup",
        default_value = 2.0,
        minimum_value = 0.001,
        order = "a-b",
    },
    { 
        type = "double-setting",
        name = utils.mod_name.."-speed-multiplier-per-tier",
        setting_type = "startup",
        default_value = 2.0,
        minimum_value = 0.001,
        order = "b",
    },
    { 
        type = "double-setting",
        name = utils.mod_name.."-energy-usage-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.8,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-pollution-multiplier-per-tier",
        setting_type = "startup",
        default_value = 0.8,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-health-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.5,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-range-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.5,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-tank-multiplier-per-tier",
        setting_type = "startup",
        default_value = 2.0,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-storage-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.5,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-beacon-distribution-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.25,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-thruster-performance-per-tier",
        setting_type = "startup",
        default_value = 1.5,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-damage-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.5,
        minimum_value = 0.001,
        order = "b",
    },
    {
        type = "double-setting",
        name = utils.mod_name.."-special-effect-multiplier-per-tier",
        setting_type = "startup",
        default_value = 1.2,
        minimum_value = 0.001,
        order = "b",
    },

    { 
        type = "int-setting",
        name = utils.mod_name.."-module-slots-per-tier",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0,
        order = "b",
    },
    { 
        type = "int-setting",
        name = utils.mod_name.."-agg-radius-per-tier",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0,
        order = "b",
    },
})

