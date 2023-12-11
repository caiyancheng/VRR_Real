import os.path

import serial
import temporal_light_sensor
import matplotlib.pyplot as plt
import numpy as np
import json
import time
from datetime import datetime
import os

sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM5", 500000))
num_measurements = 50000 #51999是极限，但是一般不建议超过50000，注意会卡住
sampling_frequency = 25000

luminance_time_log_json = {}
luminance_time_log_json['time'] = []
luminance_time_log_json['measurements'] = []
luminance_time_log_json['start_ts'] = []

current_time = datetime.now()
readable_timestamp = current_time.strftime("%Y-%m-%d-%H-%M-%S")
save_path = os.path.join(r'E:\Datasets/Subjective_Exp_4_Light_Measure', readable_timestamp)
os.makedirs(save_path)
config_json = {
    'num_measurements': num_measurements,
    'sampling_frequency': sampling_frequency
}
with open(os.path.join(save_path, 'config.json'), 'w') as fp:
    json.dump(config_json, fp)

for measure_index in range(1000000):
    luminance_time_log_json = {}
    begin_time = time.time()
    sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency)
    measurements, start_ts = sensor.get_results()
    luminance_time_log_json['time'] = begin_time
    luminance_time_log_json['measurements'] = measurements.tolist()
    luminance_time_log_json['start_ts'] = start_ts
    real_save_path = os.path.join(save_path, f'measure_{measure_index}')
    os.makedirs(real_save_path)
    with open(os.path.join(real_save_path, 'luminance_time_log.json'), 'w') as fp:
        json.dump(luminance_time_log_json, fp)
    time.sleep(2)


# measurements, start_ts = sensor.get_results()
# fig = plt.figure(figsize=(10, 5))
#
# plt.plot(np.arange(len(measurements)) * 1/sampling_frequency, measurements / 65535)
# plt.xlim((0, 0.25))
# plt.ylim((0, 0.001))
# plt.show()
# plt.savefig(r'E:\Py_codes\Py_Temporal_Light_Sensor_GIGA\plt_save_fig/try.png')

# 有一种办法可以让读取数据和显示数据共存，例如，要求temporal flicker meter 每隔2s, 收集2s数据，之后盖上时间戳，然后和显示光那边的时间戳对应就好了（但是最好还能有一个Konica可以实时地读取数据
# 建议使用三台机器
# 1： My Laptop: 显示光照
# 2： My PC: 记录Temporal Flicker Meter
# 3： Rainbow Lab PC: 记录Knoica光强
# 就在我办公室记录就行咧