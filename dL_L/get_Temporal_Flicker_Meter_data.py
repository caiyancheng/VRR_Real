import matplotlib.pyplot as plt
import numpy as np
import os
import json
from dL_L.get_KONICA_data import get_KONICA_data
from Computational_Model.FFT import compute_signal_FFT
from tqdm import tqdm

def find_nearest_index(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx

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

def get_Temporal_Flicker_Meter_data(root_path):
    with open(os.path.join(root_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
    Size_list = config_data['change_params']['Size']
    Repeat_times = config_data['change_params']['Repeat_times']
    pixel_all_values = get_color_values(config_data['color_change_parameters'])

    return_abnormal_array = np.zeros(shape=(len(Size_list), len(VRR_Frequency_list), Repeat_times, len(pixel_all_values))) #如果measurements长度不够，则需要将其置为异常
    return_L_array = np.zeros(shape=(len(Size_list), len(VRR_Frequency_list), Repeat_times, len(pixel_all_values)))
    return_dL_array = np.zeros(shape=(len(Size_list), len(VRR_Frequency_list), Repeat_times, len(pixel_all_values)))

    x_L_array, y_dl_array, y_dl_L_array, _ = get_KONICA_data(base_path='LG_G1_KONICA_5')

    for size_index in range(len(Size_list)): #3
        size_value = Size_list[size_index]
        for vrr_f_index in tqdm(range(len(VRR_Frequency_list))): #6
            vrr_f_value = VRR_Frequency_list[vrr_f_index]
            for color_index in range(len(pixel_all_values)): #30
                color_value = pixel_all_values[color_index]
                for repeat_index in range(Repeat_times): #10
                    json_data_path = os.path.join(root_path, f'S_{size_value}_V_{vrr_f_value}_C_{color_value}', f'{repeat_index}.json')
                    with open(json_data_path, 'r') as fp:
                        temporal_log_data = json.load(fp)
                    measurements = np.array(temporal_log_data['measurements'])
                    if config_data['record_params']['num_flicker_meter_sample'] == len(measurements):
                        return_abnormal_array[size_index, vrr_f_index, repeat_index, color_index] = 0
                    else:
                        return_abnormal_array[size_index, vrr_f_index, repeat_index, color_index] = 1
                    KONICA_Luminance = x_L_array[size_index, :,color_index].mean()
                    x_time_array = np.arange(len(measurements)) * config_data['record_params']['time_flicker_meter_log'] / config_data['record_params']['num_flicker_meter_sample']
                    y_luminance_array = measurements / measurements.mean() * KONICA_Luminance
                    x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array,
                                                                   frequency_upper=120, plot_FFT=False, skip_0=False, force_equal=True)
                    return_L_array[size_index, vrr_f_index, repeat_index, color_index] = y_luminance_array.mean()
                    return_dL_array[size_index, vrr_f_index, repeat_index, color_index] = K_FFT_array[find_nearest_index(x_freq_array, vrr_f_value)]

    return return_L_array, return_dL_array, return_abnormal_array

if __name__ == '__main__':
    return_L_array, return_dL_array, return_abnormal_array = get_Temporal_Flicker_Meter_data(root_path=r'B:\Datasets\Temporal_Flicker_Meter_log\deltaL_L_10s\2023-12-19-20-43-10')
    print('Abnormal Numbers', return_abnormal_array.sum())
    save_path = 'Temporal_Results'
    os.makedirs(save_path, exist_ok=True)
    json_result_dict = {
        'L': return_L_array.tolist(),
        'dL': return_dL_array.tolist(),
        'abnormal': return_abnormal_array.tolist()
    }
    with open(os.path.join(save_path, 'dl_L_results_10s_5r.json'), 'w') as fp:
        json.dump(json_result_dict, fp)