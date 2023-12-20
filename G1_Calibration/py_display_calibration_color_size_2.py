import subprocess
import glfw
from OpenGL.GL import *
import time
import cv2
import numpy as np
from tqdm import tqdm
import threading
import pandas as pd
import json
from datetime import datetime
import os
import random
from tqdm import tqdm
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns()/1e9 + sleep_time
    while time.perf_counter_ns()/1e9 < end_time:
        pass
def start_opengl():
    global glfw, window
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
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

def get_color_thread():
    global Y, x, y
    time.sleep(3) #休息10s等待刷新率正常
    measuring_speed = " "  # Set your measuring speed
    command = f"E:/Matlab_codes/matlab_toolboxes/display_calibration/Konica/Konica_Measure_Light/Debug/Konica_Measure_Light.exe {measuring_speed}"
    result = subprocess.run(command, text=True, capture_output=True, shell=True)
    cmdout = result.stdout.strip()
    cmdout = ''.join(cmdout.split())
    split_str = cmdout.split(',')
    if len(split_str) < 11:
        Y = np.nan
        x = np.nan
        y = np.nan
    else:
        Y = float(split_str[9])
        x = float(split_str[10])
        y = float(split_str[11])

def calibration_color_size(rect_params, color_change_parameters, random_shuffle, save_dir_path):
    global glfw, window
    scale = color_change_parameters['scale']
    Pixel_value_range = color_change_parameters['Pixel_value_range']
    sample_numbers = color_change_parameters['sample_numbers']
    if scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)
    else:
        raise ValueError(f'the scale {scale} pattern is not included in this code')

    setting_list = []
    for size_value in rect_params['Size']:
        for color_value in pixel_all_values:
            for repeat_value in range(rect_params['Repeat']):
                setting_params = size_value, color_value, repeat_value
                setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)

    start_opengl()
    frame_rate = 60

    csv_data = {}
    csv_data['size'] = []
    csv_data['color'] = []
    csv_data['Y'] = []
    csv_data['x'] = []
    csv_data['y'] = []
    for setting_index in range(len(setting_list)):
        size_value, color_value, repeat_value = setting_list[setting_index]
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
        Y = x = y = None

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
            sleep_time = (1.0 / frame_rate - (end_time - begin_time))
            microsecond_sleep(sleep_time)
            glfw.poll_events()

        measurement_thread = threading.Thread(target=get_color_thread)
        measurement_thread.start()
        while not glfw.window_should_close(window):
            if Y:
                break
            frame_begin_time = time.perf_counter_ns()/1e9
            if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                return -1
            glColor3f(color_value, color_value, color_value)
            glBegin(GL_QUADS)
            glVertex2f(x_center - x_scale, y_center - y_scale)
            glVertex2f(x_center + x_scale, y_center - y_scale)
            glVertex2f(x_center + x_scale, y_center + y_scale)
            glVertex2f(x_center - x_scale, y_center + y_scale)
            glEnd()
            glfw.swap_buffers(window)
            end_time = time.perf_counter_ns() / 1e9
            sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
            microsecond_sleep(sleep_time)
            glfw.poll_events()
        csv_data['size'].append(size_value)
        csv_data['color'].append(color_value)
        csv_data['Y'].append(Y)
        csv_data['x'].append(x)
        csv_data['y'].append(y)
    glfw.terminate()
    df = pd.DataFrame(csv_data)
    df.to_csv(os.path.join(save_dir_path, 'result_data.csv'), index=False)



if __name__ == "__main__":
    rect_params = {
        'x_center': 0,
        'y_center': 0,
        'Size': [1, 16, 'full'],
        'Repeat': 5,
    }
    color_change_parameters = {
        'Pixel_value_range': [0.05, 1],
        'sample_numbers': 30,
        'scale': 'Log10'
    }

    now = datetime.now()
    formatted_time = now.strftime("%Y_%m_%d_%H_%M_%S")
    save_dir_path = f'E:\Py_codes\VRR_Real\G1_Calibration\py_display_calibration_results_3/LG-G1-Std-{formatted_time}'
    os.makedirs(save_dir_path)
    config_json = {'rect_params': rect_params, 'color_change_parameters': color_change_parameters}
    with open(os.path.join(save_dir_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp=fp)

    calibration_color_size(rect_params, color_change_parameters, save_dir_path)