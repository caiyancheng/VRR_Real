import serial
import temporal_light_sensor
import matplotlib.pyplot as plt
import numpy as np

sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM4", 500000))
num_measurements = 50000
sampling_frequency = 5000
sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency)

measurements, start_ts = sensor.get_results()
fig = plt.figure(figsize=(10, 5))

plt.plot(np.arange(len(measurements)) * 1/sampling_frequency, measurements / 65535)
plt.xlim((0, 0.25))
plt.ylim((0, 1))
plt.show()
# plt.savefig(r'E:\Py_codes\Py_Temporal_Light_Sensor_GIGA\plt_save_fig/try.png')