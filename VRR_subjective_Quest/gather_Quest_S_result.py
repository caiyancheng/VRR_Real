import math
import pandas as pd
import numpy as np
import os
import json

Quest_root_path = 'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all'
observer_path_list = os.listdir(Quest_root_path)
gather_dict = {}
gather_dict_creat = False
# Observer_list = ['Ale', 'Maliha', 'Yancheng_Cai', 'Ali', 'Shushan', 'Hongyun_Gao', 'Zhen', 'Yaru']#, 'Zhen']
# observer_name_list = ['Observer_Yancheng_Cai_2', 'Observer_Ale_2', 'Observer_Ali_2', 'Observer_Maliha_2',
#                       'Observer_Shushan_2', 'Observer_Hongyun_Gao_2', 'Observer_Zhen_2', 'Observer_Yaru_2',
#                       'Observer_Yuan_2', 'Observer_Claire_2', 'Observer_pupu_2', 'Observer_haoyu_2', 'Observer_Dounia_2']
observer_name_list = ['Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen']
for Observer_index in range(len(observer_name_list)):
    Observer_id = observer_name_list[Observer_index]
    observer_name_list[Observer_index] = f'Observer_{Observer_id}_2'

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
        gather_dict['Radius'] = []
        gather_dict['Area'] = []
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
        size_origin = csv_dict['Size_Degree'][index]
        area_value = 62.666 * 37.808 if size_origin == -1 else math.pi * (size_origin/2)**2
        gather_dict['Radius'].append((area_value / math.pi) ** 0.5)
        gather_dict['Area'].append(area_value)
        gather_dict['Observer_name'].append(Observer_name)
        gather_dict['Age'].append(Age)
        gather_dict['Gender'].append(Gender)

df = pd.DataFrame(gather_dict)
df.to_csv(f'{Quest_root_path}/Matlab_D_thr_S_gather.csv', index=False)