import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# 定义三个数据文件的路径
data_path_1 = r'display_calibration\disp_meas_YanchengCai_G1_2023_11_16_100pointsramp1/resp_YanchengCai_G1_2023_11_16_100pointsramp1.csv'
data_path_2 = r'display_calibration\disp_meas_YanchengCai_G1_2023_11_16_100pointsramp2/resp_YanchengCai_G1_2023_11_16_100pointsramp2.csv'
data_path_3 = r'display_calibration\disp_meas_YanchengCai_G1_2023_11_17_1000pointsramp1/resp_YanchengCai_G1_2023_11_17_1000pointsramp1.csv'

# 从CSV文件中读取数据
csv_data_1 = pd.read_csv(data_path_1)
csv_data_2 = pd.read_csv(data_path_2)
csv_data_3 = pd.read_csv(data_path_3)

# 提取每个数据集中的RGB值和亮度值
RGB_values_1 = csv_data_1[' R'].to_numpy()
Luminance_values_1 = csv_data_1[' Y'].to_numpy()
RGB_values_2 = csv_data_2[' R'].to_numpy()
Luminance_values_2 = csv_data_2[' Y'].to_numpy()
RGB_values_3 = csv_data_3[' R'].to_numpy()
Luminance_values_3 = csv_data_3[' Y'].to_numpy()

# 创建一个新的图形窗口，指定图形的大小
# plt.figure(figsize=(30,10))

# 绘制散点图，显示RGB值和亮度值的关系
plt.scatter(RGB_values_1, Luminance_values_1, label='Ramp 1 (100 points)')
plt.scatter(RGB_values_2, Luminance_values_2, label='Ramp 2 (100 points)')
plt.scatter(RGB_values_3, Luminance_values_3, label='Ramp 1 (1000 points)')

# 添加标题和坐标轴标签
plt.title("LG G1 Calibration")  # 图形标题
plt.xlabel("RGB Values (White, R=G=B)")  # x轴标签
plt.ylabel("Luminance Values (cd/m^2)")  # y轴标签

# 添加图例，用于区分不同的散点图
plt.legend()

# 显示图形
plt.show()
