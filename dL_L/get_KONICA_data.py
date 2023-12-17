import numpy as np
import json
import os
import matplotlib.pyplot as plt

def get_KONICA_data(base_path):
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

    x_axis_L_sizes = []
    y_axis_dl_sizes = []
    y_axis_dl_L_sizes = []
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
                dl = np.abs(luminance_30 - luminance_120)
                # dl = luminance_30 - luminance_120
                x_axis_L.append(L)
                y_axis_dl.append(dl)
                y_axis_dl_L.append(dl / L)
            x_axis_L_repeats.append(x_axis_L)
            y_axis_dl_repeats.append(y_axis_dl)
            y_axis_dl_L_repeats.append(y_axis_dl_L)
        x_axis_L_sizes.append(x_axis_L_repeats)
        y_axis_dl_sizes.append(y_axis_dl_repeats)
        y_axis_dl_L_sizes.append(y_axis_dl_L_repeats)
    return np.array(x_axis_L_sizes), np.array(y_axis_dl_sizes), np.array(y_axis_dl_L_sizes), size_values