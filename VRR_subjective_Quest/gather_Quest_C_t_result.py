import pandas as pd
import numpy as np
import os
import json

Quest_root_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3'
observer_path_list = os.listdir(Quest_root_path)
gather_dict = {}
gather_dict_creat = False
for observer_path in observer_path_list:
    if observer_path.endswith('.csv') or observer_path.endswith('.png'):
        continue
    Quest_file_path = os.path.join(Quest_root_path, observer_path, 'reorder_result_D_thr_C_t.csv')
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
    for index in range(len(csv_dict['C_t'])):
        for key in csv_dict.keys():
            gather_dict[key].append(csv_dict[key][index])
        gather_dict['Observer_name'].append(Observer_name)
        gather_dict['Age'].append(Age)
        gather_dict['Gender'].append(Gender)

df = pd.DataFrame(gather_dict)
df.to_csv('B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv', index=False)