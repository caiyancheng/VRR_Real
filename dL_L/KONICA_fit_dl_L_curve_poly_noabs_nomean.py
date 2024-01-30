import numpy as np
import matplotlib.pyplot as plt
from get_KONICA_data_3 import get_KONICA_data
import json
import os

degree = 5

base_path = 'B:\Py_codes\VRR_Real\dL_L_PC_datasets\short_range_LG_G1_KONICA_multi_points\9_points\point_-0.95_-0.95\KONICA_2024-01-28-17-25-20'
x_color_array, x_axis_L_sizes, y_axis_dl_sizes, y_axis_dl_L_sizes, size_values = get_KONICA_data(base_path=base_path, abs=False)
size_num = len(x_axis_L_sizes)
color_num = x_color_array.shape

# 多项式拟合
# x_fit_1 = np.linspace(np.log10(np.min(min(x_axis_L_sizes))), np.log10(np.max(max(x_axis_L_sizes))), 100)
x_fit_1 = np.linspace(-0.4, 1.2, 100)

#1
json_save = {}
plt.figure(figsize=(6,5))
for i in range(len(x_axis_L_sizes)):
    current_L_array = x_axis_L_sizes[i]
    current_dl_L_array = y_axis_dl_L_sizes[i]
    x = np.log10(current_L_array)
    y = current_dl_L_array
    coefficients = np.polyfit(x, y, degree)
    fitted_curve = np.polyval(coefficients, x_fit_1)
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit_1, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
    json_save[f'size_{size_values[i]}'] = {'coefficients': coefficients.tolist()}
    plt.legend()
#Fit all:
current_L_array = np.concatenate(x_axis_L_sizes, axis=0)
current_dl_L_array = np.concatenate(y_axis_dl_L_sizes, axis=0)
x = np.log10(current_L_array)
y = current_dl_L_array
coefficients = np.polyfit(x, y, degree)
json_save['size_all'] = {'coefficients': coefficients.tolist()}
# with open(os.path.join(base_path, f'KONICA_Fit_result_poly_{degree}_noabs.json'), 'w') as fp:
#     json.dump(json_save, fp)

fitted_curve = np.polyval(coefficients, x_fit_1)
plt.plot(x_fit_1, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
plt.show()
