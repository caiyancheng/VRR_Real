import numpy as np
import json
import os
import matplotlib.pyplot as plt


KONICA_base_path = 'LG_G1_KONICA_3'
with open(os.path.join(KONICA_base_path, 'result.json'), 'r') as fp:
    result_data = json.load(fp)
with open(os.path.join(KONICA_base_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)

pixel_all_values = np.arange(config_data['Pixel_value_range'][0], config_data['Pixel_value_range'][1], config_data['Pixel_value_step'])
size_values = config_data['Size']
repeat_times = config_data['repeat_times']

# Create two separate figures and axes
fig1, ax1 = plt.subplots(figsize=(10,5))
fig2, ax2 = plt.subplots(figsize=(10,5))

for size_value in size_values:
    for repeat_time in range(repeat_times):
        x_axis_L = []
        y_axis_dl = []
        y_axis_dl_L = []
        for color_value in pixel_all_values:
            result_index = result_data[f'S_{size_value}_C_{color_value}_R_{repeat_time}']
            luminance_30 = result_index['30'][0]
            luminance_120 = result_index['120'][0]
            L = (luminance_30 + luminance_120) / 2
            dl = luminance_30 - luminance_120
            x_axis_L.append(L)
            y_axis_dl.append(dl)
            y_axis_dl_L.append(dl / L)
        ax1.plot(x_axis_L, y_axis_dl, marker='o', markersize=8,label=f'Size_{size_value}_Repeat_{repeat_time}')
        ax2.plot(x_axis_L, y_axis_dl_L, marker='o', markersize=8, label=f'Size_{size_value}_Repeat_{repeat_time}')


Flicker_meter_base_path = r'../deltaL_L_LG_G1.json'
with open(Flicker_meter_base_path, 'r') as fp:
        deltaL_L_json_dict = json.load(fp)
luminance_list = [1,2,3,4,5,10,100]
size_list = [4, 16]
vrr_f_list = [2, 5, 10]
deltaL_L_real = []

for size_index in range(len(size_list)):
    size_value = size_list[size_index]
    for vrr_f_index in range(len(vrr_f_list)):
        vrr_f_value = vrr_f_list[vrr_f_index]
        deltaL_L_json_sub_dict = deltaL_L_json_dict[f'size_{size_value}_vrr_f_{vrr_f_value}']
        plot_luminance_list = deltaL_L_json_sub_dict['Luminance']
        plot_deltaL_list = deltaL_L_json_sub_dict['deltaL']
        plot_detlaL_L_list = deltaL_L_json_sub_dict['deltaL_L']
        deltaL_L_real.append(plot_detlaL_L_list[-2:])
        print('plot_deltaL/L', plot_detlaL_L_list[-2:])
        ax1.plot(plot_luminance_list, plot_deltaL_list, marker='o', label=f'Size: {size_value}, VRR_f: {vrr_f_value}')
        ax2.plot(plot_luminance_list, plot_detlaL_L_list, marker='o', label=f'Size: {size_value}, VRR_f: {vrr_f_value}')

# Set labels for both figures
ax1.set_xscale('log')
ax2.set_xscale('log')
ax1.set_title('plot deltaL vs Luminance')
ax1.set_xlabel('Luminance')
ax1.set_ylabel('deltaL')
ax2.set_title('plot deltaL/L vs Luminance')
ax2.set_xlabel('Luminance')
ax2.set_ylabel('deltaL/L')

# Show legends for both figures
ax1.legend()
ax2.legend()

# Show the plots
plt.show()
