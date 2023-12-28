import numpy as np
import json
import os

root_path = r'B:\Py_codes\VRR_Real\VRR_Subjective_MOA\Result_MOA_disk_1\Observer_Yancheng_Cai_2'

with open(os.path.join(root_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)
with open(os.path.join(root_path, 'result.json'), 'r') as fp:
    result_data = json.load(fp)

VRR_Frequency_list = config_data["change_parameters"]["VRR_Frequency"]
Size_list = config_data["change_parameters"]["Size"]

color_value_all = []
for vrr_f_value in VRR_Frequency_list:
    for size_value in Size_list:
        Color_value = result_data[f"V_{vrr_f_value}_S_{size_value}"]
        color_value_all.append(Color_value)

std = np.std(np.array(color_value_all))
print('STD', std)
