import matplotlib.pyplot as plt
import numpy as np
import json
import os
from Color_and_Luminance import Color2Luminance_LG_G1
import pandas as pd

CL_transform = Color2Luminance_LG_G1()
CL_transform.__int__(degree_C2L=7, degree_L2C=7)

root_path = 'Result_MOA_disk_eccentricity_CFF_1'
observer = 'Yancheng_Cai'
file_main_path = os.path.join(root_path, f'Observer_{observer}')
with open(os.path.join(file_main_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)
# with open(os.path.join(file_main_path, 'result.json'), 'r') as fp:
#     result_data = json.load(fp)
df = pd.read_csv(os.path.join(file_main_path, 'result.csv'))
s_contrast_list = config_data['stimulus_params']['Contrast']
s_size_list = config_data['stimulus_params']['Size']
s_color_list = config_data['stimulus_params']['Color']
s_pers_list = config_data['stimulus_params']['Persistence']
s_ecc_list = config_data['stimulus_params']['Eccentricity']
c_size_list = config_data['center_point_params']['Size']
c_color_list = config_data['center_point_params']['Color']
# repeat_time = config_data['stimulus_params']['Repeat_times']
repeat_time = 1

plt.figure(figsize=(10,5))
# plt.figure()
# split_key = 'Contrast'
# if split_key in config_data['stimulus_params'].keys():
#     sub_plot_number = len(config_data['stimulus_params'][split_key])
# elif split_key in config_data['center_point_params'].keys():
#     sub_plot_number = len(config_data['center_point_params'][split_key])
# else:
#     raise ValueError('The split key does not exist!')
color_plot = ['r', 'b']
Y_CFF_sum = np.zeros((2,len(s_ecc_list)))
num_trail = np.zeros((2,len(s_ecc_list)))
for s_contrast_index in range(len(s_contrast_list)):
    s_contrast = s_contrast_list[s_contrast_index]
    for s_size_index in range(len(s_size_list)):
        s_size = s_size_list[s_size_index]
        for s_color_index in range(len(s_color_list)):
            s_color = s_color_list[s_color_index]
            for s_pers_index in range(len(s_pers_list)):
                s_pers = s_pers_list[s_pers_index]
                if s_pers == 0.1:
                    continue
                for c_size_index in range(len(c_size_list)):
                    c_size = c_size_list[c_size_index]
                    for c_color_index in range(len(c_color_list)):
                        c_color = c_color_list[c_color_index]
                        x_ecc_list = []
                        y_CFF_list_ecc = []
                        for s_ecc_index in range(len(s_ecc_list)):
                            s_ecc = s_ecc_list[s_ecc_index]
                            if s_ecc == 0 and s_size <= c_size:
                                continue
                            x_ecc_list.append(s_ecc)
                            CFF_list_repeat = []
                            for repeat_index in range(repeat_time):
                                # overall_index = f'SCT_{s_contrast}_SS_{s_size}_SCR_{s_color}_SP_{s_pers}_SE_{s_ecc}_CS_{c_size}_CC_{c_color}'
                                # CFF_list_repeat.append(result_data[overall_index])
                                filter_rows = df[(df['Stimulus_Contrast'] == s_contrast) & (df['Stimulus_Size'] == s_size) & (df['Stimulus_Color'] == s_color)
                                                 & (df['Stimulus_Persistence'] == s_pers) & (df['Stimulus_Eccentricity'] == s_ecc) & (df['Center_point_size'] == c_size)
                                                 & (df['Center_point_color'] == c_color) & (df['Repeat_ID'] == repeat_index)]
                                CFF_list_repeat.append(filter_rows['CFF'].item())
                            index_in = c_size_index
                            y_CFF_list_ecc.append(np.array(CFF_list_repeat).mean())
                            Y_CFF_sum[index_in, s_ecc_index] += np.array(CFF_list_repeat).mean()
                            num_trail[index_in, s_ecc_index] += 1
                        plt.subplot(1, 2, index_in+1)
                        plt.plot(x_ecc_list, y_CFF_list_ecc, color=color_plot[index_in])
Y_CFF_average = Y_CFF_sum / num_trail
plt.subplot(1, 2, 1)
plt.plot(s_ecc_list, Y_CFF_average[0,:], 'k', linewidth=6.0)
# L_1 = CL_transform.C2L(c_color_list[0])
# plt.title(f'Center Point Color = {c_color_list[0]}, Luminance = {round(L_1,5)}')
# plt.title(f'Stimulus Contrast = {s_contrast_list[0]}')
# plt.title(f'Stimulus Size = {s_size_list[0]}')
# L_1 = CL_transform.C2L(s_color_list[0])
# plt.title(f'Stimulus Color = {s_color_list[0]}, Luminance = {round(L_1,5)}')
plt.title(f'Center Point Size = {c_size_list[0]}')
plt.xlabel('Eccentricity (horizontal degree)')
plt.ylim([0,35])
plt.ylabel('CFF (Hz)')

plt.subplot(1, 2, 2)
plt.plot(s_ecc_list, Y_CFF_average[1,:], 'k', linewidth=6.0)
# L_2 = CL_transform.C2L(c_color_list[1])
# plt.title(f'Center Point Color = {c_color_list[1]}, Luminance = {round(L_2,5)}')
# plt.title(f'Stimulus Contrast = {s_contrast_list[1]}')
# plt.title(f'Stimulus Size = {s_size_list[1]}')
# L_2 = CL_transform.C2L(s_color_list[1])
# plt.title(f'Stimulus Color = {s_color_list[1]}, Luminance = {round(L_2,5)}')
plt.title(f'Center Point Size = {c_size_list[1]}')
plt.xlabel('Eccentricity (horizontal degree)')
plt.ylim([0,35])
plt.ylabel('CFF (Hz)')
plt.subplots_adjust(left=0.05, right=0.95, bottom=0.1, top=0.9, wspace=0.2)
plt.show()



