import json
import pandas as pd
import numpy as np
import os

def read_calibration_result(base_path):
    with open(os.path.join(base_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    result_data = pd.read_csv(os.path.join(base_path, 'final_result.csv'))
    size_list = config_data['rect_params']['Size']
    repeat_time = config_data['rect_params']['Repeat']
    scale = config_data['color_change_parameters']['scale']
    Pixel_value_range = config_data['color_change_parameters']['Pixel_value_range']
    sample_numbers = config_data['color_change_parameters']['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)

    Luminance_array = np.zeros((len(size_list), pixel_all_values.shape[0], repeat_time))
    for size_index in range(len(size_list)):
        size_value = size_list[size_index]
        for color_index in range(len(pixel_all_values)):
            color_value = pixel_all_values[color_index]
            for repeat_index in range(repeat_time):
                filter_result = result_data[
                    (result_data['size'] == str(size_value)) & (np.abs(result_data['color']-color_value)<1e-6) & (
                                result_data['repeat'] == repeat_index)]
                Luminance = filter_result['Y'].item()
                Luminance_array[size_index, color_index, repeat_index] = Luminance
    return pixel_all_values, Luminance_array, size_list

def read_calibration_result_2(base_path):
    with open(os.path.join(base_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    result_data = pd.read_csv(os.path.join(base_path, 'final_result.csv'))
    size_list = config_data['stimulus_params']['Size']
    repeat_time = config_data['stimulus_params']['Repeat']
    scale = config_data['color_change_parameters']['scale']
    Pixel_value_range = config_data['color_change_parameters']['Pixel_value_range']
    sample_numbers = config_data['color_change_parameters']['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)

    Luminance_array = np.zeros((len(size_list), pixel_all_values.shape[0], repeat_time))
    for size_index in range(len(size_list)):
        size_value = size_list[size_index]
        for color_index in range(len(pixel_all_values)):
            color_value = pixel_all_values[color_index]
            for repeat_index in range(repeat_time):
                filter_result = result_data[
                    (result_data['size'] == str(size_value)) & (np.abs(result_data['color']-color_value)<1e-6) & (
                                result_data['repeat'] == repeat_index)]
                Luminance = filter_result['Y'].item()
                Luminance_array[size_index, color_index, repeat_index] = Luminance
    return pixel_all_values, Luminance_array, size_list

if __name__ == '__main__':
    base_path = r'py_display_calibration_results_new\LG-G1-Std-2023_12_23_16_14_06'
    pixel_all_values, Luminance_array, size_list = read_calibration_result(base_path=base_path)