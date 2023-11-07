import serial
import temporal_light_sensor
import matplotlib.pyplot as plt
import numpy as np

def main():
    sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM5", 500000))

    sampling_frequency = 5000 #points per second
    num_measurements = 50000
    sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency)

    measurements, start_ts = sensor.get_results()

    plt.figure(figsize=(100, 5))
    plt.plot(np.arange(len(measurements)) * 1/sampling_frequency, measurements / 65535)
    plt.ylim((0, 1))
    plt.xlim((0, num_measurements/sampling_frequency))
    # plt.show()
    plt.savefig(r'E:\Py_codes\Py_Temporal_Light_Sensor_GIGA\plt_save_fig/0.png')


if __name__ == "__main__":
    main()
