local utils = require("lib.utils")

local auto_create_tiers = require("prototypes.auto_create_tiers")

utils.info('Adding Base Game Tiers')

local base_game_machine_list = utils.constants.base_game_machine_list

local backup_base_game_machine_tech_mapping = {
    ['beacon'] = 'effect-transmission'
}

for _, machine_name in ipairs(base_game_machine_list) do

    -- local type, proto = utils.find_entity_by_name(machine_name)
    -- utils.debug(machine_name..' type is '..type)
    -- utils.debug(utils.jsonSerializeTable(proto,machine_name))

    auto_create_tiers.create_machine_tiers(machine_name,backup_base_game_machine_tech_mapping[machine_name])

end
