import numpy as np
import matplotlib.pyplot as plt
from get_KONICA_data import get_KONICA_data

L_array, _, dl_L_array, size_values = get_KONICA_data(base_path='LG_G1_KONICA_5')
size_num, repeat_num, color_num = L_array.shape

# 多项式拟合
x_fit = np.linspace(np.min(np.log10(L_array))-2, np.max(np.log10(L_array))+2, 100)
for i in range(size_num):
    current_L_array = L_array[i, :, :].mean(axis=0)
    current_dl_L_array = dl_L_array[i, :, :].mean(axis=0)
    x = np.log10(current_L_array)
    y = current_dl_L_array
    coefficients = np.polyfit(x, y, 3)
    fitted_curve = np.polyval(coefficients, x_fit)
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit, fitted_curve, label=f'Fit - Size {size_values[i]}', linestyle='--')
#Fit all:
current_L_array = L_array.mean(axis=1).flatten()
current_dl_L_array = dl_L_array.mean(axis=1).flatten()
x = np.log10(current_L_array)
y = current_dl_L_array
coefficients = np.polyfit(x, y, 3)
fitted_curve = np.polyval(coefficients, x_fit)
plt.plot(x_fit, fitted_curve, label=f'Fit - All Sizes', linestyle='--')

plt.legend()
plt.title('Polynomial Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
plt.show()
