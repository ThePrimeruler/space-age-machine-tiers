local function recipe_and_tech_constants(utils)
    -- Recipe And Science Generation Settings


    -- A Material Mapping To Upgrade The Materials Used To Make A Recipe
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
    } ---@type {[string]: {item: string, ratio: number}}

    -- materials that can be added if that science pack was added to the tech
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
                item='low-density-structure', ratio=1.0
            },
            ['backup'] = {
                item='processing-unit', ratio=1.5
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
                item='superconductor', ratio=1
            },
            ['backup'] = {
                item='holmium-plate', ratio=1
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
                item='carbon-fiber', ratio=1
            },
            ['backup'] = {
                item='bioflux', ratio=1
            },
            ['nutrients'] = {
                item='bioflux', ratio=1.0
            },
            ['iron-stick'] = {
                item = 'carbon-fiber', ratio = 1.0
            },
        },
        ["cryogenic-science-pack"]={
            ['add'] = {
                item='quantum-processor', ratio=.5
            },
            ['backup'] = {
                item='lithium-plate', ratio=1
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
                item='quantum-processor', ratio=.5
            },
            ['backup'] = {
                item='biter-egg', ratio=0.1
            },
            ['bioflux'] = {
                item='biter-egg', ratio=0.2
            },

        },
    } ---@type {[string]: {item: string, ratio: number}}

    -- a list of space science packs to compare against
    utils.constants.space_packs = {
        'metallurgic-science-pack',
        'electromagnetic-science-pack',
        'agricultural-science-pack',
    } ---@type string[]

    -- where the science-pack progression ordering
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
    } ---@type {[string]: {item: string, ratio: number}}


    -- checks for these science packs in the order
    utils.constants.pre_space_science_tiers = {
        ['automation-science-pack'] = {
            item='logistic-science-pack', ratio=1.5
        },
        ['logistic-science-pack'] = {
            item='chemical-science-pack', ratio=2.0
        },
        ['chemical-science-pack'] = {
            item='space-science-pack', ratio=1.0
        },
    } ---@type {[string]: {item: string, ratio: number}}

    -- if moving past pre-space, add these packs in
    utils.constants.pre_space_science_additional = {
        "production-science-pack",
        "utility-science-pack",
    } ---@type string[]

    -- if you have all the space packs, add this one
    utils.constants.all_space_pack_next = {
        item='cryogenic-science-pack', ratio=1.5
    } ---@type {item: string, ratio: number}

    -- post space pack mapping
    utils.constants.post_space_science_tiers = {
            ['cryogenic-science-pack'] = {
                item='promethium-science-pack', ratio=2.0
        },
    } ---@type {[string]: {item: string, ratio: number}}

    -- mapping of technologies to science packs
    utils.constants.tech_to_sci_pack_map = {
        ['planet-discovery-aquilo'] = 'cryogenic-science-pack',
        ['planet-discovery-gleba'] = 'agricultural-science-pack',
        ['planet-discovery-fulgora'] = 'electromagnetic-science-pack',
        ['planet-discovery-vulcanus'] = 'metallurgic-science-pack',

        ['automation-science-pack'] = 'automation-science-pack',
        ['logistic-science-pack'] = 'logistic-science-pack',
        ['chemical-science-pack'] = 'chemical-science-pack',
        ['production-science-pack'] = 'production-science-pack',
        ['utility-science-pack'] = 'utility-science-pack',
        ['space-science-pack'] = 'space-science-pack',
        ['cryogenic-science-pack'] = 'cryogenic-science-pack',
        ['agricultural-science-pack'] = 'agricultural-science-pack',
        ['electromagnetic-science-pack'] = 'electromagnetic-science-pack',
        ['metallurgic-science-pack'] = 'metallurgic-science-pack',
    } ---@type {[string]: string}

end

return recipe_and_tech_constants