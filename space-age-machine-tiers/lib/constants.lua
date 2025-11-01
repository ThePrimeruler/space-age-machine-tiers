local recipe_and_tech_constants = require('lib.constants_recipe_tech')

local function get_constants(utils)
    utils.constants = {}

    utils.constants.added_machine_tier_1 = {
    }

    utils.constants.physical_projectile_research_list = {}
    utils.constants.refined_flammables_research_list = {}


    utils.constants.entity_types = {
        'agricultural-tower',
        'furnace',
        'assembling-machine',
        'lab',
        'beacon',
        'lightning-attractor',
        'mining-drill',
        'storage-tank',
        'ammo-turret',
        'electric-turret',
        'fluid-turret',
        -- 'artillery-turret',
        'rocket-silo',
        'cargo-bay',
        'asteroid-collector',
        'thruster',
        'inserter',
        'reactor',
        'boiler',
        'generator',
        'fusion-generator',
        'fusion-reactor',
        'burner-generator',
    }

    utils.constants.pollution_types = {
        'pollution',
        'spores',
    }

    -- List Of Machine Names (Base) added by this mod
    utils.constants.every_machine_list = {}

    -- load in the recipe and tech constants into the utils.constants table
    recipe_and_tech_constants(utils)


    -- space age additions
    require('prototypes.space_age.base_machines_constants')(utils) -- import and call the constants function
    if utils.setting_do_military_tiers then
        require('prototypes.space_age.military.military_constants')(utils) -- import and call the constants function
    end
    if utils.setting_do_space_platform_tiers then
        require('prototypes.space_age.space_platform.space_platform_constants')(utils) -- import and call the constants function
    end


    -- mod support constants
    if utils.do_aop then
        require('prototypes.age_of_production.aop_constants')(utils) -- import and call the constants function
    end
    if utils.do_lignumis then
        require('prototypes.lignumis.lignumis_constants')(utils) -- import and call the constants function
    end
    if utils.do_maraxsis then
        require('prototypes.maraxsis.maraxsis_constants')(utils) -- import and call the constants function
    end
    if utils.do_muluna then
        require('prototypes.muluna.muluna_constants')(utils) -- import and call the constants function
    end
end

return get_constants
