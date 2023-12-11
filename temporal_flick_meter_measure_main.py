import serial
import temporal_light_sensor
import matplotlib.pyplot as plt
import numpy as np

sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM5", 500000))
num_measurements = 50000 #51999是极限，但是一般不建议超过50000，注意会卡住
sampling_frequency = 20000
sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency, bright_mode=True)

measurements, start_ts = sensor.get_results()
fig = plt.figure(figsize=(10, 5))

plt.plot(np.arange(len(measurements)) * 1/sampling_frequency, measurements / 65535)
plt.xlim((0, 0.05))
plt.ylim((0, 0.004))
plt.show()
# plt.savefig(r'E:\Py_codes\Py_Temporal_Light_Sensor_GIGA\plt_save_fig/try.png')

# 有一种办法可以让读取数据和显示数据共存，例如，要求temporal flicker meter 每隔2s, 收集2s数据，之后盖上时间戳，然后和显示光那边的时间戳对应就好了（但是最好还能有一个Konica可以实时地读取数据
# 建议使用三台机器
# 1： My Laptop: 显示光照
# 2： My PC: 记录Temporal Flicker Meter
# 3： Rainbow Lab PC: 记录Knoica光强
# 就在我办公室记录就行咧