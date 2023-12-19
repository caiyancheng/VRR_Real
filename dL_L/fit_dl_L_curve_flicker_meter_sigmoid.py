import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from get_KONICA_data import get_KONICA_data
import json
import os

# Sigmoid函数
def sigmoid(x, k, x0):
    return 1 / (1 + np.exp(-k * (x - x0)))
# root_path = r'B:\Datasets\Temporal_Flicker_Meter_log\deltaL_L_2s\2023-12-17-05-06-02'
# root_path = r'B:\Datasets\Temporal_Flicker_Meter_log\deltaL_L_5s\2023-12-18-01-08-47'
root_path = r'B:\Datasets\Temporal_Flicker_Meter_log\deltaL_L_10s\2023-12-18-17-18-03'
with open(os.path.join(root_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)
with open(r'B:\Py_codes\VRR_Real\dL_L\Temporal_Results/dl_L_results_10s.json', 'r') as fp:
    json_result_dict = json.load(fp)
Temporal_L_array = np.array(json_result_dict['L'])
Temporal_dL_array = np.array(json_result_dict['dL'])
Temporal_abnormal_array = np.array(json_result_dict['abnormal'])
size_num, vrr_f_num,repeat_num, color_num = Temporal_L_array.shape
Temporal_dL_L_array = Temporal_dL_array / Temporal_L_array
x_fit = np.linspace(np.min(np.log10(Temporal_L_array))-2, np.max(np.log10(Temporal_L_array))+2, 100)
VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
Size_list = config_data['change_params']['Size']
initial_guess_for_k = 1.0
initial_guess_for_x0 = 0.0
p0 = [initial_guess_for_k, initial_guess_for_x0]
fig1, ax1 = plt.subplots(figsize=(8,6))
for size_i in range(size_num):
    for vrr_f_i in range(vrr_f_num):
        current_L_array = Temporal_L_array[size_i, vrr_f_i, :, :].mean(axis=0)
        current_dl_L_array = Temporal_dL_L_array[size_i, vrr_f_i, :, :].mean(axis=0)
        x = np.log10(current_L_array)
        y = current_dl_L_array
        popt, pcov = curve_fit(sigmoid, x, y, p0=p0)

        # 绘制散点和拟合曲线
        plt.scatter(x, y)
        plt.scatter(x, y, label=f'Size {Size_list[size_i]} VRR_F {VRR_Frequency_list[vrr_f_i]}')
        # plt.plot(x, y, label=f'Size {Size_list[size_i]} VRR_F {VRR_Frequency_list[vrr_f_i]}', linewidth=0.5)
        # plt.plot(x_fit, sigmoid(x_fit, *popt),
        #          label=f'Fit - Size {Size_list[size_i]} VRR_F {VRR_Frequency_list[vrr_f_i]}', linestyle='--')

# Fit all:
current_L_array = Temporal_L_array.mean(axis=2).flatten()
current_dl_L_array = Temporal_dL_L_array.mean(axis=2).flatten()
x = np.log10(current_L_array)
y = current_dl_L_array
popt, pcov = curve_fit(sigmoid, x, y, p0=p0)

# 绘制拟合曲线
plt.plot(x_fit, sigmoid(x_fit, *popt), label=f'Fit - All Sizes', linewidth=4, color='red')

plt.legend(bbox_to_anchor=(1.05, 0.5), loc='center left', borderaxespad=0., prop={'size': 10})
pos1 = ax1.get_position()
pos1.x1 = 0.7
ax1.set_position(pos1)
plt.title('Sigmoid Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
plt.show()
