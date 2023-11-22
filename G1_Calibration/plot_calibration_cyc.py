import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

data_path = r'E:\Py_codes\VRR_Real\G1_Calibration\py_display_calibration_results\LG-G1-Std-2023_11_21_18_20_28/result_data.csv'
csv_data = pd.read_csv(data_path)

# 提取每个数据集中的RGB值和亮度值
RGB_values = csv_data['color'].to_numpy()
Size_values = csv_data['screen_size'].to_numpy()
Luminance_values = csv_data['Y'].to_numpy()

fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
#
# # 使用scatter绘制散点图
# ax.scatter(RGB_values, Size_values, Luminance_values, c='b', marker='o')
#
# # 设置轴标签
# ax.set_xlabel('RGB Values (R=G=B)')
# ax.set_ylabel('Size Values')
# ax.set_zlabel('Luminance Values (cd/m^2)')
#
# # 显示图形
# plt.show()
size_control = [0.1, 0.2, 0.3, 0.4, 0.5]
for size_i in size_control:
    RGB_values_sub = RGB_values[Size_values==size_i]
    Luminance_values_sub = Luminance_values[Size_values==size_i]
    plt.scatter(RGB_values_sub, Luminance_values_sub, label=f'Size == {size_i}')
plt.xlabel('RGB Values (R=G=B)')
plt.ylabel('Luminance Values (cd/m^2)')
plt.show()