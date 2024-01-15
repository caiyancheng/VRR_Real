import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

Quest_exp_path = r'Result_Quest_disk_eccentricity_1'
Observer = 'Yancheng_Cai'

plt.figure(figsize=(8,9))
config_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'config.json')
csv_result_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'reorder_result_D_thr_C_t.csv')
with open(config_path, 'r') as fp:
    config_data = json.load(fp)
Eccentricity_list = config_data["change_parameters"]["Eccentricity"]
df = pd.read_csv(csv_result_path)
ecc_list = []
C_t_list = []
C_t_high_list = []
C_t_low_list = []
for ecc_index in range(len(Eccentricity_list)):
    ecc_value = Eccentricity_list[ecc_index]
    ecc_list.append(ecc_value)
    sub_df = df[df["Eccentricity"] == ecc_value]
    C_t_list.append(sub_df['C_t'].item())
    C_t_high_list.append(sub_df['C_t_high'].item())
    C_t_low_list.append(sub_df['C_t_low'].item())

error_bar = np.array([C_t_list, C_t_high_list]) - np.array([C_t_low_list, C_t_list])
plt.errorbar(ecc_list, np.array(C_t_list), yerr=error_bar, fmt='-o', label=f'Observer {Observer}')
plt.yscale('log')
plt.xticks(ecc_list, [str(ecc) for ecc in ecc_list])
plt.ylabel('Flicker Detection Contrast Threshold')
plt.ylim([0.001, 0.1])
plt.title(f'Frequency of RR Switch: 8 Hz, Size: disk with diameter 4 degree')
plt.grid(True)
plt.legend()
plt.xlabel('Eccentricity (degree)')
plt.tight_layout()
plt.show()

