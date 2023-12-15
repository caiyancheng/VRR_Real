#使用固定的刷新率60Hz
#改变不同的Color
import subprocess
import glfw
from OpenGL.GL import *
import time
import cv2
import numpy as np
from tqdm import tqdm
import threading
from datetime import datetime
import os
import json
import pandas as pd
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity
import random

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + sleep_time
    while time.perf_counter_ns() / 1e9 < end_time:
        pass

def start_opengl():
    global center_point_size_y
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    window = glfw.create_window(screen_width, screen_height, "LG G1 Color - KONICA", second_monitor, None)
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
    time.sleep(3)
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


def check_dl_L(size_value, color_value, frame_rate, glfw, window, maxtime=100):
    x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
    x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
    global Y, x, y
    if not glfw.init():
        return

    # # 展示2s的纯白画面
    # all_begin_time = time.perf_counter_ns() / 1e9
    # while not glfw.window_should_close(window):
    #     if Y: # 如果已经收到了结果，推出
    #         break
    #     begin_time = time.perf_counter_ns() / 1e9
    #     if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
    #         return -1
    #     real_display_t = begin_time - all_begin_time
    #     if real_display_t > 2:
    #         break
    #     glClear(GL_COLOR_BUFFER_BIT)
    #     glColor3f(0.5, 0.5, 0.5)
    #     glBegin(GL_QUADS)
    #     glVertex2f(x_center - x_scale, y_center - y_scale)
    #     glVertex2f(x_center + x_scale, y_center - y_scale)
    #     glVertex2f(x_center + x_scale, y_center + y_scale)
    #     glVertex2f(x_center - x_scale, y_center + y_scale)
    #     glEnd()
    #     glfw.swap_buffers(window)
    #
    #     end_time = time.perf_counter_ns() / 1e9
    #     sleep_time = (1.0 / frame_rate - (end_time - begin_time))
    #     microsecond_sleep(sleep_time)
    #     glfw.poll_events()

    all_begin_time = time.perf_counter_ns() / 1e9
    Y = x = y = None
    measurement_thread = threading.Thread(target=get_color_thread)
    measurement_thread.start()
    while not glfw.window_should_close(window):
        if Y: # 如果已经收到了结果，推出
            break
        begin_time = time.perf_counter_ns() / 1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        real_display_t = begin_time - all_begin_time
        if real_display_t > maxtime:
            return [np.nan, np.nan, np.nan]
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
        sleep_time = (1.0 / frame_rate - (end_time - begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    return [Y, x, y]

def check_dl_L_all(Size, Pixel_value_range, Pixel_value_step, Refresh_rate, repeat_times, save_dir_path, random_shuffle):
    pixel_all_values = np.arange(Pixel_value_range[0], Pixel_value_range[1], Pixel_value_step)
    setting_list = []
    for size_value in Size:
        for color_value in pixel_all_values:
            for repeat_index in range(repeat_times):
                setting_params = size_value, color_value, repeat_index
                setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)
    glfw, window = start_opengl()
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    json_log_data = {}
    for index in range(len(setting_list)):
        size_value, color_value, repeat_index = setting_list[index]
        print('Size_value', size_value, 'Color_value', color_value, 'Repeat_index', repeat_index)
        log_data = {}
        for frame_rate in Refresh_rate:
            response = check_dl_L(size_value, color_value, frame_rate, glfw, window)
            if response == -1:
                return #有人想要退出了
            else:
                log_data[str(frame_rate)] = response
        json_log_data[f'S_{size_value}_C_{color_value}_R_{repeat_index}'] = log_data
    with open(os.path.join(save_dir_path, 'result.json'), 'w') as fp:
        json.dump(json_log_data, fp)

if __name__ == "__main__":
    Size = [4, 'full']
    Pixel_value_range = [0, 1]
    Pixel_value_step = 0.05
    Refresh_rate = [30, 120]
    repeat_times = 1

    save_dir_path = f"../dL_L/LG_G1_KONICA_3"
    os.makedirs(save_dir_path, exist_ok=True)
    config_json = {'Size': Size, 'Pixel_value_range': Pixel_value_range,
                   'Pixel_value_step': Pixel_value_step, 'Refresh_rate': Refresh_rate,
                   'repeat_times': repeat_times}
    with open(os.path.join(save_dir_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp=fp)
    check_dl_L_all(Size, Pixel_value_range, Pixel_value_step,
                   Refresh_rate, repeat_times, save_dir_path,
                   random_shuffle=False)