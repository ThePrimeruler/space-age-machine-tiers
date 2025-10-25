local utils = require("lib.utils")
-- Copy Pelagos Code For Fuel Values, as I can't copy for some reason
-- adding flamethrower turret fuel values to tiers 2 and 3


local overrides = {
	-- vanilla
	["light-oil"] = "1.2MJ",
	["heavy-oil"] = "0.6MJ",
	["petroleum-gas"] = "0.6MJ",
	["coconut-oil"] = "0.3MJ",
	-- pelagos
	["ethanol"] = "2MJ",
	["methane"] = "0.6MJ",
	["crude-oil"] = "0.3MJ",
	["titanium-sludge"] = "0.15MJ",
	--bumpuff agriculture
	["puff-gas"] = "0.6MJ",
	--maraxis
	["hydrogen"] = "0.4MJ",
}

for name, value in pairs(overrides) do
	local fluid = data.raw.fluid[name]
	if fluid then
		fluid.fuel_value = value
	end
end



for i=2,3,1 do
    local _, flameturret = utils.find_entity_by_name(utils.get_machine_name(i,'flamethrower-turret'))
    if not flameturret then
        utils.debug('did not find flameturret for '..i)
        goto continue
    end

    for fluid_name, fuel_value in pairs(overrides) do
        local fluid = data.raw.fluid[fluid_name]
        if fluid then
            local number_part = util.parse_energy(fuel_value) / 1000000 -- MJ
            if number_part and number_part > 0 then
                local found = false
                for _, f in pairs(flameturret.attack_parameters.fluids) do
                    if f.type == fluid_name then
                        f.damage_modifier = number_part
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(flameturret.attack_parameters.fluids, {
                        type = fluid_name,
                        damage_modifier = number_part,
                    })
                end
            end
        else
            -- utils.debug("Override skipped: fluid '" .. fluid_name .. "' not found in data.raw.fluid")
        end
    end
    ::continue::
end