import matplotlib.pyplot as plt
import numpy as np
import json
import os

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

if __name__ == '__main__':
    exp_log_path = r'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1'
    luminance_index = 1
    size_index = 4
    vrr_f_index = 2
    repeat_index = 0
    file_name = os.path.join(exp_log_path, f'Luminance_{luminance_index}_Size_{size_index}_VRR_Frequency_{vrr_f_index}', f'{repeat_index}.json')
    with open(file_name, 'r') as fp:
        exp_data = json.load(fp)
    x_time_array = np.array(exp_data['x_time'])
    y_luminance_array = np.array(exp_data['y_luminance_scale'])
    compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array,
                       frequency_upper=120, plot_FFT=True, skip_0=True, force_equal=True)