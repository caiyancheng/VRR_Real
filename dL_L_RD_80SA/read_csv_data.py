#如何从示波器中读取数据
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

csv_file_path = r'K:\T0000RF1.csv'
df = pd.read_csv(csv_file_path, skiprows=range(15))
time_array = np.array(df['TIME'])
stimulus_array = np.array(df['REF1'])
stimulus_peak_array = np.array(df['REF1 Peak Detect'])

plt.figure(figsize=(20,4))
# plt.plot(time_array, stimulus_array, label='REF1')
plt.plot(time_array, stimulus_array - stimulus_peak_array, label='REF1 Peak Detect')
plt.xlim([0,0.1])
plt.legend()
plt.show()
