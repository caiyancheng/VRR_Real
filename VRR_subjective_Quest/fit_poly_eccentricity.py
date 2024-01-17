import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

# 这段代码是为了拟合敏感度随着空间位置变化的掉落，之后将加入到空间积分中
Quest_exp_path = r'Result_Quest_disk_eccentricity_1'
Observer = 'Yancheng_Cai'

degree_list = [1,2,3]
ecc_fit_result_json_save_data = {}

plt.figure(figsize=(8,4))
config_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'config.json')
csv_result_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'reorder_result_D_thr_C_t.csv')
with open(config_path, 'r') as fp:
    config_data = json.load(fp)
Eccentricity_array = np.array(config_data["change_parameters"]["Eccentricity"])
x_ecc_fit_array = np.linspace(np.min(Eccentricity_array), np.max(Eccentricity_array), 100)
df = pd.read_csv(csv_result_path)
ecc_list = []
C_t_list = []
# C_t_high_list = []
# C_t_low_list = []
for ecc_index in range(len(Eccentricity_array)):
    ecc_value = Eccentricity_array[ecc_index]
    ecc_list.append(ecc_value)
    sub_df = df[df["Eccentricity"] == ecc_value]
    C_t_list.append(sub_df['C_t'].item())
ecc_array = np.array(ecc_list)
C_t_array = np.array(C_t_list)
plt.errorbar(ecc_array, C_t_array, fmt='-o', label=f'Observer Result')

#FIT
for degree_index in range(len(degree_list)):
    degree_value = degree_list[degree_index]
    coefficients = np.polyfit(ecc_array, C_t_array, degree_value)
    ecc_fit_result_json_save_data[f'fit_degree_{degree_value}_coefficients'] = coefficients.tolist()
    fitted_curve_C_t = np.polyval(coefficients, x_ecc_fit_array)
    plt.plot(x_ecc_fit_array, fitted_curve_C_t, label=f'{degree_value} degree polynomial fitting', linestyle='--')

with open('fit_poly_eccentricity_all.json', 'w') as fp:
    json.dump(ecc_fit_result_json_save_data, fp)
plt.yscale('log')
plt.xticks(ecc_list, [str(ecc) for ecc in ecc_list])
plt.ylabel('Flicker Detection Contrast Threshold')
plt.ylim([0.008, 0.05])
# plt.title(f'Frequency of RR Switch: 8 Hz, Size: disk with diameter 4 degree')
plt.grid(True)
plt.legend()
plt.xlabel('Eccentricity (degree)')
plt.tight_layout()
plt.savefig(r'B:\All_Conference_Papers\SIGGRAPH24\Images/ecc_2.png')

