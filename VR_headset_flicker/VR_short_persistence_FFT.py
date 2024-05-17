import numpy as np
from Computational_Model.FFT import compute_signal_FFT
import matplotlib.pyplot as plt

refresh_rate = 90
persistence = 0.1
one_frame_time = 1 / refresh_rate
vr_luminance = 100

totoal_time = 10
sample_hz = 1000

x_time_array = np.arange(totoal_time * sample_hz)/sample_hz #1000个点，代表10s
y_luminance_list = []

for time in x_time_array:
    if time % one_frame_time < persistence * one_frame_time:
        y_luminance_list.append(vr_luminance)
    else:
        y_luminance_list.append(0)

y_luminance_array = np.array(y_luminance_list)

x_freq_array, K_FFT_array = compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array, frequency_upper=200, plot_FFT=False, force_equal=True)

plt.figure()
# plt.plot(x_time_array[0:100], y_luminance_array[0:100])
plt.plot(x_freq_array, K_FFT_array / K_FFT_array[0])
plt.show()