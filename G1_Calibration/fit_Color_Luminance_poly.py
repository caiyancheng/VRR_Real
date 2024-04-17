import numpy as np
import matplotlib.pyplot as plt
import json
from Read_Calibration_result import read_calibration_result

degree = 7
# base_path = r'py_display_calibration_results_new\LG-G1-Std-2023_12_23_16_14_06'
base_path = r'py_display_calibration_results_new\LG-G1-Std-2023_12_23_17_49_24'
pixel_all_values, Luminance_array, size_list = read_calibration_result(base_path=base_path)
size_num, color_num, repeat_num = Luminance_array.shape

# 多项式拟合
x_fit = np.linspace(np.min(pixel_all_values), np.max(pixel_all_values), 100)
json_save = {}
#1
plt.figure(figsize=(5,5))
for size_index in range(len(size_list)):
    size_value = size_list[size_index]
    x = pixel_all_values
    y = np.log10(Luminance_array[size_index, :, :].mean(axis=-1))
    coefficients = np.polyfit(x, y, degree)
    fitted_curve = np.polyval(coefficients, x_fit)
    plt.scatter(x, y, label=f'Size {size_value}')
    plt.plot(x_fit, fitted_curve, label=f'Fit - Size {size_value}', linestyle='--')
    json_save[f'size_{size_value}'] = {'coefficients': coefficients.tolist()}
# Fit all:
x = np.tile(pixel_all_values, size_num-1)
Luminance_array = Luminance_array[:-1,...]
y = np.log10(Luminance_array.mean(axis=-1).flatten())
coefficients = np.polyfit(x, y, degree)
fitted_curve = np.polyval(coefficients, x_fit)
plt.plot(x_fit, fitted_curve, label=f'Fit - Size No Full All', linestyle='--')
json_save[f'size_nofull_all'] = {'coefficients': coefficients.tolist()}
json_save['color_min'] = np.min(pixel_all_values)
json_save['color_max'] = np.max(pixel_all_values)
with open(f'KONICA_Color_Luminance_Fit_result_poly_{degree}.json', 'w') as fp:
    json.dump(json_save, fp)

#
# fitted_curve = np.polyval(coefficients, x_fit)
# plt.plot(x_fit, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.xlabel('Color')
plt.ylabel('log10(Luminance)')
plt.show()
