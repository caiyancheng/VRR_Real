import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import json
import os

csv_data_path = r'E:\Py_codes\VRR_Real\G1_Calibration\py_display_calibration_results_RR\LG-G1-Std-2024_05_16_04_19_16'
csv_data = pd.read_csv(os.path.join(csv_data_path, 'final_result.csv'))

with open(os.path.join(csv_data_path, 'config.json')) as fp:
    config_data = json.load(fp)

stimulus_params = config_data['stimulus_params']
color_change_parameters = config_data['color_change_parameters']
frame_rate_parameters = config_data['frame_rate_parameters']

color_scale = color_change_parameters['scale']
Pixel_value_range = color_change_parameters['Pixel_value_range']
sample_numbers = color_change_parameters['sample_numbers']
if color_scale == 'Linear':
    pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
elif color_scale == 'Log10':
    if Pixel_value_range[0] == 0:
        Pixel_value_range[0] = 0.001
    pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                   num=sample_numbers)
else:
    raise ValueError(f'the scale {color_scale} pattern is not included in this code')

RR_scale = frame_rate_parameters['scale']
Frame_rate_range = frame_rate_parameters['Frame_rate_range']
sample_numbers = frame_rate_parameters['sample_numbers']
if RR_scale == 'Linear':
    RR_all_values = np.linspace(Frame_rate_range[0], Frame_rate_range[1], num=sample_numbers)
elif RR_scale == 'Log10':
    RR_all_values = np.logspace(np.log10(Frame_rate_range[0]), np.log10(Frame_rate_range[1]), num=sample_numbers)
else:
    raise ValueError(f'the scale {RR_scale} pattern is not included in this code')

plt.figure()
Luminance_120Hz_list = []
for color_value in pixel_all_values:
    csv_data_filter = csv_data[(abs(csv_data['color'] - color_value) < 0.001) & (abs(csv_data['refresh_rate'] - 120) < 0.01)]
    Luminance = np.mean(csv_data_filter['Y'])
    Luminance_120Hz_list.append(Luminance)

for RR in RR_all_values:
    Contrast_list = []
    for color_value in pixel_all_values:
        csv_data_filter = csv_data[(abs(csv_data['color'] - color_value) < 0.001) & (abs(csv_data['refresh_rate'] - RR)<0.01)]
        Luminance_RR = np.mean(csv_data_filter['Y'])
        csv_data_filter = csv_data[(abs(csv_data['color'] - color_value) < 0.001) & (abs(csv_data['refresh_rate'] - 120) < 0.01)]
        Luminance_120Hz = np.mean(csv_data_filter['Y'])
        Contrast = abs(Luminance_RR - Luminance_120Hz) / (Luminance_RR + Luminance_120Hz)
        Contrast_list.append(Contrast)
    plt.plot(Luminance_120Hz_list, Contrast_list, label=f'RR = {RR} Hz')
plt.xlabel('Luminance')
plt.ylabel('Contrast')
plt.xscale('log')
plt.yscale('log')
plt.legend()
plt.show()

