import os
from typing import OrderedDict

mod_name = 'space-age-machine-tiers'

names_to_add = [  # Format As Standard Name
    'Flamethrower turret',
    'Gun turret'
]

tiers = [2, 3]

locale_file_path = f'{os.path.dirname(__file__)}/{mod_name}/locale/en/locale.cfg'

with open(locale_file_path, 'r', encoding='utf-8') as file:
    locale_file:list[str] = file.readlines()

locale_mapping: OrderedDict[str, list] = OrderedDict()

in_section = 'start'
comment_block = []
for line in locale_file:
    strip_line = line.strip('\n')
    if strip_line.startswith('['):  # section
        in_section = strip_line
        locale_mapping[in_section] = comment_block
        comment_block = []
        locale_mapping[in_section].append(strip_line)
    elif strip_line.startswith('#'):  # comment
        comment_block.append(strip_line)
    elif strip_line == '':  # blank
        comment_block.append(strip_line)
    else:  # setting line
        locale_mapping[in_section].extend(comment_block)
        comment_block = []
        locale_mapping[in_section].append(strip_line)


# Generator Functions
def slugify(name: str) -> str:
    return name.lower().strip().replace(" ", "-")


def modifier_description(name: str, level: int) -> str:
    # key must end in -attack-bonus to be picked up by Factorio
    return f'{mod_name}-{slugify(name)}-{level}-attack-bonus={name.strip()} {level} damage: +__1__'


# Ensure Section Exists
if '[modifier-description]' not in locale_mapping:
    locale_mapping['[modifier-description]'] = ['[modifier-description]']

# Generate Lines
for name in names_to_add:
    for tier in tiers:
        generated_line = modifier_description(name, tier)
        line_key = generated_line.split('=')[0]
        if not any(line.startswith(line_key) for line in locale_mapping['[modifier-description]']):
            locale_mapping['[modifier-description]'].append(generated_line)

# Write Back File
new_lines = []
for _, lines in locale_mapping.items():
    for line in lines:
        new_lines.append(f'{line}\n')

with open(locale_file_path, 'w', encoding='utf-8') as file:
    file.writelines(new_lines)
