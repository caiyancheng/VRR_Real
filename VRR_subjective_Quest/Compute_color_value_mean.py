import numpy as np
import json
import os
import pandas as pd

root_path = r'B:\Py_codes\VRR_Real\VRR_Subjective_Quest\Result_Quest_disk_4'
Observer_list = ['Yancheng_Cai', 'Ali', 'Ale']

VRR_Frequency_list = [0.5, 2, 4, 8]
Size_list = ['0.5', '1', '16', 'full']
Quest_color_value = np.zeros((len(Observer_list), len(VRR_Frequency_list), len(Size_list)))

for Observer_index in range(len(Observer_list)):
    Observer_value = Observer_list[Observer_index]
    file_name = os.path.join(root_path, f'Observer_{Observer_value}_2', 'reorder_result_D_thr.csv')
    df = pd.read_csv(file_name)
    for vrr_f_index in range(len(VRR_Frequency_list)):
        vrr_f_value = VRR_Frequency_list[vrr_f_index]
        for size_index in range(len(Size_list)):
            size_value = Size_list[size_index]
            sub_df = df[(df['VRR_Frequency'] == vrr_f_value) & (df['Size_Degree'] == size_value)]
            try:
                Quest_color_value[Observer_index, vrr_f_index, size_index] = sub_df['threshold']
            except:
                X = 1

json_data_save = {}
for vrr_f_index in range(len(VRR_Frequency_list)):
    vrr_f_value = VRR_Frequency_list[vrr_f_index]
    for size_index in range(len(Size_list)):
        size_value = Size_list[size_index]
        mean_Quest_color = np.mean(Quest_color_value[:,vrr_f_index, size_index])
        json_data_save[f'V_{vrr_f_value}_S_{size_value}'] = float(mean_Quest_color)
with open('Average_Quest_Color.json', 'w') as fp:
    json.dump(json_data_save, fp)