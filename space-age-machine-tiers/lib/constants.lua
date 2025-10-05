local function get_constants(utils)
    utils.constants = {}

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
    }

    utils.constants.added_machine_tier_1 = {
    }

    if utils.setting_do_space_platform_tiers then
        utils.constants.space_platform_machine_list = {
            'thruster',
            'crusher',
            'asteroid-collector',
            'cargo-bay',
            'rocket-silo',
        }
    end

    utils.constants.physical_projectile_research_list = {}
    utils.constants.refined_flammables_research_list = {}

    if utils.setting_do_military_tiers then
        utils.constants.military_machine_list = {
            'gun-turret',
            'laser-turret',
            'flamethrower-turret',
            -- 'artillery-turret',
            'rocket-turret',
            'tesla-turret',
        }
        table.insert(utils.constants.physical_projectile_research_list,'gun-turret')
        table.insert(utils.constants.refined_flammables_research_list,'flamethrower-turret')

    end


    if utils.do_aop then
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
        }
        if mods['lignumis'] then
            -- utils.info('Removing the Age Of Production Lumber Mill Upgrades Because Lignumis Is Installed')
            utils.table_remove_by_value(utils.constants.aop_machine_list,'aop-lumber-mill')
        end 
        if mods['maraxsis'] then
            -- utils.info('Removing the Age Of Production Hydraulic Plant Upgrades Because Maraxsis Is Installed')
            utils.table_remove_by_value(utils.constants.aop_machine_list,'aop-hydraulic-plant')
        end
    end

    if utils.do_lignumis then
        utils.constants.lignumis_machine_list = {
            'deep-miner',
            'desiccation-furnace',
            'lumber-mill',
            'gold-storage-tank',
        }
        ---@type boolean 
        ---@diagnostic disable-next-line: assign-type-mismatch
        utils.setting_lignumis_add_electric_lumber_mills = settings.startup[utils.mod_name.."-lignumis-add-electric-lumber-mills"].value
        if utils.setting_lignumis_add_electric_lumber_mills then
            table.insert(utils.constants.lignumis_machine_list,'electric-lumber-mill')
            table.insert(utils.constants.added_machine_tier_1,'electric-lumber-mill')
        end
    end

    if utils.do_muluna then
        utils.constants.muluna_machine_list = {
            'crusher-2',
            -- 'cryolab',
            'muluna-advanced-boiler',
            'muluna-cycling-steam-turbine',
            -- 'muluna-vacuum-heating-tower',
            'muluna-steam-crusher',
            -- 'muluna-greenhouse-wood',

        }
    end

    if utils.do_maraxsis then
        utils.constants.maraxsis_machine_list = {
            'maraxsis-hydro-plant',
            'maraxsis-fishing-tower',
            'maraxsis-conduit',
        }
    end



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

    }

    utils.constants.pollution_types = {
        'pollution',
        'spores',
    }
    if utils.do_lignumis then
        table.insert(utils.constants.pollution_types,'noise')
    end


    -- List Of Machine Names (Base) added by this mod
    utils.constants.every_machine_list = table.deepcopy(utils.constants.space_age_machine_list)

    if utils.setting_do_space_platform_tiers then
        for _, name in ipairs(utils.constants.space_platform_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end

    if utils.setting_do_military_tiers then
        for _, name in ipairs(utils.constants.military_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end




    if utils.do_aop then
        for _, name in ipairs(utils.constants.aop_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end

    if utils.do_lignumis then
        for _, name in ipairs(utils.constants.lignumis_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end

    if utils.do_muluna then
        for _, name in ipairs(utils.constants.muluna_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end

    if utils.do_maraxsis then
        for _, name in ipairs(utils.constants.maraxsis_machine_list) do
            table.insert(utils.constants.every_machine_list, name)
        end
    end









    -- Recipe And Science Generation Settings
    utils.constants.material_to_next_tier_map = {
        ['stone'] = {
            item='stone-brick', ratio=.75
        },
        ['stone-brick'] = {
            item='concrete', ratio=.5
        },
        ['concrete'] = {
            item='refined-concrete', ratio=1.0
        },
        ['electronic-circuit'] = {
            item='advanced-circuit', ratio=1.0
        },
        ['advanced-circuit'] = {
            item='processing-unit', ratio=.8
        },
        ['holmium-plate'] = {
            item='superconductor', ratio=.5
        },
        ['superconductor'] = {
            item='supercapacitor', ratio=1.0
        },
        ['wooden-gear-wheel'] = {
            item='iron-gear-wheel', ratio=1.0
        },
        ['iron-gear-wheel'] = {
            item='engine-unit', ratio=0.5
        },
        ['engine-unit'] = {
            item='electric-engine-unit', ratio=1
        },
        ['iron-plate'] = {
            item='steel-plate', ratio=0.75
        },
        ['copper-plate'] = {
            item='copper-cable', ratio=2.5
        },
        ['plastic-bar'] = {
            item='low-density-structure', ratio=.5
        },
        ['nutrients'] = {
            item='bioflux', ratio=1.0
        },
    }

    utils.constants.science_material_to_next_tier_map = {
        ["automation-science-pack"]={
            ['lumber'] = {
                item='iron-plate', ratio=0.75
            },
            ['gold-plate'] = {
                item='copper-plate', ratio=0.75
            },
            ['gold-pipe'] = {
                item='pipe', ratio=0.75
            },
            ['basic-circuit-board'] = {
                item='electronic-circuit', ratio=1.0
            },
        },
        ["logistic-science-pack"]={
            ['lumber'] = {
                item='iron-plate', ratio=0.75
            },
            ['gold-plate'] = {
                item='copper-plate', ratio=0.75
            },
            ['gold-pipe'] = {
                item='pipe', ratio=0.75
            },
            ['basic-circuit-board'] = {
                item='electronic-circuit', ratio=1.0
            },
        },

        ['space-science-pack']={
            ['add'] = {
                item='low-density-structure', ratio=20.0
            },
            ['backup'] = {
                item='processing-unit', ratio=20.0
            },
        },

        ["metallurgic-science-pack"]={
            ['add'] = {
                item='tungsten-plate', ratio=20.0
            },
            ['backup'] = {
                item='tungsten-carbide', ratio=20.0
            },
            ['tungsten-plate'] = {
                item='tungsten-carbide', ratio=1.0
            },
            ['steel-plate'] = {
                item='tungsten-plate', ratio=1.0
            },
        },
        ["electromagnetic-science-pack"]={
            ['add'] = {
                item='superconductor', ratio=10
            },
            ['backup'] = {
                item='holmium-plate', ratio=10
            },
            ['superconductor'] = {
                item='supercapacitor', ratio=1.0
            },
            ['copper-plate'] = {
            item='holmium-plate', ratio=2.5
            },
            ['copper-cable'] = {
                item='holmium-plate', ratio=2.5
            },
        },
        ["agricultural-science-pack"]={
            ['add'] = {
                item='carbon-fiber', ratio=25
            },
            ['iron-stick'] = {
                item = 'carbon-fiber', ratio = 1.0
            },
        },
        ["cryogenic-science-pack"]={
            ['add'] = {
                item='quantum-processor', ratio=5
            },
            ['backup'] = {
                item='lithium-plate', ratio=5
            },
            ['holmium-plate'] = {
                item='lithium-plate', ratio=1.0
            },
            ['processing-unit'] = {
                item='quantum-processor', ratio=.8
            },
            ['lubricant'] = {
                item='fluoroketone-cold', ratio=.2
            },
            ['electrolyte'] = {
                item='fluoroketone-cold', ratio=.5
            },
            ['holmium-solution'] = {
                item='fluoroketone-cold', ratio=.2
            },
            ['landfill'] = {
                item='foundation', ratio=1.0
            },
        },
        ["promethium-science-pack"]={
            ['add'] = {
                item='quantum-processor', ratio=15
            },
            ['backup'] = {
                item='lithium-plate', ratio=5
            },
        },
    }


    utils.constants.space_packs = {
        'metallurgic-science-pack',
        'electromagnetic-science-pack',
        'agricultural-science-pack',
    }

    if utils.do_maraxsis then
        table.insert(utils.constants.space_packs, 'hydraulic-science-pack')
    end


    utils.constants.space_next_pack_mapping = {
        ['metallurgic-science-pack'] = {
            item='electromagnetic-science-pack', ratio=1.0
        },
        ['electromagnetic-science-pack'] = {
            item='agricultural-science-pack', ratio=1.0
        },
        ['agricultural-science-pack'] = {
            item='metallurgic-science-pack', ratio=1.0
        },
    }

    utils.constants.science_to_next_tier_map = {
        ['all_space'] = {
            item='cryogenic-science-pack', ratio=1.0
        },
        ['automation-science-pack'] = {
            item='logistic-science-pack', ratio=1.0
        },
        ['logistic-science-pack'] = {
            item='chemical-science-pack', ratio=1.0
        },
        ['chemical-science-pack'] = {
            item='space-science-pack', ratio=1.0
        },
        ['cryogenic-science-pack'] = {
            item='promethium-science-pack', ratio=2.0
        },
    }

    -- if lignumis, then add in new sci-packs
    if utils.do_lignumis then
        for k,v in pairs({
            ['wood-science-pack'] = {
                item='steam-science-pack', ratio=1.0
            },
            ['steam-science-pack'] = {
                item='automation-science-pack', ratio=2.0
            },
        }) do
            utils.constants.science_material_to_next_tier_map[k] = v
        end
    end

    utils.constants.tech_to_sci_pack_map = {
        ['planet-discovery-aquilo'] = 'cryogenic-science-pack',
        ['planet-discovery-gleba'] = 'agricultural-science-pack',
        ['planet-discovery-fulgora'] = 'electromagnetic-science-pack',
        ['planet-discovery-vulcanus'] = 'metallurgic-science-pack',
        ['space-science-pack'] = 'space-science-pack',
        ['cryogenic-science-pack'] = 'cryogenic-science-pack',
        ['agricultural-science-pack'] = 'agricultural-science-pack',
        ['electromagnetic-science-pack'] = 'electromagnetic-science-pack',
        ['metallurgic-science-pack'] = 'metallurgic-science-pack',
        
    }

    if utils.do_maraxsis then
        utils.constants.tech_to_sci_pack_map['hydraulic-science-pack'] = 'hydraulic-science-pack'
    end

end

return get_constants
