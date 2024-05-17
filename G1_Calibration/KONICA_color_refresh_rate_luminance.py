import subprocess
import math
from OpenGL.GL import *
import glfw
import time
import numpy as np
import threading
import pandas as pd
import json
from datetime import datetime
import os
import random
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity
num_segments_s = 50
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
    time.sleep(1)
    measuring_speed = " "  # Set your measuring speed
    command = f"E:\Matlab_codes\matlab_toolboxes_KONICA\display_calibration\Konica/Konica_Measure_Light/Debug/Konica_Measure_Light.exe {measuring_speed}"
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

def calibration_color_size(stimulus_params, color_change_parameters, frame_rate_parameters, random_shuffle, save_dir_path):
    global glfw, window, Y, x, y

    color_scale = color_change_parameters['scale']
    Pixel_value_range = color_change_parameters['Pixel_value_range']
    sample_numbers = color_change_parameters['sample_numbers']
    if color_scale == 'Linear':
        pixel_all_values = np.linspace(Pixel_value_range[0], Pixel_value_range[1], num=sample_numbers)
    elif color_scale == 'Log10':
        if Pixel_value_range[0] == 0:
            Pixel_value_range[0] = 0.001
        pixel_all_values = np.logspace(np.log10(Pixel_value_range[0]), np.log10(Pixel_value_range[1]),
                                       num=sample_numbers)
    else:
        raise ValueError(f'the scale {color_scale} pattern is not included in this code')

    RR_scale = frame_rate_parameters['scale']
    Frame_rate_range = frame_rate_parameters['Frame_rate_range']
    sample_numbers = frame_rate_parameters['sample_numbers']
    if RR_scale == 'Linear':
        RR_all_values = np.linspace(Frame_rate_range[0], Frame_rate_range[1], num=sample_numbers)
    elif RR_scale == 'Log10':
        RR_all_values = np.logspace(np.log10(Frame_rate_range[0]), np.log10(Frame_rate_range[1]), num=sample_numbers)
    else:
        raise ValueError(f'the scale {RR_scale} pattern is not included in this code')

    setting_list = []
    for size_value in stimulus_params['Size']:
        for color_value in pixel_all_values:
            for RR_value in RR_all_values:
                for repeat_value in range(stimulus_params['Repeat']):
                    setting_params = size_value, color_value, RR_value, repeat_value
                    setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)

    start_opengl()

    csv_data = {}
    csv_data['size'] = []
    csv_data['color'] = []
    csv_data['refresh_rate'] = []
    csv_data['repeat'] = []
    csv_data['Y'] = []
    csv_data['x'] = []
    csv_data['y'] = []
    for setting_index in range(len(setting_list)):
        size_value, color_value, frame_rate, repeat_value = setting_list[setting_index]
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)


        if stimulus_params['White_Clear']:
            all_begin_time = time.perf_counter_ns() / 1e9
            while not glfw.window_should_close(window):
                begin_time = time.perf_counter_ns() / 1e9
                if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                    return -1
                real_display_t = begin_time - all_begin_time
                if real_display_t > 2: #White Clear 2s
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
        Y = x = y = None
        measurement_thread = threading.Thread(target=get_color_thread)
        measurement_thread.start()
        if size_value == 'full':
            while not glfw.window_should_close(window):
                if Y:
                    break
                frame_begin_time = time.perf_counter_ns() / 1e9
                if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                    return -1
                glClear(GL_COLOR_BUFFER_BIT)
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
        else:
            while not glfw.window_should_close(window):
                if Y:
                    break
                frame_begin_time = time.perf_counter_ns() / 1e9
                if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                    return -1
                glClear(GL_COLOR_BUFFER_BIT)
                glColor3f(color_value, color_value, color_value)
                glBegin(GL_TRIANGLE_FAN)
                glVertex2f(x_center, y_center)
                for i in range(num_segments_s + 1):
                    theta = i * (2.0 * math.pi / num_segments_s)
                    x = x_center + x_scale * math.cos(theta)
                    y = y_center + y_scale * math.sin(theta)
                    glVertex2f(x, y)
                glEnd()
                glfw.swap_buffers(window)
                end_time = time.perf_counter_ns() / 1e9
                sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
                microsecond_sleep(sleep_time)
                glfw.poll_events()


        csv_data['size'].append(size_value)
        csv_data['color'].append(color_value)
        csv_data['repeat'].append(repeat_value)
        csv_data['refresh_rate'].append(frame_rate)
        csv_data['Y'].append(Y)
        csv_data['x'].append(x)
        csv_data['y'].append(y)
        df = pd.DataFrame(csv_data)
        print('Size', size_value, 'Color', color_value, 'Refresh Rate', frame_rate, 'Luminance', Y)
        df.to_csv(os.path.join(save_dir_path, 'result_in_progress.csv'), index=False)
    glfw.terminate()
    df = pd.DataFrame(csv_data)
    df.to_csv(os.path.join(save_dir_path, 'final_result.csv'), index=False)



if __name__ == "__main__":
    stimulus_params = {
        'x_center': 0,
        'y_center': 0,
        'Size': [16],
        'Repeat': 2,
        'White_Clear': False,
    }
    color_change_parameters = {
        'Pixel_value_range': [0.05, 1],
        'sample_numbers': 30,
        'scale': 'Log10',
    }
    frame_rate_parameters = {
        'Frame_rate_range': [10,120],
        'sample_numbers': 10,
        'scale': 'Linear',
    }

    now = datetime.now()
    formatted_time = now.strftime("%Y_%m_%d_%H_%M_%S")
    save_dir_path = f'py_display_calibration_results_RR/LG-G1-Std-{formatted_time}'
    os.makedirs(save_dir_path)
    config_json = {'stimulus_params': stimulus_params,
                   'color_change_parameters': color_change_parameters,
                   'frame_rate_parameters': frame_rate_parameters}
    with open(os.path.join(save_dir_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp=fp)

    calibration_color_size(stimulus_params=stimulus_params,
                           color_change_parameters=color_change_parameters,
                           frame_rate_parameters=frame_rate_parameters,
                           random_shuffle=True,
                           save_dir_path=save_dir_path)

    # 不同refresh rate下分别对应多高的Luminance