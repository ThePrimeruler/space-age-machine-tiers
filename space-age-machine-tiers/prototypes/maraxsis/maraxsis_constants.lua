local function maraxsis_constants(utils)
    utils.constants.maraxsis_machine_list = {
        'maraxsis-hydro-plant',
        'maraxsis-fishing-tower',
        'maraxsis-conduit',
    }

    for _, name in ipairs(utils.constants.maraxsis_machine_list) do
        table.insert(utils.constants.every_machine_list, name)
    end

    table.insert(utils.constants.space_packs, 'hydraulic-science-pack')

    utils.constants.tech_to_sci_pack_map['hydraulic-science-pack'] = 'hydraulic-science-pack'

end

return maraxsis_constants