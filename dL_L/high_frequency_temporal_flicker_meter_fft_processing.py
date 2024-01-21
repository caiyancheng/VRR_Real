import matplotlib.pyplot as plt
import numpy as np
import os
import json
from dL_L.get_KONICA_data import get_KONICA_data
from Computational_Model.FFT import compute_signal_FFT
from tqdm import tqdm

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

def get_Temporal_Flicker_meter_data_and_fft(Dataset_path):
    config_file = os.path.join(Dataset_path, 'config.json')
    with open(config_file, 'r') as fp:
        config_data = json.load(fp)
    VRR_Frequency_list = config_data['change_params']['VRR_Frequency']
    Size_list = config_data['change_params']['Size']
    Repeat_times = config_data['change_params']['Repeat_times']
    pixel_all_values = get_color_values(config_data['color_change_parameters'])

    os.makedirs(os.path.join(Dataset_path, 'plot_all_FFT_results'), exist_ok=True)
    plt.figure(figsize=(50, 30))
    for size_index in range(len(Size_list)):  # 3
        size_value = Size_list[size_index]
        for vrr_f_index in tqdm(range(len(VRR_Frequency_list))):  # 6
            vrr_f_value = VRR_Frequency_list[vrr_f_index]

            # cmap = plt.get_cmap('rainbow')
            plt.subplot(len(Size_list), len(VRR_Frequency_list), size_index*len(VRR_Frequency_list)+vrr_f_index+1)
            for color_index in range(len(pixel_all_values)):  # 30
                color_value = pixel_all_values[color_index]
                for repeat_index in range(Repeat_times):  # 101
                    json_data_path = os.path.join(Dataset_path, f'S_{size_value}_V_{vrr_f_value}_C_{color_value}',
                                                  f'{repeat_index}.json')
                    with open(json_data_path, 'r') as fp:
                        temporal_log_data = json.load(fp)
                    measurements = np.array(temporal_log_data['measurements'])
                    if config_data['record_params']['num_flicker_meter_sample'] == len(measurements):
                        abnormal = 0
                    else:
                        abnormal = 1
                    x_time_array = np.arange(len(measurements)) * config_data['record_params'][
                        'time_flicker_meter_log'] / config_data['record_params']['num_flicker_meter_sample']
                    y_fake_luminance_array = measurements / measurements.mean()
                    x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array,
                                                                   y_luminance_array=y_fake_luminance_array,
                                                                   frequency_upper=150, plot_FFT=False, skip_0=False,
                                                                   force_equal=True)
                    plt.plot(x_freq_array[1:], K_FFT_array[1:])
                    plt.xlabel('Frequency (Hz)')
                    plt.ylabel('Normalized Amplitude')
                    plt.title(f'Size_{size_value}_VRR_Frequency_{vrr_f_value}')
                    plt.axvline(x=vrr_f_value, color='y', linestyle='--', label=f'{vrr_f_value} Hz (Flicker)',
                                linewidth=0.5)  # 添加竖线
                    plt.axvline(x=30, color='g', linestyle='--', label='30 Hz', linewidth=0.5)  # 添加竖线
                    plt.axvline(x=120, color='b', linestyle='--', label='120 Hz', linewidth=0.5)  # 添加竖线
    # plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.2), ncol=5)
    plt.tight_layout()
    plt.savefig(os.path.join(Dataset_path, 'plot_all_FFT_results', f'overa_all.png'))

if __name__ == '__main__':
    Dataset_path = r'E:\Datasets\Temporal_Flicker_Meter_log_new\deltaL_L_10second_9VRR_4Size_2repeat_30color_log10\2024-01-21-00-53-48'
    get_Temporal_Flicker_meter_data_and_fft(Dataset_path=Dataset_path)
