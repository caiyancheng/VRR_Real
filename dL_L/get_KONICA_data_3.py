import numpy as np
import json
import os
import matplotlib.pyplot as plt
# 与2相比,这里每一个repeat都被当作独立轮

def get_KONICA_data(base_path, abs=True):
    with open(os.path.join(base_path, 'result.json'), 'r') as fp:
        result_data = json.load(fp)
    with open(os.path.join(base_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    if config_data['scale'] == 'Linear':
        pixel_all_values = np.linspace(config_data['Pixel_value_range'][0], config_data['Pixel_value_range'][1],
                                       num=config_data['sample_numbers'])
    elif config_data['scale'] == 'Log10':
        if config_data['Pixel_value_range'][0] == 0:
            config_data['Pixel_value_range'][0] = 0.001
        pixel_all_values = np.logspace(np.log10(config_data['Pixel_value_range'][0]),
                                       np.log10(config_data['Pixel_value_range'][1]), num=config_data['sample_numbers'])
    size_values = config_data['Size']
    repeat_times = config_data['repeat_times']

    x_color_array = np.array(pixel_all_values)
    x_axis_L_sizes = []
    y_axis_dl_sizes = []
    y_axis_dl_L_sizes = []
    for size_value in size_values:
        x_axis_L = []
        y_axis_dl = []
        y_axis_dl_L = []
        for repeat_time in range(repeat_times):
            for color_value in pixel_all_values:
                result_index = result_data[f'S_{size_value}_C_{color_value}_R_{repeat_time}']
                luminance_30 = result_index['30'][0]
                luminance_120 = result_index['120'][0]
                if np.isnan(luminance_30) or np.isnan(luminance_120):
                    print('NAN')
                    continue
                L = (luminance_30 + luminance_120) / 2
                if L < 0.5:
                    continue
                if abs:
                    dl = np.abs(luminance_30 - luminance_120) / 2
                else:
                    dl = (luminance_30 - luminance_120) / 2
                x_axis_L.append(L)
                y_axis_dl.append(dl)
                y_axis_dl_L.append(dl / L)
        x_axis_L_sizes.append(np.array(x_axis_L))
        y_axis_dl_sizes.append(np.array(y_axis_dl))
        y_axis_dl_L_sizes.append(np.array(y_axis_dl_L))
    return x_color_array, x_axis_L_sizes, y_axis_dl_sizes, y_axis_dl_L_sizes, size_values


if __name__ == '__main__':
    x_C_array, x_L_array, y_dl_array, y_dl_L_array, sizes = get_KONICA_data(base_path='B:\Py_codes\VRR_Real\dL_L_PC_datasets\short_range_LG_G1_KONICA_multi_points\9_points\point_-0.95_-0.95\KONICA_2024-01-28-17-25-20')
    X = 1