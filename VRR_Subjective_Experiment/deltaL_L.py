import matplotlib.pyplot as plt
import numpy as np
import json
import os
from tqdm import tqdm

def find_value(values, aim_value):
    differences = np.abs(values - aim_value)
    index = np.argmin(differences)
    return index

def plot_pict(x_array, y_array, x_label, y_label, title, fig_size=False, save=False, save_fig_name='no name'):
    if fig_size:
        plt.figure(figsize=fig_size)
    plt.plot(x_array, y_array)
    plt.title(label=title)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    if save:
        plt.savefig(f'{save_fig_name}.png')
        plt.close()
    else:
        plt.show()

def compute_signal_FFT(x_time_array, y_luminance_array, frequency_upper=240, plot_FFT=False, skip_0=True, force_equal=True):
    if force_equal:
        y_luminance_array[-1] = y_luminance_array[0]
    w_s = 1 / (x_time_array[1:] - x_time_array[:-1]).mean()
    N_s = x_time_array.shape[0]
    K_FFT = np.abs(np.fft.fft(y_luminance_array)) / N_s
    x_freq = np.arange(0, N_s) * w_s / N_s
    x_freq_sub = x_freq[x_freq <= frequency_upper]  # 只看240帧以下
    N_s_sub = x_freq_sub.shape[0]

    if plot_FFT:
        if skip_0:
            plot_pict(x_array=x_freq[1:N_s_sub], y_array=K_FFT[1:N_s_sub],
                      x_label='Frequency', y_label='Amplitude',
                      title='spectrum overall', save=False)
        else:
            plot_pict(x_array=x_freq[0:N_s_sub], y_array=K_FFT[0:N_s_sub],
                      x_label='Frequency', y_label='Amplitude',
                      title='spectrum overall', save=False)

    return x_freq[0:N_s_sub], K_FFT[0:N_s_sub]

def compute_deltaL_L_all(luminance_list, size_list, vrr_f_list):
    exp_log_path = r'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1'
    # plt.figure(figsize=(10,5))
    deltaL_L_json_dict = {}
    for size_index in tqdm(range(len(size_list))):
        size_value = size_list[size_index]
        for vrr_f_index in range(len(vrr_f_list)):
            vrr_f_value = vrr_f_list[vrr_f_index]
            plot_luminance_list = []
            plot_deltaL_list = []
            plot_detlaL_L_list = []
            for luminance_index in range(len(luminance_list)):
                luminance_value = luminance_list[luminance_index]
                plot_luminance_list.append(luminance_value)
                deltaL_set = []
                for repeat_index in range(10):
                    file_name = os.path.join(exp_log_path, f'Luminance_{luminance_value}_Size_{size_value}_VRR_Frequency_{vrr_f_value}', f'{repeat_index}.json')
                    with open(file_name, 'r') as fp:
                        exp_data = json.load(fp)
                    x_time_array = np.array(exp_data['x_time'])
                    y_luminance_array = np.array(exp_data['y_luminance_scale'])
                    x_freq_sub, K_FFT_sub = compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array,
                                                               frequency_upper=120, plot_FFT=False, skip_0=True, force_equal=True)
                    index = find_value(x_freq_sub, vrr_f_value)
                    deltaL = K_FFT_sub[index]
                    deltaL_set.append(deltaL)
                plot_deltaL_list.append(np.array(deltaL_set).mean())
                plot_detlaL_L_list.append(np.array(deltaL_set).mean()/luminance_value)
            # plt.subplot(len(size_list), len(vrr_f_list), size_index * len(vrr_f_list) + vrr_f_index + 1)
            # plt.plot(plot_luminance_list, plot_deltaL_list)
            # plt.xlabel('Luminance')
            # plt.ylabel('deltaL amplitude')
            deltaL_L_json_sub_dict = {'Luminance': plot_luminance_list,
                                      'deltaL': plot_deltaL_list,
                                      'deltaL_L': plot_detlaL_L_list}
            deltaL_L_json_dict[f'size_{size_value}_vrr_f_{vrr_f_value}'] = deltaL_L_json_sub_dict
    with open(r'E:\Py_codes\VRR_Real/deltaL_L_LG_G1.json', 'w') as fp:
        json.dump(deltaL_L_json_dict, fp)

def plot_deltaL_L(size_list, vrr_f_list):
    with open(r'E:\Py_codes\VRR_Real/deltaL_L_LG_G1.json', 'r') as fp:
        deltaL_L_json_dict = json.load(fp)
    fig1, ax1 = plt.subplots()
    fig1.suptitle('Plot of deltaL vs Luminance')
    fig2, ax2 = plt.subplots()
    fig2.suptitle('Plot of deltaL/L vs Luminance')

    for size_index in tqdm(range(len(size_list))):
        size_value = size_list[size_index]
        for vrr_f_index in range(len(vrr_f_list)):
            vrr_f_value = vrr_f_list[vrr_f_index]
            deltaL_L_json_sub_dict = deltaL_L_json_dict[f'size_{size_value}_vrr_f_{vrr_f_value}']
            plot_luminance_list = deltaL_L_json_sub_dict['Luminance']
            plot_deltaL_list = deltaL_L_json_sub_dict['deltaL']
            plot_detlaL_L_list = deltaL_L_json_sub_dict['deltaL_L']
            ax1.plot(plot_luminance_list, plot_deltaL_list, label=f'Size: {size_value}, VRR_f: {vrr_f_value}')
            # ax1.set_title(f'Size: {size_value}, Frequency of RR switch: {vrr_f_value}')
            ax2.plot(plot_luminance_list, plot_detlaL_L_list, label=f'Size: {size_value}, VRR_f: {vrr_f_value}')
            # ax2.set_title(f'Size: {size_value}, Frequency of RR switch: {vrr_f_value}')
    ax1.set_xlabel('Luminance')
    ax1.set_ylabel('deltaL')
    ax1.legend()
    ax2.set_xlabel('Luminance')
    ax2.set_ylabel('deltaL/L')
    ax2.legend()
    plt.show()


if __name__ == '__main__':
    luminance_list = [1,2,3,4,5,10,100]
    size_list = [4, 16]
    vrr_f_list = [2, 5, 10]
    # compute_deltaL_L_all(luminance_list=luminance_list, size_list=size_list, vrr_f_list=vrr_f_list)
    plot_deltaL_L(size_list, vrr_f_list)