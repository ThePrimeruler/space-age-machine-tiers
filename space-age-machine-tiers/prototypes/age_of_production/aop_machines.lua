local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding AOP Machine Tiers')

local aop_machine_list = utils.constants.aop_machine_list

local backup_aop_machine_tech_mapping = {
    ["aop-arc-furnace"] = "aop-arc-furnace",
    ["aop-atomic-enricher"] = "aop-atomic-enricher",
    ["aop-biochemical-facility"] = "aop-hybridation",
    ["aop-electromechanic-facility"] = "aop-electromechanics",
    ["aop-greenhouse"] = "aop-greenhouse",
    ["aop-hydraulic-plant"] = "aop-hydraulics",
    ["aop-lumber-mill"] = "aop-woodworking",
    ["aop-petrochemical-facility"] = "aop-petrochemistry",
    ["aop-quantum-assembler"] = "aop-quantum-machinery",
    ["aop-quantum-computer"] = "aop-quantum-machinery",
    ["aop-quantum-stabilizer"] = "aop-quantum-machinery",
    ["aop-scrubber"] = "aop-air-scrubbing",
    ["aop-smeltery"] = "aop-smeltery",
}

for _, machine_name in ipairs(aop_machine_list) do

    auto_create_tiers.create_machine_tiers(machine_name,backup_aop_machine_tech_mapping[machine_name])

end
