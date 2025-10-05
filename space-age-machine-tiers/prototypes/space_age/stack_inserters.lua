local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Stack Inserter Tiers')


local machine_name = 'stack-inserter'
local backup_tech_mapping = 'stack-inserter'


-- local type, proto = utils.find_entity_by_name(machine_name)
-- utils.debug(machine_name..' type is '..type)
-- utils.debug(utils.jsonSerializeTable(proto,machine_name))

auto_create_tiers.create_machine_tiers(machine_name,backup_tech_mapping)
