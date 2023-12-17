import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from get_KONICA_data import get_KONICA_data

# Sigmoid函数
def sigmoid(x, k, x0):
    return 1 / (1 + np.exp(-k * (x - x0)))

L_array, _, dl_L_array, size_values = get_KONICA_data(base_path='LG_G1_KONICA_5')
size_num, repeat_num, color_num = L_array.shape
initial_guess_for_k = 1.0
initial_guess_for_x0 = 0.0
p0 = [initial_guess_for_k, initial_guess_for_x0]
x_fit = np.linspace(np.min(np.log10(L_array))-2, np.max(np.log10(L_array))+2, 100)

for i in range(size_num):
    current_L_array = L_array[i, :, :].mean(axis=0)
    current_dl_L_array = dl_L_array[i, :, :].mean(axis=0)
    x = np.log10(current_L_array)
    y = current_dl_L_array
    popt, pcov = curve_fit(sigmoid, x, y, p0=p0)

    # 绘制散点和拟合曲线
    plt.scatter(x, y, label=f'Size {size_values[i]}')
    plt.plot(x_fit, sigmoid(x_fit, *popt), label=f'Fit - Size {size_values[i]}', linestyle='--')

# Fit all:
current_L_array = L_array.mean(axis=1).flatten()
current_dl_L_array = dl_L_array.mean(axis=1).flatten()
x = np.log10(current_L_array)
y = current_dl_L_array
popt, pcov = curve_fit(sigmoid, x, y, p0=p0)

# 绘制拟合曲线
plt.plot(x_fit, sigmoid(x_fit, *popt), label=f'Fit - All Sizes', linestyle='--')

plt.legend()
plt.title('Sigmoid Fit for All Sizes')
plt.xlabel('log10(Luminance)')
plt.ylabel('deltaL/L')
plt.show()
