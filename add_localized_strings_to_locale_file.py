import os
from typing import OrderedDict
mod_name = 'space-age-machine-tiers'

names_to_add = [ # Format As Sandard Name
]

tiers = [2,3]

locale_file_path = f'{os.path.dirname(__file__)}/{mod_name}/locale/en/locale.cfg'

with open(locale_file_path,'r',encoding='utf-8') as file:
    locale_file = file.readlines()

locale_mapping:OrderedDict[str,list] = OrderedDict()

in_section = 'start'
comment_block = []
for line in locale_file:
    strip_line = line.strip()
    if strip_line.startswith('['): # its a section
        in_section = strip_line
        locale_mapping[strip_line] = comment_block
        comment_block = []
        locale_mapping[strip_line].append(strip_line)
    elif strip_line.startswith('#'): # it's a comment
        comment_block.append(strip_line)
    elif strip_line == '': # new line
        comment_block.append(strip_line)
    else: # it's a setting line
        locale_mapping[in_section].extend(comment_block)
        comment_block = []
        locale_mapping[in_section].append(strip_line)


# import json
# print(json.dumps(locale_mapping,indent=4))


# [technology-name]
def technology_name(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}={name.strip()}'

# [technology-description]
def technology_description(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}={name.strip()} Upgrade'

#[item-name]
def item_name(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}-{level}={name.strip()} {level}'

#[item-description]
def item_description(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}-{level}={name.strip()} Version {level}'

#[entity-name]
def entity_name(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}-{level}={name.strip()} {level}'

#[entity-description]
def entity_description(name:str, level:str)->str:
    return f'{mod_name}-{name.lower().strip().replace(" ","-")}-{level}={name.strip()} Version {level}'



group_mapping = {
    '[technology-name]':technology_name,
    '[technology-description]':technology_description,
    '[item-name]':item_name,
    '[item-description]':item_description,
    '[entity-name]':entity_name,
    '[entity-description]':entity_description
}

for group, func in group_mapping.items():
    if group not in locale_mapping:
        raise RuntimeError(f'locale file does not have group "{group}"')
    for name in names_to_add:
        for tier in tiers:
            generated_line = func(name,tier)
            line_key = generated_line.split('=')[0]
            if not any(line_key in line for line in locale_mapping[group]):
                locale_mapping[group].append(generated_line)

# import json
# print(json.dumps(locale_mapping,indent=4))

new_lines = []
for _,lines in locale_mapping.items():
    for line in lines:
        new_lines.append(f'{line}\n')

# import json
# print(json.dumps(new_lines,indent=4))

with open(locale_file_path,'w',encoding='utf-8') as file:
    file.writelines(new_lines)
