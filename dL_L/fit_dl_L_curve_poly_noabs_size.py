import numpy as np
import matplotlib.pyplot as plt
from get_KONICA_data import get_KONICA_data
import json
import math
from scipy.optimize import curve_fit

degree = 5

def polynomial_fit(x, *coeffs): #多元多项式拟合
    result = 0
    degree = int(len(coeffs) / 2)  # 系数的数量等于多项式的次数加1
    for i in range(degree):
        result += coeffs[i] * (x[0] ** i) * (x[1] ** (degree - i - 1))
    return result

L_array, _, dl_L_array, size_values = get_KONICA_data(base_path='LG_G1_KONICA_10', abs=False)
dl_L_array = dl_L_array/2
size_num, repeat_num, color_num = L_array.shape

# 多项式拟合
x_fit_1 = np.linspace(np.min(np.log10(L_array)), np.max(np.log10(L_array)), 100)

#1
json_save = {}
plt.figure(figsize=(6,5))
for i in range(size_num):
    size_value = size_values[i]
    if size_value == 'full':
        area_value = 62.666 * 37.808
    else:
        area_value = math.pi * size_value**2
    current_L_array = L_array[i, :, :].mean(axis=0)
    current_dl_L_array = dl_L_array[i, :, :].mean(axis=0)
    x_1 = np.log10(current_L_array)
    x_2 = np.log10(area_value)
    x_2_repeated = np.tile(x_2, len(x_1))
    x = np.stack([x_1, x_2_repeated], 1)
    y = current_dl_L_array[:,None]
    if i == 0:
        X = x
        Y = y
    else:
        X = np.concatenate((X, x), 0)
        Y = np.concatenate((Y, y), 0)
    # coefficients = np.polyfit(x, y, degree)
    # fitted_curve = np.polyval(coefficients, x_fit_1)
    # plt.scatter(x, y, label=f'Size {size_values[i]}')
    # plt.plot(x_fit_1, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
    # json_save[f'size_{size_values[i]}'] = {'coefficients': coefficients.tolist()}

X_array = np.array(X)
X_array_filter = X_array[X_array[:,0] < 1]
Y_array = np.array(Y)
Y_array_filter = Y_array[X_array[:,0] < 1]
# 接下来的事情还是交给Matlab解决吧
json_save_data = {'X': X_array.tolist(), 'Y': Y_array.tolist(), 'X_filter': X_array_filter.tolist(), 'Y_filter': Y_array_filter.tolist()}
with open('fit_dl_L_curve_poly_noabs_size.json', 'w') as fp:
    json.dump(json_save_data, fp)

# coefficients = np.polyfit(np.column_stack((X_array[:,0], X_array[:,1])), Y_array, degree)
# coefficients, _ = curve_fit(polynomial_fit, (X_array[:,0], X_array[:,1]), Y_array[:,0], p0= np.ones(degree*2))
# json_save['L_AREA'] = {'coefficients': coefficients.tolist()}
# with open(f'KONICA_Fit_result_poly_{degree}_noabs_size.json', 'w') as fp:
#     json.dump(json_save, fp)
#
# fitted_curve = np.polyval(coefficients, x_fit_1)
# plt.plot(x_fit_1, fitted_curve, label=f'Fit - All Sizes', linewidth=4)
#
# plt.legend()
# plt.title(f'{degree} degree Polynomial Fit for All Sizes')
# plt.xlabel('log10(Luminance)')
# plt.ylabel('deltaL/L')
# plt.show()
