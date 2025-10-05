local utils = require("lib.utils")

require "prototypes.space_age.big_drills"
require "prototypes.space_age.foundries"
require "prototypes.space_age.recyclers"
require "prototypes.space_age.electromagnetic_plants"
require "prototypes.space_age.lightning_rods"
require "prototypes.space_age.lightning_collectors"
require "prototypes.space_age.biochambers"
require "prototypes.space_age.agriculture_towers"
require "prototypes.space_age.cryogenic_plants"
require "prototypes.space_age.biolabs"
require "prototypes.space_age.stack_inserters"
require "prototypes.space_age.heating_towers"

if utils.setting_do_space_platform_tiers then
    require "prototypes.space_age.space_platform"
end

if utils.setting_do_military_tiers then
    require "prototypes.space_age.military"
end

if utils.do_aop then
    require "prototypes.age_of_production.aop_machines"
end

if utils.do_lignumis then
    if utils.setting_lignumis_add_electric_lumber_mills then
        require "prototypes.lignumis.electric_lumber_mills"
    end
    require "prototypes.lignumis.lignumis_machines"
end

if utils.do_muluna then
    require "prototypes.muluna.muluna_machines"
end 

if utils.do_maraxsis then
    require "prototypes.maraxsis.maraxsis_machines"
end
