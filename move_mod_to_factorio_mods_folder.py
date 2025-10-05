import os
import json
import shutil

mod_name = 'space-age-machine-tiers'

factorio_mods_folder_location = '...'

my_mod_folder_location = os.path.normpath(f'{os.path.dirname(__file__)}/{mod_name}')

info_json_location = os.path.normpath(f'{my_mod_folder_location}/info.json')

with open(info_json_location,'r',encoding='utf-8') as file:
    info_json = json.load(file)

mod_version = info_json['version']

zipped_file_name = f'{mod_name}_{mod_version}'

zipped_file_start_path = os.path.normpath(f'{os.path.dirname(__file__)}/{zipped_file_name}.zip')
zipped_file_factorio_mods_folder_path = os.path.normpath(f'{factorio_mods_folder_location}/{zipped_file_name}.zip')

# zip folder and rename
parent_dir = os.path.dirname(my_mod_folder_location)
folder_name = os.path.basename(my_mod_folder_location)
shutil.make_archive(zipped_file_name, 'zip', root_dir=parent_dir, base_dir=folder_name)

# delete old file if it's there
if os.path.exists(zipped_file_factorio_mods_folder_path):
    os.remove(zipped_file_factorio_mods_folder_path)

# move the new zipped mod into location
shutil.move(zipped_file_start_path, zipped_file_factorio_mods_folder_path)
