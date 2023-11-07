import json
import numpy as np
import matplotlib.pyplot as plt

save_json_path = 'plt_save_fig/MTime_2023-10-27/[60,120,60]-[2,2,2,2,2]-[1.0,1.0,1.0]-Noblack.json'

with open(save_json_path, 'r') as fp:
    json_data = json.load(fp)

x_time_array = np.array(json_data['x_time'])
y_luminance_array = np.array(json_data['y_luminance'])

plt.figure()
plt.plot(x_time_array,y_luminance_array)
plt.xlim([0,10])
plt.ylim([0,1])
plt.show()

