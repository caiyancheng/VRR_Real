import numpy as np
import json
import os
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter


def sigmoid(x, k, x0):
    return 1 / (1 + np.exp(-k * (x - x0)))

# plt.rc('font', family='Times New Roman')
font_dict = {'family': 'Times New Roman', 'fontsize': 14}
base_path = 'LG_G1_KONICA_10'
# base_path = 'LG_G1_KONICA_5'
with open(os.path.join(base_path, 'result.json'), 'r') as fp:
    result_data = json.load(fp)
with open(os.path.join(base_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)

# pixel_all_values = np.arange(config_data['Pixel_value_range'][0], config_data['Pixel_value_range'][1], config_data['Pixel_value_step'])
if config_data['scale'] == 'Linear':
    pixel_all_values = np.linspace(config_data['Pixel_value_range'][0], config_data['Pixel_value_range'][1], num=config_data['sample_numbers'])
elif config_data['scale'] == 'Log10':
    if config_data['Pixel_value_range'][0] == 0:
        config_data['Pixel_value_range'][0] = 0.001
    pixel_all_values = np.logspace(np.log10(config_data['Pixel_value_range'][0]), np.log10(config_data['Pixel_value_range'][1]), num=config_data['sample_numbers'])
size_values = config_data['Size']
repeat_times = config_data['repeat_times']

plt.figure(figsize=(12,4))


for size_value in size_values:
    x_axis_L_repeats = []
    y_axis_dl_repeats = []
    y_axis_dl_L_repeats = []
    for repeat_time in range(repeat_times):
        x_axis_L = []
        y_axis_dl = []
        y_axis_dl_L = []
        for color_value in pixel_all_values:
            result_index = result_data[f'S_{size_value}_C_{color_value}_R_{repeat_time}']
            luminance_30 = result_index['30'][0]
            luminance_120 = result_index['120'][0]
            if np.isnan(luminance_30) or np.isnan(luminance_120):
                print('NAN')
                continue
            # if luminance_30 < 1 or luminance_120 < 1:
            #     continue
            L = (luminance_30 + luminance_120) / 2
            # dl = np.abs(luminance_30 - luminance_120)
            dl = luminance_30 - luminance_120
            dl = dl/2
            x_axis_L.append(L)
            y_axis_dl.append(dl)
            y_axis_dl_L.append(dl / L)
        if len(x_axis_L) != 30:
            continue
        x_axis_L_repeats.append(x_axis_L)
        y_axis_dl_repeats.append(y_axis_dl)
        y_axis_dl_L_repeats.append(y_axis_dl_L)
    x_axis_L_mean = np.array(x_axis_L_repeats).mean(axis=0)
    y_axis_dl_mean = np.array(y_axis_dl_repeats).mean(axis=0)
    y_axis_dl_L_mean = np.array(y_axis_dl_L_repeats).mean(axis=0)
    if size_value == 'full':
        plt.subplot(1, 3, 1)
        plt.plot(x_axis_L_mean, y_axis_dl_mean, marker='o', markersize=6,
                 label=f'63 * 38 degree$^2$ (full screen)')
        plt.subplot(1, 3, 2)
        plt.plot(x_axis_L_mean, np.abs(y_axis_dl_L_mean), marker='o', markersize=6,
                 label=f'63 * 38 degree$^2$ (full screen)')
    else:
        plt.subplot(1, 3, 1)
        plt.plot(x_axis_L_mean, y_axis_dl_mean, marker='o', markersize=6,
                 label=f'{size_value} * {size_value} degree$^2$')
        plt.subplot(1, 3, 2)
        plt.plot(x_axis_L_mean, np.abs(y_axis_dl_L_mean), marker='o', markersize=6,
                 label=f'{size_value} * {size_value} degree$^2$')



with open(f'KONICA_Fit_result_sigmoid.json', 'r') as fp:
    fit_sigmoid_result = json.load(fp)
popt = fit_sigmoid_result['size_all']['popt']
x_fit_plot = np.logspace(np.log10(0.01),np.log10(max(x_axis_L_mean))+1,100)
# x_fit_plot = np.linspace(min(x_axis_L_mean)-1,max(x_axis_L_mean)+2,100)
fitted_curve_sigmoid = sigmoid(np.log10(x_fit_plot), *popt)

plt.subplot(1, 3, 1)
plt.title('$\Delta L$ vs Luminance', fontsize=14)
plt.xlabel('Luminance (nits)', fontsize=14)
plt.ylabel('$\Delta L$', rotation=0, fontsize=14)
plt.xscale('log')
formatter = ScalarFormatter()
formatter.set_scientific(False)  # 禁用科学计数法
plt.gca().xaxis.set_major_formatter(formatter)
plt.xticks([1,10,100])
plt.grid(True)
plt.axhline(y=0, color='b', linestyle='--', label='$\Delta L$ = 0', linewidth=2)
plt.legend()

plt.subplot(1, 3, 2)
# plt.plot(x_fit_plot, fitted_curve_sigmoid, label=f'sigmoid function fitting', linewidth=2, alpha=1)
# plt.plot(x_fit_plot, fitted_curve_poly, label=f'polynomial function fitting - degree={fit_poly_degree}', linewidth=2, alpha=1)
plt.title('Michelson Contrast vs Luminance', fontsize=14)
plt.xlabel('Luminance (nits)', fontsize=14)
plt.ylabel('Michelson Contrast', fontsize=14)
plt.xscale('log')
formatter = ScalarFormatter()
formatter.set_scientific(False)  # 禁用科学计数法
plt.gca().xaxis.set_major_formatter(formatter)
plt.xticks([1,10,100])
plt.xlim([0.5,1000])
plt.ylim([-0.002,0.07])
plt.grid(True)
plt.axhline(y=0, color='b', linestyle='--', label='contrast = 0', linewidth=2)
plt.legend()

plt.subplot(1, 3, 3)
plt.plot(x_fit_plot, fitted_curve_sigmoid, label=f'sigmoid fitting', linewidth=2, alpha=1)
fit_poly_degree_list = [2,3,4,5]
for fit_poly_degree in fit_poly_degree_list:
    with open(f'KONICA_Fit_result_poly_{fit_poly_degree}.json', 'r') as fp:
        fit_poly_result = json.load(fp)
    coefficients = fit_poly_result['coefficients']
    fitted_curve_poly = np.polyval(coefficients, np.log10(x_fit_plot))
    plt.plot(x_fit_plot, fitted_curve_poly, label=f'polynomial fitting - {fit_poly_degree}d', linewidth=2, alpha=1)
plt.title('Michelson Contrast Curve Fitting', fontsize=14)
plt.xlabel('Luminance (nits)', fontsize=14)
plt.ylabel('Michelson Contrast', fontsize=14)
plt.xscale('log')
formatter = ScalarFormatter()
formatter.set_scientific(False)  # 禁用科学计数法
plt.gca().xaxis.set_major_formatter(formatter)
plt.xticks([1,10,100])
plt.xlim([0.5,1000])
plt.ylim([-0.002,0.07])
plt.grid(True)
plt.axhline(y=0, color='b', linestyle='--', label='contrast = 0', linewidth=2)
plt.legend()
# Show legends for both figures

plt.subplots_adjust(left=0.05, right=0.99, top=0.92, bottom=0.13, wspace=0.25)
# Show the plots
# plt.show()
plt.savefig(f'B:\All_Conference_Papers\SIGGRAPH24\Images/deltaL-L.png', dpi=300)
