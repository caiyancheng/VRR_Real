import json
import numpy as np
import matplotlib.pyplot as plt

save_json_10_path = 'plt_save_fig/MTime_2023-11-01_BIG_Display/RefreshRate_[60,120,60]_Time_[2, 0.2, 0.2, 0.2, 0.2]_Color_[1.0,1.0,1.0]_Noblack.json'
save_json_08_path = 'plt_save_fig/MTime_2023-11-01_BIG_Display/RefreshRate_[60,120,60]_Time_[2, 0.2, 0.2, 0.2, 0.2]_Color_[0.8,0.8,0.8]_Noblack.json'
save_json_06_path = 'plt_save_fig/MTime_2023-11-01_BIG_Display/RefreshRate_[60,120,60]_Time_[2, 0.2, 0.2, 0.2, 0.2]_Color_[0.6,0.6,0.6]_Noblack.json'
save_json_04_path = 'plt_save_fig/MTime_2023-11-01_BIG_Display/RefreshRate_[60,120,60]_Time_[2, 0.2, 0.2, 0.2, 0.2]_Color_[0.4,0.4,0.4]_Noblack.json'
save_json_02_path = 'plt_save_fig/MTime_2023-11-01_BIG_Display/RefreshRate_[60,120,60]_Time_[2, 0.2, 0.2, 0.2, 0.2]_Color_[0.2,0.2,0.2]_Noblack.json'

with open(save_json_10_path, 'r') as fp:
    json_data_10 = json.load(fp)
with open(save_json_08_path, 'r') as fp:
    json_data_08 = json.load(fp)
with open(save_json_06_path, 'r') as fp:
    json_data_06 = json.load(fp)
with open(save_json_04_path, 'r') as fp:
    json_data_04 = json.load(fp)
with open(save_json_02_path, 'r') as fp:
    json_data_02 = json.load(fp)

start_time = [4,5,4,5,5]
end_time = [6,7,6,7,7]

x_time_array_10 = np.array(json_data_10['x_time'])
x_time_array_10_r = x_time_array_10[(x_time_array_10 > start_time[0]) & (x_time_array_10 < end_time[0])]
x_time_array_08 = np.array(json_data_08['x_time'])
x_time_array_08_r = x_time_array_08[(x_time_array_08 > start_time[1]) & (x_time_array_08 < end_time[1])]
x_time_array_06 = np.array(json_data_06['x_time'])
x_time_array_06_r = x_time_array_06[(x_time_array_06 > start_time[2]) & (x_time_array_06 < end_time[2])]
x_time_array_04 = np.array(json_data_04['x_time'])
x_time_array_04_r = x_time_array_04[(x_time_array_04 > start_time[3]) & (x_time_array_04 < end_time[3])]
x_time_array_02 = np.array(json_data_02['x_time'])
x_time_array_02_r = x_time_array_02[(x_time_array_02 > start_time[4]) & (x_time_array_02 < end_time[4])]

y_luminance_array_10 = np.array(json_data_10['y_luminance'])[(x_time_array_10 > start_time[0]) & (x_time_array_10 < end_time[0])]
y_luminance_array_08 = np.array(json_data_08['y_luminance'])[(x_time_array_08 > start_time[1]) & (x_time_array_08 < end_time[1])]
y_luminance_array_06 = np.array(json_data_06['y_luminance'])[(x_time_array_06 > start_time[2]) & (x_time_array_06 < end_time[2])]
y_luminance_array_04 = np.array(json_data_04['y_luminance'])[(x_time_array_04 > start_time[3]) & (x_time_array_04 < end_time[3])]
y_luminance_array_02 = np.array(json_data_02['y_luminance'])[(x_time_array_02 > start_time[4]) & (x_time_array_02 < end_time[4])]

x_10_real_begin = x_time_array_10_r[np.argmax(y_luminance_array_10 > max(y_luminance_array_10)/2)]
x_08_real_begin = x_time_array_08_r[np.argmax(y_luminance_array_08 > max(y_luminance_array_08)/2)]
x_06_real_begin = x_time_array_06_r[np.argmax(y_luminance_array_06 > max(y_luminance_array_06)/2)]
x_04_real_begin = x_time_array_04_r[np.argmax(y_luminance_array_04 > max(y_luminance_array_04)/2)]
x_02_real_begin = x_time_array_02_r[np.argmax(y_luminance_array_02 > max(y_luminance_array_02)/2)]
# plt.figure()
# plt.subplot(5,1,1)
# plt.plot(x_time_array_10_r, y_luminance_array_10)
# plt.subplot(5,1,2)
# plt.plot(x_time_array_08_r, y_luminance_array_08)
# plt.subplot(5,1,3)
# plt.plot(x_time_array_06_r, y_luminance_array_06)
# plt.subplot(5,1,4)
# plt.plot(x_time_array_04_r, y_luminance_array_04)
# plt.subplot(5,1,5)
# plt.plot(x_time_array_02_r, y_luminance_array_02)
#
# plt.ylim([0,1])
# plt.xlabel('Time')
# plt.ylabel('Luminance')
# plt.show()

# 创建一个子图网格，所有子图共享Y轴
fig, axs = plt.subplots(5, 1, sharey=True, figsize=(10, 5))  # figsize可以根据需要调整

# 在这个例子中，我们不再使用subplot来单独添加每个子图，而是使用axs数组
axs[0].plot(x_time_array_10_r, y_luminance_array_10)
axs[1].plot(x_time_array_08_r, y_luminance_array_08)
axs[2].plot(x_time_array_06_r, y_luminance_array_06)
axs[3].plot(x_time_array_04_r, y_luminance_array_04)
axs[4].plot(x_time_array_02_r, y_luminance_array_02)

left = 0.02
right = 1.1

x_04_real_begin = 5.95
x_02_real_begin = 5.95

x_lims = [
    (x_10_real_begin - left, x_10_real_begin + right),
    (x_08_real_begin - left, x_08_real_begin + right),
    (x_06_real_begin - left, x_06_real_begin + right),
    (x_04_real_begin - left, x_04_real_begin + right),
    (x_02_real_begin - left, x_02_real_begin + right)
]
color_annotations = ['Color=[1.0, 1.0, 1.0]', 'Color=[0.8, 0.8, 0.8]', 'Color=[0.6, 0.6, 0.6]', 'Color=[0.4, 0.4, 0.4]', 'Color=[0.2, 0.2, 0.2]']

# 设置每个子图的xlim
for ax, lim, annotation in zip(axs, x_lims, color_annotations):
    ax.set_xlim(lim)
    ax.set_ylim([0, 1])
    ax.text(0.5, 0.9, annotation, transform=ax.transAxes, fontsize=9, va='top', ha='left')

# 设置底部子图的X轴标签
axs[-1].set_xlabel('Time')

# 设置整个图的Y轴标签
fig.text(0.01, 0.5, 'Luminance', va='center', rotation='vertical')  # 调整位置

plt.tight_layout()  # 自动调整子图参数，以给定的填充
plt.show()
