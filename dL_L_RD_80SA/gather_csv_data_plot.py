# 如何从示波器中读取数据
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tqdm import tqdm
import os
from Computational_Model.FFT import compute_signal_FFT
from Color_and_Luminance import Color2Luminance_LG_G1
import json

CL_transform = Color2Luminance_LG_G1()
CL_transform.__int__(degree_C2L=7, degree_L2C=7)

change_parameters = {
    'VRR_Frequency': [0.5, 2, 4, 8, 10, 12, 14, 16],
    'Color_Value_adjust_range': [0.04, 0.2],
    'Color_sample_numbers': 10,
    'Size': [16, 'full'],
}

root_path = r'E:\Datasets\RD-80SA\2024-4-14'
file_dir_list = os.listdir(root_path)
color_values = np.linspace(change_parameters['Color_Value_adjust_range'][0],
                           change_parameters['Color_Value_adjust_range'][1],
                           num=change_parameters['Color_sample_numbers'])
ff_dict = {
    '0.5': 0.5,
    '2': 2,
    '4': 4,
    '8': 8,
    '10': 10,
    '12': 11.9,
    '14': 13.3,
    '16': 14.9,
}

vrr_f_list = []
size_list = []
color_value_list = []
real_fundamental_frequency_list = []
L_list = []
dL_list = []

# plt.figure(figsize=(8,6))
file_index = 0
for vrr_f in tqdm(change_parameters['VRR_Frequency']):
    for size in change_parameters['Size']:
        for color_value in color_values:
            vrr_f_list.append(vrr_f)
            size_list.append(size)
            color_value_list.append(color_value)

            file_name = file_dir_list[file_index]

            df = pd.read_csv(os.path.join(root_path, file_name), skiprows=range(15))
            x_time_array = (np.array(df['TIME']) - df['TIME'][0]) / (
                        df['TIME'][len(df['TIME']) - 1] - df['TIME'][0]) * 10
            stimulus_array = np.array(df['CH1'])
            luminance_value = CL_transform.C2L(color_value=color_value)
            y_luminance_array = stimulus_array / stimulus_array.mean() * luminance_value
            x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array,
                                                           y_luminance_array=y_luminance_array,
                                                           frequency_upper=120, plot_FFT=False,
                                                           force_equal=True)
            # search_fq_start_point = np.abs(x_freq_array - vrr_f * 0.8).argmin()
            # search_fq_end_point = np.abs(x_freq_array - vrr_f * 1.2).argmin()
            # ff_index = search_fq_start_point + np.argmax(K_FFT_array[search_fq_start_point:search_fq_end_point + 1])
            real_fundamental_frequency = ff_dict[f'{vrr_f}']
            real_fundamental_frequency_list.append(real_fundamental_frequency)
            ff_index = np.abs(x_freq_array - real_fundamental_frequency).argmin()
            L_list.append(luminance_value)
            dL_list.append(K_FFT_array[ff_index])
            # L_plot_list.append(luminance_value)
            # dL_plot_List.append(K_FFT_array[ff_index])
            file_index += 1
        # plt.plot(L_plot_list, dL_plot_List, label=f'vrr_f = {vrr_f}, size = {size}')
# plt.subplots_adjust(left=0.1, bottom=0.35, right=0.99, top=0.99)
# plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.5), ncol=3)
# plt.xlabel('Luminance')
# plt.ylabel('delta Luminance')
# plt.show()

json_dict = {'vrr_f_list': vrr_f_list,
             'size_list': size_list,
             'color_value_list': color_value_list,
             'real_fundamental_frequency_list': real_fundamental_frequency_list,
             'L_list': L_list,
             'dL_list': dL_list,
             'change_parameters': change_parameters,
             'ff_dict': ff_dict}

with open(r'E:\Datasets\RD-80SA/2024-4-14_gather_result_2.json', 'w') as fp:
    json.dump(json_dict, fp)
