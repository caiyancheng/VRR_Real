import os
import matplotlib.pyplot as plt
import json

base_path = 'E:\Datasets\Subjective_Exp_1\Subjective_Exp_1'

def draw_temporal_flicker_meter(Luminance_value, Size_value, VRR_Frequency, repeat_index):
    file_name = os.path.join(base_path, f'Luminance_{Luminance_value}_Size_{Size_value}_VRR_Frequency_{VRR_Frequency}',
                             f'{repeat_index}.json')
    with open(file_name, 'r') as fp:
        signal_data = json.load(fp)
    x_time_array = signal_data['x_time']
    y_luminance_array = signal_data['y_luminance_scale']
    plt.figure()
    plt.plot(x_time_array, y_luminance_array)
    plt.xlim(0, 0.25)
    plt.ylim(0, max(y_luminance_array) * 1.1)
    plt.xlabel('Time in seconds')
    plt.ylabel('Luminance (nits)')
    plt.show()

def draw_temporal_flicker_meter_repeat_set(Luminance_value, Size_value, VRR_Frequency):
    plt.figure(figsize=(10,4))
    for repeat_index in range(4):
        file_name = os.path.join(base_path,
                                 f'Luminance_{Luminance_value}_Size_{Size_value}_VRR_Frequency_{VRR_Frequency}',
                                 f'{repeat_index}.json')
        with open(file_name, 'r') as fp:
            signal_data = json.load(fp)
        x_time_array = signal_data['x_time']
        y_luminance_array = signal_data['y_luminance_scale']
        plt.subplot(2, 2, repeat_index+1)
        plt.plot(x_time_array, y_luminance_array)
        plt.xlim(0, 0.2)
        plt.ylim(0, 6)
        plt.xlabel('Time in seconds')
        plt.ylabel('Luminance (nits)')
    plt.show()

if __name__ == '__main__':
    Luminance_value = 100
    Size_value = 4
    VRR_Frequency = 10
    repeat_index = 1
    draw_temporal_flicker_meter(Luminance_value=Luminance_value,
                                Size_value=Size_value,
                                VRR_Frequency=VRR_Frequency,
                                repeat_index=repeat_index)
    # draw_temporal_flicker_meter_repeat_set(Luminance_value=Luminance_value,
    #                                        Size_value=Size_value,
    #                                        VRR_Frequency=VRR_Frequency)
