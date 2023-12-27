import numpy as np
import json
import pandas as pd
import matplotlib.pyplot as plt
import os

Observer_Name = 'Yancheng_Cai'
# Observer_Name = 'Rafal'
MOA_exp_path = f'Result_MOA_3/Observer_{Observer_Name}_2'
with open(os.path.join(MOA_exp_path, 'config.json'), 'r') as fp:
    MOA_config = json.load(fp)
with open(os.path.join(MOA_exp_path, 'result_MOA_C_t.json'), 'r') as fp:
    MOA_C_t_result = json.load(fp)
MOA_Sizes = MOA_config['change_parameters']['Size']
MOA_VRR_Fs = MOA_config['change_parameters']['VRR_Frequency']

plt.figure()
for size_index in range(len(MOA_Sizes)):
    size_value = MOA_Sizes[size_index]
    x_vrr_f = []
    y_L = []
    for vrr_f_index in range(len(MOA_VRR_Fs)):
        vrr_f_value = MOA_VRR_Fs[vrr_f_index]
        L_result = MOA_C_t_result[f'V_{vrr_f_value}_S_{size_value}']['Luminance']
        x_vrr_f.append(vrr_f_value)
        y_L.append(L_result)
    plt.plot(x_vrr_f, y_L, label=f'Size_{size_value}')
    plt.scatter(x_vrr_f, y_L, marker='o')
plt.legend()
plt.title(f'Observer_{Observer_Name} MOA Experiment Result')
plt.xlabel('Frequency of RR Switch (Hz)')
plt.ylabel('Luminance (cd/m^2)')
plt.show()
