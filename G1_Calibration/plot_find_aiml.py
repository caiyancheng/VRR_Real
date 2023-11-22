import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

data_path = r'E:\Py_codes\VRR_Real\G1_Calibration\py_display_calibration_results\LG-G1-Std-2023_11_22_14_31_06-AimL-1/result_data.csv'
csv_data = pd.read_csv(data_path)

RGB_values = csv_data['Color'].to_numpy()
Luminance_values = csv_data['Luminance'].to_numpy()
Index = np.array(range(len(Luminance_values)))

fig = plt.figure(figsize=(10,5))

plt.subplot(1, 2, 1)
plt.plot(Index, Luminance_values, marker='o', linestyle='-')
plt.xlabel('Test Index')
plt.ylabel('Luminance Values (cd/m^2)')

plt.subplot(1, 2, 2)
plt.plot(Index, RGB_values, marker='o', linestyle='-')
plt.xlabel('Test Index')
plt.ylabel('RGB Values (R=G=B)')

plt.show()