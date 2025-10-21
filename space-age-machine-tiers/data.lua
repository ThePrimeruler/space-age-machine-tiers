local utils = require("lib.utils")

require "prototypes.space_age.base_machines"

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
