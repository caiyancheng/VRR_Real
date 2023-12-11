import json
import numpy as np
import matplotlib.pyplot as plt

save_json_path = 'B:\Subjective_Exp_1\Luminance_1_Size_4_Fix_60Hz/0.json'

with open(save_json_path, 'r') as fp:
    json_data = json.load(fp)

x_time_array = np.array(json_data['x_time'])
y_luminance_array = np.array(json_data['y_luminance'])

plt.figure()
plt.plot(x_time_array,y_luminance_array)
plt.xlim([0,0.25])
plt.ylim([0,max(y_luminance_array)])
plt.show()

