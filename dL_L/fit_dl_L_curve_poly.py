import numpy as np
import matplotlib.pyplot as plt
from get_KONICA_data import get_KONICA_data
import json

degree = 4

L_array, _, dl_L_array, size_values = get_KONICA_data(base_path='LG_G1_KONICA_10')
dl_L_array = dl_L_array/2
size_num, repeat_num, color_num = L_array.shape

# 多项式拟合
x_fit_1 = np.linspace(np.min(np.log10(L_array)), np.max(np.log10(L_array)), 100)
x_fit_2 = np.linspace(np.min(np.log10(L_array))-2, np.max(np.log10(L_array))+2, 100)

#1
plt.figure(figsize=(12,5))
plt.subplot(1,2,1)
for i in range(size_num):
    current_L_array = L_array[i, :, :].mean(axis=0)
    current_dl_L_array = dl_L_array[i, :, :].mean(axis=0)
    x = np.log10(current_L_array)
    y = current_dl_L_array
    coefficients = np.polyfit(x, y, degree)
    fitted_curve = np.polyval(coefficients, x_fit_1)
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit_1, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
#Fit all:
current_L_array = L_array.mean(axis=1).flatten()
current_dl_L_array = dl_L_array.mean(axis=1).flatten()
x = np.log10(current_L_array)
y = current_dl_L_array
coefficients = np.polyfit(x, y, degree)
json_save = {'coefficients': coefficients.tolist()}
with open(f'KONICA_Fit_result_poly_{degree}.json', 'w') as fp:
    json.dump(json_save, fp)

fitted_curve = np.polyval(coefficients, x_fit_1)
plt.plot(x_fit_1, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
# plt.show()

# 2
plt.subplot(1,2,2)
for i in range(size_num):
    current_L_array = L_array[i, :, :].mean(axis=0)
    current_dl_L_array = dl_L_array[i, :, :].mean(axis=0)
    x = np.log10(current_L_array)
    y = current_dl_L_array
    coefficients = np.polyfit(x, y, degree)
    fitted_curve = np.polyval(coefficients, x_fit_2)
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit_2, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
#Fit all:
current_L_array = L_array.mean(axis=1).flatten()
current_dl_L_array = dl_L_array.mean(axis=1).flatten()
x = np.log10(current_L_array)
y = current_dl_L_array
coefficients = np.polyfit(x, y, degree)
json_save = {'coefficients': coefficients.tolist()}
with open(f'KONICA_Fit_result_poly_{degree}.json', 'w') as fp:
    json.dump(json_save, fp)

fitted_curve = np.polyval(coefficients, x_fit_2)
plt.plot(x_fit_2, fitted_curve, label=f'Fit - All Sizes', linewidth=4)

plt.legend()
plt.title(f'{degree} degree Polynomial Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
plt.show()
