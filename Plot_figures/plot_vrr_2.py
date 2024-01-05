import matplotlib.pyplot as plt
import pandas as pd
import json
import os
import numpy as np
from Computational_Model.FFT import compute_signal_FFT


def get_color_values(color_change_parameters):
    scale = color_change_parameters['scale']
    Pixel_value_range = color_change_parameters['Pixel_value_range']
    sample_numbers = color_change_parameters['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)
    return pixel_all_values

config_path = r'B:\Py_codes\VRR_Real\Plot_figures/config.json'
root_path = r'B:\Datasets\Temporal_Flicker_Meter_log\deltaL_L_10s\2023-12-19-20-43-10/'
L_result_path = r'B:\Py_codes\VRR_Real\Plot_figures/dl_L_results_10s_5r.json'
repeat_times = 5

with open(config_path, 'r') as fp:
    config_data = json.load(fp)
VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
Size_list = config_data['change_params']['Size']
Repeat_times = config_data['change_params']['Repeat_times']
pixel_all_values = get_color_values(config_data['color_change_parameters'])
with open(L_result_path, 'r') as fp:
    L_result_data = json.load(fp)
aim_vrr_f = 8
aim_size = 16
aim_color = [0.21235057950506092,0.3210006144457002,0.4376179965934659,0.5380484445259031]
aim_repeat = 0
plot_num = 2000

x_Time_array_plot_list = []
y_Luminance_array_plot_list = []
x_Frequency_plot_list = []
y_K_FFT_plot_list = []
Luminance_average = []

fig = plt.figure(figsize=(10, 5))
for size_index in range(len(Size_list)):  # 3
    size_value = Size_list[size_index]
    if aim_size != size_value:
        continue
    for vrr_f_index in range(len(VRR_Frequency_list)):  # 6
        vrr_f_value = VRR_Frequency_list[vrr_f_index]
        if vrr_f_value != aim_vrr_f:
            continue
        for color_index in range(len(pixel_all_values)):  # 30
            color_value = pixel_all_values[color_index]
            if color_value not in aim_color:
                continue
            for repeat_index in range(Repeat_times):
                if repeat_index != aim_repeat:
                    continue
                json_data_path = os.path.join(root_path, f'S_{size_value}_V_{vrr_f_value}_C_{color_value}',f'{repeat_index}.json')
                with open(json_data_path, 'r') as fp:
                    temporal_log_data = json.load(fp)
                measurements = np.array(temporal_log_data['measurements'])
                x_time_array = np.arange(len(measurements)) * config_data['record_params']['time_flicker_meter_log'] / config_data['record_params']['num_flicker_meter_sample']
                y_luminance_array = measurements / measurements.mean() * np.array(L_result_data['KONICA_Luminance'])[size_index, vrr_f_index, repeat_index, color_index]
                x_Time_array_plot_list.append(x_time_array[:plot_num])
                y_Luminance_array_plot_list.append(y_luminance_array[:plot_num])
                Luminance_average.append(y_luminance_array.mean())
                x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array,
                                                               frequency_upper=150, plot_FFT=False, skip_0=False,
                                                               force_equal=True)
                x_Frequency_plot_list.append(x_freq_array)
                y_K_FFT_plot_list.append(K_FFT_array)

plt.subplot(1, 2, 1)
for plot_index in range(len(x_Time_array_plot_list)):
    plot_index = len(x_Time_array_plot_list) - plot_index - 1
    plt.plot(x_Time_array_plot_list[plot_index], y_Luminance_array_plot_list[plot_index], linewidth=0.8)
plt.xlabel('Time (s)')
plt.ylabel('Luminance (nits)')
# plt.yscale('log')
plt.ylim([0,110])
plt.yticks([1,10,50,100])
plt.title(f'30Hz-120Hz VRR (Frequency of RR Switch = {aim_vrr_f}Hz)')
# plt.grid(True)

ax = fig.add_subplot(122, projection='3d')
ax_position = ax.get_position()
ax_position.x0 = 0.01  # 调整左边界
ax_position.x1 = 0.99  # 调整右边界
ax_position.y0 = 0.01   # 调整下边界
ax_position.y1 = 0.99   # 调整上边界
ax.set_position(ax_position)
ax.plot([aim_vrr_f, aim_vrr_f], [0, 110], [0, 0], color='r', label=f'{aim_vrr_f} Hz (Flicker)', linewidth=2)
ax.plot([30, 30], [0, 110], [0, 0], color='g', label='30 Hz', linewidth=2)
ax.plot([120, 120], [0, 110], [0, 0], color='b', label='120 Hz', linewidth=2)
for plot_index in range(len(x_Time_array_plot_list)):
    plot_index = len(x_Time_array_plot_list) - plot_index -1
    x = x_Frequency_plot_list[plot_index][1:]
    y = [Luminance_average[plot_index]] * len(x)
    z = y_K_FFT_plot_list[plot_index][1:]
    ax.plot(x, y, z, linewidth=0.8)

ax.set_xlabel('Temporal Frequency (Hz)')
ax.set_ylabel('Average Luminance (nits)')
ax.set_zlabel('Amplitude')
ax.set_title('Fourier Transform (0 Hz is skipped)')
ax.set_xticks([aim_vrr_f, 30, 120])
ax.set_zticks([0.05, 0.10])
ax.set_ylim([0, 110])
ax.set_zlim([0, 0.13])
ax.grid(True)
# ax.legend()
ax.view_init(elev=20, azim=-70)  # 调整视角
plt.subplots_adjust(left=0.06, right=0.99, top=0.95, bottom=0.10, wspace=-0.1)
# plt.show()
plt.savefig(f'B:\All_Conference_Papers\SIGGRAPH24\Images/FFT_{aim_vrr_f}_3d.png', dpi=300)