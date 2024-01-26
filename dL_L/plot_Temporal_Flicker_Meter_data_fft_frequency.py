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

def plot_Temporal_Flicker_Meter_data(root_path):
    with open(os.path.join(root_path, 'config.json'), 'r') as fp:
        config_data = json.load(fp)
    VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
    Size_list = config_data['change_params']['Size']
    Repeat_times = config_data['change_params']['Repeat_times']
    pixel_all_values = get_color_values(config_data['color_change_parameters'])

    return_abnormal_array = np.zeros(shape=(len(Size_list), len(VRR_Frequency_list), Repeat_times, len(pixel_all_values))) #如果measurements长度不够，则需要将其置为异常

    x_L_array, y_dl_array, y_dl_L_array, _ = get_KONICA_data(base_path='LG_G1_KONICA_10')

    plt.figure(figsize=(40, 40))
    for size_index in range(len(Size_list)): #3
        size_value = Size_list[size_index]
        for vrr_f_index in tqdm(range(len(VRR_Frequency_list))): #6
            vrr_f_value = VRR_Frequency_list[vrr_f_index]
            plt.subplot(len(VRR_Frequency_list), len(Size_list), vrr_f_index * len(Size_list) + size_index + 1)
            for color_index in range(len(pixel_all_values)): #30
                color_value = pixel_all_values[color_index]
                for repeat_index in range(Repeat_times): #10
                    if repeat_index != 0:
                        continue
                    json_data_path = os.path.join(root_path, f'S_{size_value}_V_{vrr_f_value}_C_{color_value}', f'{repeat_index}.json')
                    with open(json_data_path, 'r') as fp:
                        temporal_log_data = json.load(fp)
                    measurements = np.array(temporal_log_data['measurements'])
                    if config_data['record_params']['num_flicker_meter_sample'] == len(measurements):
                        return_abnormal_array[size_index, vrr_f_index, repeat_index, color_index] = 0
                    else:
                        return_abnormal_array[size_index, vrr_f_index, repeat_index, color_index] = 1
                    KONICA_Luminance = x_L_array[size_index, :, color_index].mean()
                    x_time_array = np.arange(len(measurements)) * config_data['record_params']['time_flicker_meter_log'] / config_data['record_params']['num_flicker_meter_sample']
                    y_luminance_array = measurements / measurements.mean() * KONICA_Luminance
                    x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array,
                                                                   y_luminance_array=y_luminance_array,
                                                                   frequency_upper=120, plot_FFT=False, skip_0=False,
                                                                   force_equal=True)
                    plt.title(f'VRR_f_{vrr_f_value}_Size_{size_value}')
                    plt.plot(x_freq_array[1:], K_FFT_array[1:], label=f'Color_{round(color_value, 4)}')
                    plt.xlabel('frequency (Hz)')
                    plt.ylabel('Amplitude')
                    plt.ylim([0,0.4])
            plt.tight_layout()
            plt.legend(ncol=3)
    plt.savefig(f"B:\Datasets\FFT_frequency_plot/ALL.png")
    plt.close()

if __name__ == '__main__':
    root_path = r'B:\Datasets\Temporal_Flicker_Meter_log_Krypton\deltaL_L_10second_9VRR_4Size_2repeat_30color_log10\2024-01-26-01-22-07'
    plot_Temporal_Flicker_Meter_data(root_path=root_path)