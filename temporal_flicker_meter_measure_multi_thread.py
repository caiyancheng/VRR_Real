import winsound
import json
import glfw
from OpenGL.GL import *
from OpenGL.GLUT.freeglut import *
import time
import cv2
import numpy as np
import random
import keyboard
import pandas as pd
from datetime import datetime
import os
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity
import serial
import temporal_light_sensor
import threading

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns()/1e9 + sleep_time
    while time.perf_counter_ns()/1e9 < end_time:
        pass
def start_opengl():
    global center_point_size_y
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    center_point_size_y = center_point_size_x * screen_width / screen_height
    window = glfw.create_window(screen_width, screen_height, "Color Disappearing Effect", second_monitor, None)
    if not window:
        glfw.terminate()
        return
    glfw.window_hint(glfw.DOUBLEBUFFER, True)
    glfw.make_context_current(window)
    glfw.swap_interval(1)
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    glfw.show_window(window)
    return glfw, window

def temporal_flicker_meter_thread(record_params):
    global measurements, start_ts, measure_done, sensor
    num_measurements = int(record_params['num_flicker_meter_sample'])
    sampling_frequency = int(num_measurements / record_params['time_flicker_meter_log'])
    time.sleep(3)
    sensor.take_measurement(num_measurements=num_measurements, sampling_frequency=sampling_frequency)
    measurements, start_ts = sensor.get_results() #这个环节可能会卡住，所以要做好准备终结这个子线程
    measure_done = True
    print('Measure Finished!')

def temporal_measure_one_block(glfw, window, vrr_params, c_params, record_params):
    global measurements, start_ts, measure_done
    x_center, y_center, x_scale, y_scale, interval_time, vrr_color = c_params

    # 展示2s的纯白画面
    all_begin_time = time.perf_counter_ns() / 1e9
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter_ns() / 1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        real_display_t = begin_time - all_begin_time
        if real_display_t > 2:
            break
        glClear(GL_COLOR_BUFFER_BIT)
        glColor3f(0.5, 0.5, 0.5)
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()
        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns() / 1e9
        sleep_time = (1.0 / vrr_params['fix_frame_rate'] - (end_time - begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()

    all_begin_time = time.perf_counter_ns() / 1e9
    measurements = start_ts = None
    measure_done = False
    measurement_thread = threading.Thread(target=temporal_flicker_meter_thread, args=(record_params,))
    measurement_thread.start()
    begin_vrr_time = time.perf_counter_ns() / 1e9
    while not glfw.window_should_close(window):
        if measure_done: #测量结束
            return measurements, start_ts
        frame_begin_time = time.perf_counter_ns()/1e9
        # if frame_begin_time - all_begin_time > record_params['time_maximum']: #超时
        #     print('Measure Failed! Time Out!')
        #     try:
        #         measurement_thread._stop()
        #     except:
        #         print('Stop function not exist. ChatGPT lies.')
        #     return -1
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        color = vrr_color
        if time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter_ns()/1e9
            frame_rate = vrr_params['frame_rate_max']
        glColor3f(color[0], color[1], color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()
        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns()/1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def temporal_record_main(change_parameters, vrr_params, color_change_parameters, record_params, real_save_path, random_shuffle):
    scale = color_change_parameters['scale']
    Pixel_value_range= color_change_parameters['Pixel_value_range']
    sample_numbers = color_change_parameters['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]), num=sample_numbers)
    else:
        raise ValueError(f'the scale {scale} pattern is not included in this code')
    setting_list = []
    for size_value in change_parameters['Size']:
        for color_value in pixel_all_values:
            for vrr_f_value in change_parameters['VRR_Frequency']:
                setting_params = size_value, vrr_f_value, color_value
                setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)

    glfw, window = start_opengl()
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    global sensor
    sensor = temporal_light_sensor.TemporalLightSensor(serial.Serial("COM5", 500000, timeout=record_params['time_maximum']))

    for index in range(len(setting_list)):
        size_value, vrr_f_value, color_value = setting_list[index]
        save_path_dir = os.path.join(real_save_path, f'S_{size_value}_V_{vrr_f_value}_C_{color_value}')
        os.makedirs(save_path_dir, exist_ok=True)

        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
        interval_time = 1 / (2 * vrr_f_value)
        vrr_color = [color_value, color_value, color_value]
        c_params = x_center, y_center, x_scale, y_scale, interval_time, vrr_color
        for repeat_index in range(change_parameters['Repeat_times']):
            result = temporal_measure_one_block(glfw=glfw,
                                       window=window,
                                       vrr_params=vrr_params,
                                       c_params=c_params,
                                       record_params=record_params)
            # while result == -1: #如果一直没有响应，就一直执行这个进程。
            #     result = temporal_measure_one_block(glfw=glfw,
            #                                         window=window,
            #                                         vrr_params=vrr_params,
            #                                         c_params=c_params,
            #                                         record_params=record_params)
            print('Measure Success!!!')
            measurements, start_ts = result
            json_log_data = {
                'measurements': measurements.tolist(),
                'start_ts': start_ts,
            }
            with open(os.path.join(save_path_dir, f'{repeat_index}.json'), 'w') as fp:
                json.dump(json_log_data, fp)


if __name__ == "__main__": #必须要用多线程，否则会出现问题
    change_parameters = {
        'VRR_Frequency': [0.5, 1, 2, 4, 8, 16],
        'Size': [1, 16, 'full'],
        'Repeat_times': 4, #每条应该记录10遍
    }
    color_change_parameters = {
        'Pixel_value_range': [0.05, 1],
        'sample_numbers': 30,
        'scale': 'Log10'
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 10,
        'fix_frame_rate': 60,
    }
    record_params = {
        'time_flicker_meter_log': 10,
        'num_flicker_meter_sample': 50000,
        'time_maximum': 17, #最多10s, 超出10s不再记录
    }
    save_path = r'Temporal_Flicker_Meter_log/deltaL_L'
    current_time = datetime.now()
    readable_timestamp = current_time.strftime("%Y-%m-%d-%H-%M-%S")
    real_save_path = os.path.join(save_path, readable_timestamp)
    os.makedirs(real_save_path)
    config_json = {
        'change_params': change_parameters,
        'vrr_params': vrr_params,
        'color_change_parameters': color_change_parameters,
        'record_params': record_params,
    }
    with open(os.path.join(real_save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    print(change_parameters)
    temporal_record_main(change_parameters=change_parameters,
                         vrr_params=vrr_params,
                         color_change_parameters=color_change_parameters,
                         record_params=record_params,
                         real_save_path=real_save_path,
                         random_shuffle=False)