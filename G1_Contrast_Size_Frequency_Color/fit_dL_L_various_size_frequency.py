import numpy as np
import matplotlib.pyplot as plt
import json

fit_degree_list = [2,3,4,5]

def get_color_values(color_change_parameters):
    scale = color_change_parameters['scale']
    Pixel_value_range = color_change_parameters['Pixel_value_range']
    sample_numbers = color_change_parameters['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)
    return pixel_all_values


with open('B:\Py_codes\VRR_Real\G1_Contrast_Size_Frequency_Color/deltaL_L_10second_9VRR_4Size_2repeat_30color_log10.json', 'r') as fp:
    Temporal_Flicker_meter_data = json.load(fp)

KONICA_Luminance_array = np.array(Temporal_Flicker_meter_data['KONICA_Luminance'])
Luminance_array = np.array(Temporal_Flicker_meter_data['L'])
delta_Luminance_array = np.array(Temporal_Flicker_meter_data['dL'])
config_data = Temporal_Flicker_meter_data['config_data']

VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
Size_list = config_data['change_params']['Size']
Repeat_times = config_data['change_params']['Repeat_times']
pixel_all_values = get_color_values(config_data['color_change_parameters'])

x_fit_range = np.linspace(np.min(np.log10(Luminance_array)), np.max(np.log10(Luminance_array)), 100)
plt.figure(figsize=(40,20))
json_fit_result_coefficients = {}
for size_index in range(len(Size_list)):
    size_value = Size_list[size_index]
    for vrr_f_index in range(len(VRR_Frequency_list)):
        vrr_f_value = VRR_Frequency_list[vrr_f_index]
        json_fit_result_coefficients[f'Size_{size_value}_VRR_F_{vrr_f_value}'] = {}
        plt.subplot(len(Size_list), len(VRR_Frequency_list), size_index * len(VRR_Frequency_list) + vrr_f_index + 1)
        current_L_array = Luminance_array[size_index, vrr_f_index].flatten()
        current_dL_array = delta_Luminance_array[size_index, vrr_f_index].flatten()
        current_dL_L_array = current_dL_array / current_L_array
        x = np.log10(current_L_array)
        y = current_dL_L_array
        for fit_degree in fit_degree_list:
            coefficients = np.polyfit(x, y, fit_degree)
            json_fit_result_coefficients[f'Size_{size_value}_VRR_F_{vrr_f_value}'][f'degree_{fit_degree}_coefficients'] = coefficients.tolist()
            fitted_curve = np.polyval(coefficients, x_fit_range)
            plt.plot(x_fit_range, fitted_curve, label=f'polynomial fitting - degree {fit_degree}', linestyle='-')
        plt.xlabel('Luminance (cd/m$^2$)')
        plt.ylabel('Contrast')
        plt.title(f'Size_{size_value}_Frequency_of_RR_switch_{vrr_f_value}')
        plt.scatter(x, y)
        plt.legend()
plt.tight_layout()
plt.savefig('B:\Py_codes\VRR_Real\G1_Contrast_Size_Frequency_Color/dl_L_split.png')

plt.figure(figsize=(10,10))
current_L_array_all = Luminance_array.flatten()
current_dl_array_all = delta_Luminance_array.flatten()
current_dl_L_array_all = current_dl_array_all / current_L_array_all
x = np.log10(current_L_array_all)
y = current_dl_L_array_all
json_fit_result_coefficients[f'All_in_all'] = {}
for fit_degree in fit_degree_list:
    coefficients = np.polyfit(x, y, fit_degree)
    json_fit_result_coefficients[f'All_in_all'][
        f'degree_{fit_degree}_coefficients'] = coefficients.tolist()
    fitted_curve = np.polyval(coefficients, x_fit_range)
    plt.plot(x_fit_range, fitted_curve, label=f'polynomial fitting - degree {fit_degree}', linestyle='--')
plt.xlabel('Luminance (cd/m$^2$)')
plt.ylabel('Contrast')
plt.scatter(x, y)
plt.legend()
plt.tight_layout()
plt.savefig('B:\Py_codes\VRR_Real\G1_Contrast_Size_Frequency_Color/dl_L_all.png')