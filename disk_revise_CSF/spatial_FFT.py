import math
import numpy as np
import matplotlib.pyplot as plt

screen_width = 1.2176
screen_height = 0.6849
screen_width_resolution = 3840
screen_height_resolution = 2160
distance = 1

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

def rectangle_signal(degree_down, degree_up, signal_degree_down, signal_degree_up, signal_I, sample_points=10000):
    degree_up = 100
    degree_down = -100
    x = np.arange(degree_down, degree_up, (degree_up-degree_down)/sample_points)
    y = np.zeros(x.shape)
    y[(x>signal_degree_down)&(x<signal_degree_up)] = signal_I
    return x, y

def spaitial_FFT_function(Luminance, size, s_f):
    r = math.radians(size) / 2
    y = r * Luminance / 1000 * np.sinc(2*r*s_f)
    return y

def compute_spatial_FFT(x_spatial_array, y_stimulus_array, frequency_upper=240, plot_FFT=False, skip_0=True, force_equal=True):
    if force_equal:
        y_stimulus_array[-1] = y_stimulus_array[0]
    w_s = 1 / (x_spatial_array[1:] - x_spatial_array[:-1]).mean()
    N_s = x_spatial_array.shape[0]
    K_FFT = np.abs(np.fft.fft(y_stimulus_array)) / N_s
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
def generate_signal(size, luminance, plot=False):
    # size_radians = math.radians(size)
    visual_degree_left = math.degrees(-math.atan(screen_width / (2 * distance)))
    visual_degree_right = math.degrees(math.atan(screen_width / (2 * distance)))
    visual_degree_down = math.degrees(-math.atan(screen_height / (2 * distance)))
    visual_degree_up = math.degrees(math.atan(screen_height / (2 * distance)))
    horizontal_x, horizontal_y = rectangle_signal(visual_degree_left, visual_degree_right, - size / 2,
                                                  size / 2, luminance)
    vertical_x, vertical_y = rectangle_signal(visual_degree_down, visual_degree_up, - size / 2,
                                              size / 2, luminance)
    if plot:
        plt.figure()
        plt.plot(horizontal_x, horizontal_y, label='Horizontal')
        plt.plot(vertical_x, vertical_y, label='Vertical')
        plt.legend()
        plt.xlabel('Visual Degree (radians)')
        plt.ylabel('Luminance')
        plt.title(f'Size = {size}*{size} degree; Luminance = {luminance} nits')
        plt.show()

    return horizontal_x, horizontal_y, vertical_x, vertical_y

if __name__ == '__main__':
    size_list = [4,16]
    luminance_list = [1,2,3,4,5,10,100]
    # horizontal_x, horizontal_y, vertical_x, vertical_y = generate_signal(size=16, luminance=100, plot=True)
    plt.figure()
    for size_value in size_list:
        for luminance_value in luminance_list:
            horizontal_x, horizontal_y, vertical_x, vertical_y = generate_signal(size=size_value, luminance=luminance_value,
                                                                                 plot=False)
            x, amplitude = compute_spatial_FFT(x_spatial_array=horizontal_x, y_stimulus_array=horizontal_y,
                                                frequency_upper=200, plot_FFT=False, skip_0=False, force_equal=True)
            plt.plot(x, amplitude, label=f'S: {size_value}, L: {luminance_value}')
            # amplitude_predict = spaitial_FFT_function(luminance_value, size_value, x)
            # plt.plot(x, amplitude_predict, label=f'S: {size_value}, L: {luminance_value}, Predict')
    plt.xlabel('cycles per degree')
    plt.ylabel('Amplitude')
    plt.title('Horizontal FFT')
    plt.xlim(0, 1)
    plt.legend()
    plt.show()

    for size_value in size_list:
        for luminance_value in luminance_list:
            horizontal_x, horizontal_y, vertical_x, vertical_y = generate_signal(size=size_value, luminance=luminance_value,
                                                                                 plot=False)
            x, amplitude = compute_spatial_FFT(x_spatial_array=vertical_x, y_stimulus_array=vertical_y,
                                                frequency_upper=200, plot_FFT=False, skip_0=False, force_equal=True)
            plt.plot(x, amplitude, label=f'S: {size_value}, L: {luminance_value}')
    plt.xlabel('cycles per degree')
    plt.ylabel('Amplitude')
    plt.title('Vertical FFT')
    plt.xlim(0, 1)
    plt.legend()
    plt.show()

