import numpy as np
import json
import os
import matplotlib.pyplot as plt

base_path = 'LG_G1_KONICA_1'
with open(os.path.join(base_path, 'result.json'), 'r') as fp:
    result_data = json.load(fp)
with open(os.path.join(base_path, 'config.json'), 'r') as fp:
    config_data = json.load(fp)

pixel_all_values = np.arange(config_data['Pixel_value_range'][0], config_data['Pixel_value_range'][1], config_data['Pixel_value_step'])
size_values = config_data['Size']
repeat_times = config_data['repeat_times']

# Create two separate figures and axes
fig1, ax1 = plt.subplots(figsize=(10,5))
fig2, ax2 = plt.subplots(figsize=(10,5))

for size_value in size_values:
    for repeat_time in range(repeat_times):
        x_axis_L = []
        y_axis_dl = []
        y_axis_dl_L = []
        for color_value in pixel_all_values:
            result_index = result_data[f'S_{size_value}_C_{color_value}_R_{repeat_time}']
            luminance_30 = result_index['30'][0]
            luminance_120 = result_index['120'][0]
            L = (luminance_30 + luminance_120) / 2
            dl = luminance_30 - luminance_120
            x_axis_L.append(L)
            y_axis_dl.append(dl)
            y_axis_dl_L.append(dl / L)
        ax1.plot(x_axis_L, y_axis_dl, label=f'Size_{size_value}_Repeat_{repeat_time}')
        ax2.plot(x_axis_L, y_axis_dl_L, label=f'Size_{size_value}_Repeat_{repeat_time}')

# Set labels for both figures
ax1.set_title('plot deltaL vs Luminance')
ax1.set_xlabel('Luminance')
ax1.set_ylabel('deltaL')
ax2.set_title('plot deltaL/L vs Luminance')
ax2.set_xlabel('Luminance')
ax2.set_ylabel('deltaL/L')

# Show legends for both figures
ax1.legend()
ax2.legend()

# Show the plots
plt.show()