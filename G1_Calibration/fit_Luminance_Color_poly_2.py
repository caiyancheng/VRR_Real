import numpy as np
import matplotlib.pyplot as plt
import json
from Read_Calibration_result import read_calibration_result_2

degree = 7
# base_path = r'py_display_calibration_results_new\LG-G1-Std-2024_03_18_02_29_58' #   White Clear, no Random
base_path = r'py_display_calibration_results_new\LG-G1-Std-2024_03_18_02_51_50' #   White Clear, Random
# base_path = r'py_display_calibration_results_new\LG-G1-Std-2024_03_18_03_15_22' #   no White Clear, no Random
# base_path = r'py_display_calibration_results_new\LG-G1-Std-2024_03_18_03_31_12' #   no White Clear, Random
pixel_all_values, Luminance_array, size_list = read_calibration_result_2(base_path=base_path)
size_num, color_num, repeat_num = Luminance_array.shape

# 多项式拟合
x_fit = np.linspace(np.log10(np.min(Luminance_array)), np.log10(np.max(Luminance_array)), 100)
json_save = {}
#1
plt.figure(figsize=(4,5))
for size_index in range(len(size_list)):
    size_value = size_list[size_index]
    x = np.log10(Luminance_array[size_index, :, :].mean(axis=-1))
    y = pixel_all_values
    coefficients = np.polyfit(x, y, degree)
    fitted_curve = np.polyval(coefficients, x_fit)
    plt.scatter(x, y, label=f'Size {size_value}')
    plt.plot(x_fit, fitted_curve, label=f'Fit - Size {size_value}', linestyle='--')
    json_save[f'size_{size_value}'] = {'coefficients': coefficients.tolist()}
# Fit all:
y = np.tile(pixel_all_values, size_num-1)
Luminance_array = Luminance_array[:-1,...]
x = np.log10(Luminance_array.mean(axis=-1).flatten())
coefficients = np.polyfit(x, y, degree)
fitted_curve = np.polyval(coefficients, x_fit)
plt.plot(x_fit, fitted_curve, label=f'Fit - Size No Full All', linestyle='--')
json_save[f'size_nofull_all'] = {'coefficients': coefficients.tolist()}
json_save['Luminance_min'] = np.min(Luminance_array)
json_save['Luminance_max'] = np.max(Luminance_array)
with open(f'KONICA_Luminance_Color_Fit_result_poly_{degree}.json', 'w') as fp:
    json.dump(json_save, fp)
#
# fitted_curve = np.polyval(coefficients, x_fit)
# plt.plot(x_fit, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.ylabel('Color')
plt.xlim([np.log10(np.min(Luminance_array)), np.log10(np.max(Luminance_array))])
plt.ylim([0,1])
plt.xlabel('log10(Luminance)')
plt.show()
