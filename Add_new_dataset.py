import json
import os

dataset_json_file = r'E:\Matlab_codes\csf_datasets/datasets.json'

with open(dataset_json_file, 'r') as fp:
    dataset_json_data = json.load(fp)
dataset_json_data['datasets']['yancheng2024'] = {}
dataset_json_data['datasets']['yancheng2024']['full_name'] = 'Yancheng Cai 2024 VRR Flicker Dataset'
dataset_json_data['datasets']['yancheng2024']['author'] = 'Yancheng Cai'
dataset_json_data['datasets']['yancheng2024']['year'] = '2024'
dataset_json_data['datasets']['yancheng2024']['stimulus'] = 'disk'
dataset_json_data['datasets']['yancheng2024']['criterion'] = 'flicker determination'

with open(r'E:\Matlab_codes\csf_datasets/datasets_yancheng.json', 'w') as fp:
    json.dump(dataset_json_data, fp)