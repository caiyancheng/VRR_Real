import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
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

# 左边上子图，RD-80SA的模拟信号记录
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


# fig = plt.figure(figsize=(8, 5), dpi=600)
fig = plt.figure(figsize=(11, 5), dpi=600)
gs = GridSpec(2, 2, width_ratios=[1, 1], height_ratios=[3, 1])
left_top = fig.add_subplot(gs[0, 0])
left_bottom = fig.add_subplot(gs[1, 0])

for plot_index in range(len(x_Time_array_plot_list)):
    plot_index = len(x_Time_array_plot_list) - plot_index - 1
    left_top.plot(x_Time_array_plot_list[plot_index], y_Luminance_array_plot_list[plot_index], linewidth=0.8)
# plt.xlabel('Time (s)', fontsize=14)
left_top.set_ylabel('Luminance (cd/m$^2$)', fontsize=14)
left_top.set_yscale('log')
left_top.set_ylim([-1,1])
left_top.set_yticks([0.1, 1, 10],['0.1', '1', '10'])
left_top.set_title('30Hz-120Hz VRR ($F_{rrs}$ ='+f'{aim_vrr_f}Hz)')
# plt.grid(True)

time_start = min(x_time_array[:plot_num])
time_finish = max(x_time_array[:plot_num])
y = np.ones(plot_num)
x_time = x_time_array[:plot_num]
interval_num = round(plot_num / (time_finish - time_start) * (1 / (aim_vrr_f)))
y_start_point_num = -720
for i in range(plot_num):
    if (i-y_start_point_num) % interval_num < interval_num / 2:
        y[i] = 120
    else:
        y[i] = 30

left_bottom.plot(x_time, y)
left_bottom.set_xlabel('Time (s)', fontsize=14)
left_bottom.set_ylabel('Refresh Rate (Hz)', fontsize=14)
left_bottom.set_yticks([30,120])
# plt.show()
# plt.savefig(f'E:\All_Conference_Papers\SIGGRAPH24\Images_new/final_FFT_{aim_vrr_f}_3d_label_1.pdf', format='pdf')

# 右边子图，傅里叶变换的结果
# fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(gs[:, 1], projection='3d')

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
ax.view_init(elev=20, azim=-60)  # 调整视角
ax.plot([aim_vrr_f, aim_vrr_f], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='r', linewidth=2)
ax.plot([30, 30], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='g', linewidth=2)
ax.plot([120, 120], [min(np.log10(yticks)), max(np.log10(yticks))], [0, 0], color='b', linewidth=2)
plt.subplots_adjust(left=0.06, right=0.99, top=0.95, bottom=0.10, wspace=0.0)
# plt.show()
# plt.savefig(f'E:\All_Conference_Papers\SIGGRAPH24\Images_new/final_FFT_{aim_vrr_f}_3d_label_new.pdf', format='pdf')
# plt.savefig(f'E:\All_Conference_Papers\SIGGRAPH Asia 24\Images_new/final_FFT_{aim_vrr_f}_3d_label_new.png', format='png', dpi=600)
plt.savefig(f'E:\All_Conference_Papers\SIGGRAPH Asia 24\Presentation/final_FFT_{aim_vrr_f}_3d_label_new_dpi_100.png', format='png', dpi=100)
