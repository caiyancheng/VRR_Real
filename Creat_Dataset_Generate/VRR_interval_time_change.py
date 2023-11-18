import glfw
from OpenGL.GL import *
import time
from tqdm import tqdm
import cv2
import numpy as np
import serial
import temporal_light_sensor
import matplotlib.pyplot as plt
import threading
import os
import json

Dataset_path = r'E:\Py_codes\VRR_Real\Datasets/VRR_interval_time_change_Dark_Room_2023_11_14'
os.makedirs(Dataset_path, exist_ok=True)
sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM5", 500000))
num_measurements = 50000
sampling_frequency = 5000
begin_measure = False
measure_done = False
measure_data_thread = None
threading.Lock()

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time) / 1e6
    while time.perf_counter() < end_time:
        pass

def take_measurements():
    sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency)
    measurements, start_ts = sensor.get_results()  # measurements.shape = (num_measurements,)
    x_time = np.arange(len(measurements)) * 1 / sampling_frequency
    y_luminance = measurements / 65535
    return x_time, y_luminance

def thread_measure():
    global measure_data_thread
    measure_data_thread = take_measurements()

def vrr_generate(color, frame_rates, interval_times_range, total_time):
    global begin_measure, measure_done, measure_data_thread, real_begin
    #初始化
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    glfw.window_hint(glfw.VISIBLE, glfw.FALSE)
    window = glfw.create_window(screen_width, screen_height, "Color Disappearing Effect", second_monitor, None)
    if not window:
        glfw.terminate()
        return

    glfw.make_context_current(window)
    glfw.swap_interval(1)
    glfw.show_window(window)


    for data_index in tqdm(range(len(interval_times_range))):
        interval_time = int(interval_times_range[data_index]) / 1000
        real_all_begin_time = all_begin_time = time.perf_counter()

        measurement_thread = threading.Thread(target=thread_measure)
        measurement_thread.start()  # 启动测量线程,注意前面一小部分时间是不能使用的（因为还没开始display Flicker)

        measure_data_thread = None

        while not glfw.window_should_close(window):
            begin_time = time.perf_counter()
            display_t = begin_time - all_begin_time
            real_display_t = begin_time - real_all_begin_time
            if real_display_t > total_time:
                break
            if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                break
            if display_t < interval_time:
                frame_rate = frame_rates[0]
            elif display_t < interval_time * 2:
                frame_rate = frame_rates[1]
            else:
                all_begin_time = time.perf_counter()

            glClearColor(color[0], color[1], color[2], 1.0)
            glClear(GL_COLOR_BUFFER_BIT)
            glfw.swap_buffers(window)

            end_time = time.perf_counter()
            sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
            microsecond_sleep(sleep_time)
            glfw.poll_events()
        print('Finish Flicker')
        measurement_thread.join()
        assert measure_data_thread is not None
        print('Finish Measure')
        x_time, y_luminance = measure_data_thread
        print('Get Data')
        file_name = f'Interval_Time_{interval_time}'
        # plt.figure(figsize=(100, 5))
        # plt.plot(x_time, y_luminance)
        # # plt.xlim((2, 6))
        # plt.ylim((0, 1))
        # plt.xlabel('time(s)')
        # plt.ylabel('Luminance')
        # # plt.show()
        # plt.savefig(os.path.join(Dataset_path, f'{file_name}.png'))
        # plt.close()
        # print('Finish Plot')
        json_data_dict = {}
        json_data_dict['x_time'] = x_time.tolist()
        json_data_dict['y_luminance'] = y_luminance.tolist()
        with open(os.path.join(Dataset_path, f'{file_name}.json'), 'w') as fp:
            json.dump(json_data_dict, fp=fp)
        print('Finish Json Dump')
        # print('Wait 60 seconds')
        # time.sleep(60)
    glfw.terminate()

if __name__ == "__main__":
    # time.sleep(600)
    color = [1.0, 1.0, 1.0]
    frame_rates = [30, 120] # 第二个应该比第一个大
    interval_times_range = range(10, 1000, 10) # ms
    total_time = 12 #总共展示的s数量
    # between_data_sleep_time = 1
    vrr_generate(color, frame_rates, interval_times_range, total_time)