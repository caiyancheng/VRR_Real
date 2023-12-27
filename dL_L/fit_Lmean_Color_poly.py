import numpy as np
import matplotlib.pyplot as plt
from get_KONICA_data_2 import get_KONICA_data
import json

degree = 5
C_array, L_array, _, _, size_values = get_KONICA_data(base_path='LG_G1_KONICA_10')
size_num, repeat_num, color_num = L_array.shape

# 多项式拟合
x_fit_1 = np.linspace(0, 1, 100)

#1
# plt.figure(figsize=(12,5))
# plt.subplot(1,2,1)
json_save = {}
for i in range(size_num):
    current_C_array = C_array.copy()
    current_L_array = L_array[i, :, :].mean(axis=0)
    x = current_C_array
    y = np.log10(current_L_array)
    coefficients = np.polyfit(x, y, degree)
    json_save[f'size_{size_values[i]}'] = {}
    json_save[f'size_{size_values[i]}']['coefficients'] = coefficients.tolist()
    fitted_curve = np.polyval(coefficients, x_fit_1)
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit_1, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
#Fit all:
current_C_array = np.tile(C_array.copy(), size_num)
current_L_array = L_array.mean(axis=1).flatten()
x = current_C_array
y = np.log10(current_L_array)
coefficients = np.polyfit(x, y, degree)
json_save['size_all'] = {}
json_save['size_all']['coefficients'] = coefficients.tolist()
with open(f'KONICA_Lmean_Color_Fit_result_poly_{degree}.json', 'w') as fp:
    json.dump(json_save, fp)

fitted_curve = np.polyval(coefficients, x_fit_1)
plt.plot(x_fit_1, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.xlabel('Color (Pixel value)')
plt.ylabel('log10(Luminance)')
plt.show()
