import matplotlib.pyplot as plt
import pandas as pd
import json
import os
import numpy as np
from Computational_Model.FFT import compute_signal_FFT
from Color_and_Luminance import Color2Luminance_LG_G1
from tqdm import tqdm

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

aim_vrr_f = 4
aim_size = 16
plot_num = 8000
color_index_plot = [1,2,4,8]
x_t_start = np.array([0,2190,1900,2800]) + 700

x_Time_array_plot_list = []
y_Luminance_array_plot_list = []
x_Frequency_plot_list = []
y_K_FFT_plot_list = []
Luminance_average = []

fig = plt.figure(figsize=(8, 4))
file_index = 0
for vrr_f in tqdm(change_parameters['VRR_Frequency']):
    for size in change_parameters['Size']:
        for color_index in range(len(color_values)):
            color_value = color_values[color_index]
            if (vrr_f != aim_vrr_f) or (size != aim_size) or (color_index not in color_index_plot):
                file_index += 1
                continue
            plot_color_list_index = color_index_plot.index(color_index)
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

            x_Time_array_plot_list.append(x_time_array[:plot_num]) #只画有限的范围
            y_Luminance_array_plot_list.append(y_luminance_array[x_t_start[plot_color_list_index]:x_t_start[plot_color_list_index]+plot_num])
            Luminance_average.append(y_luminance_array.mean())
            x_Frequency_plot_list.append(x_freq_array)
            y_K_FFT_plot_list.append(K_FFT_array)
            file_index += 1

plt.subplot(1, 2, 1)
for plot_index in range(len(x_Time_array_plot_list)):
    plot_index = len(x_Time_array_plot_list) - plot_index - 1
    plt.plot(x_Time_array_plot_list[plot_index], y_Luminance_array_plot_list[plot_index], linewidth=0.8)
plt.xlabel('Time (s)', fontsize=14)
plt.ylabel('Luminance (cd/m$^2$)', fontsize=14)
plt.yscale('log')
plt.ylim([-1,1])
plt.yticks([0.1, 1, 10],['0.1', '1', '10'])
plt.title('30Hz-120Hz VRR ($F_{rrs}$ ='+f'{aim_vrr_f}Hz)')
# plt.grid(True)

ax = fig.add_subplot(122, projection='3d')
ax_position = ax.get_position()
ax_position.x0 = 0.01  # 调整左边界
ax_position.x1 = 0.99  # 调整右边界
ax_position.y0 = 0.01   # 调整下边界
ax_position.y1 = 0.99   # 调整上边界
ax.set_position(ax_position)
# ax.plot([aim_vrr_f, aim_vrr_f], [0, 110], [0, 0], color='r', label=f'{aim_vrr_f} Hz (Flicker)', linewidth=2)
# ax.plot([30, 30], [0, 110], [0, 0], color='g', label='30 Hz', linewidth=2)
# ax.plot([120, 120], [0, 110], [0, 0], color='b', label='120 Hz', linewidth=2)

all_Average_Luminance_list = []
for plot_index in range(len(x_Time_array_plot_list)):
    plot_index = len(x_Time_array_plot_list) - plot_index -1
    x = x_Frequency_plot_list[plot_index][1:]
    y = np.log10([Luminance_average[plot_index]] * len(x))
    z = y_K_FFT_plot_list[plot_index][1:]
    ax.plot(x, y, z, linewidth=1, label=f'{Luminance_average[plot_index]:.1f} cd/m$^2$')
    all_Average_Luminance_list.append(Luminance_average[plot_index])

ax.set_xlabel('Temporal Frequency (Hz)', fontsize=12)
ax.set_ylabel('Average Luminance (cd/m$^2$)', fontsize=12)
# plt.yscale('log')
# plt.ylim([-1,1])
ax.set_zlabel('Amplitude')
ax.set_title('Fourier Transform (0 Hz is skipped)')
ax.set_xticks([aim_vrr_f, 30, 120])
ax.set_zticks([0.05, 0.10])
ax.set_ylim([min(np.log10(all_Average_Luminance_list)), max(np.log10(all_Average_Luminance_list))])
# plt.yticks([min(np.log10(all_Average_Luminance_list)), 0, max(np.log10(all_Average_Luminance_list))],
#            [str(round(min(all_Average_Luminance_list),2)), '1', str(round(max(all_Average_Luminance_list),2))])
yticks = [0.5,1,2,5,10]
plt.yticks(np.log10(yticks), [str(i) for i in yticks])
ax.set_zlim([0, 0.13])
ax.grid(True)
ax.legend()
ax.view_init(elev=20, azim=-70)  # 调整视角
ax.plot([aim_vrr_f, aim_vrr_f], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='r', linewidth=2)
ax.plot([30, 30], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='g', linewidth=2)
ax.plot([120, 120], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='b', linewidth=2)

plt.subplots_adjust(left=0.07, right=0.99, top=0.95, bottom=0.10, wspace=-0.1)

plt.subplots_adjust(left=0.08, right=0.95, bottom=0.12, top=0.93)
plt.show()
# plt.savefig(f'E:\All_Conference_Papers\SIGGRAPH24\Images_new/FFT_{aim_vrr_f}_3d_label.png', dpi=300)