import pandas as pd
import numpy as np
import os
import json

Quest_root_path = r'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all'
original_csv_dict = pd.read_csv(os.path.join(Quest_root_path,'Matlab_D_thr_S_gather.csv')).to_dict(orient='list')
gather_dict = {}
gather_dict_creat = False

for observer_path in observer_path_list:
    # if observer_path.endswith('.csv') or observer_path.endswith('.png')  or observer_path.endswith('Rafal_2'):
    #     continue
    if observer_path not in observer_name_list:
        continue
    Quest_file_path = os.path.join(Quest_root_path, observer_path, 'matlab_reorder_result_D_thr_S.csv')
    csv_dict = pd.read_csv(Quest_file_path).to_dict(orient='list')
    if not gather_dict_creat:
        for key in csv_dict.keys():
            gather_dict[key] = []
        gather_dict['Observer_name'] = []
        gather_dict['Age'] = []
        gather_dict['Gender'] = []
        gather_dict_creat = True
    with open(os.path.join(Quest_root_path, observer_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    Observer_name = config_data['observer_params']['name']
    Age = config_data['observer_params']['age']
    Gender = config_data['observer_params']['gender']
    for index in range(len(csv_dict['Sensitivity'])):
        for key in csv_dict.keys():
            gather_dict[key].append(csv_dict[key][index])
        gather_dict['Observer_name'].append(Observer_name)
        gather_dict['Age'].append(Age)
        gather_dict['Gender'].append(Gender)

df = pd.DataFrame(gather_dict)
df.to_csv(f'{Quest_root_path}/Matlab_D_thr_S_gather.csv', index=False)