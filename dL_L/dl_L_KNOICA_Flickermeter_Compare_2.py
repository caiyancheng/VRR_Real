import numpy as np
import json
import os
import matplotlib.pyplot as plt
from dL_L.get_KONICA_data import get_KONICA_data

x_L_array, y_dl_array, y_dl_L_array, _ = get_KONICA_data(base_path='LG_G1_KONICA_5')

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

VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
Size_list = config_data['change_params']['Size']

fig1, ax1 = plt.subplots(figsize=(10,5))
fig2, ax2 = plt.subplots(figsize=(10,5))

plt.figure(figsize=(10,10))
for size_index in range(len(Size_list)):
    size_value = Size_list[size_index]
    current_L_array = x_L_array[size_index, :, :].mean(axis=0)
    current_dl_array = y_dl_array[size_index, :, :].mean(axis=0) / 2
    current_dl_L_array = y_dl_L_array[size_index, :, :].mean(axis=0) / 2
    ax1.plot(current_L_array, current_dl_array, label=f'KONICA_Size_{size_value}', linestyle='--')
    ax2.plot(current_L_array, current_dl_L_array, label=f'KONICA_Size_{size_value}', linestyle='--')
    for vrr_f_index in range(len(VRR_Frequency_list)):
        vrr_f_value = VRR_Frequency_list[vrr_f_index]
        t_L_array = Temporal_L_array[size_index, vrr_f_index, :, :].mean(axis=0)
        t_dl_array = Temporal_dL_array[size_index, vrr_f_index, :, :].mean(axis=0)
        t_dl_L_array = t_dl_array / t_L_array
        ax1.plot(t_L_array, t_dl_array, label=f'Flicker_Meter_Size_{size_value}_Frequency_{vrr_f_value}')
        ax2.plot(t_L_array, t_dl_L_array, label=f'Flicker_Meter_Size_{size_value}_Frequency_{vrr_f_value}')

ax1.set_xscale('log')
ax2.set_xscale('log')
ax1.set_yscale('log')
ax2.set_yscale('log')
ax1.set_title('plot deltaL vs Luminance')
ax1.set_xlabel('Luminance')
ax1.set_ylabel('deltaL')
ax2.set_title('plot deltaL/L vs Luminance')
ax2.set_xlabel('Luminance')
ax2.set_ylabel('deltaL/L')
ax1.legend(bbox_to_anchor=(1.05, 0.5), loc='center left', borderaxespad=0., prop={'size': 8})
ax2.legend(bbox_to_anchor=(1.05, 0.5), loc='center left', borderaxespad=0., prop={'size': 8})
pos1 = ax1.get_position()
pos1.x1 = 0.7
ax1.set_position(pos1)
pos2 = ax1.get_position()
pos2.x1 = 0.7
ax2.set_position(pos2)
plt.show()




