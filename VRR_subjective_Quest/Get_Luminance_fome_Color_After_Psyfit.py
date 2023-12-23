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
import os

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


def get_Luminance(size_value, color_value, frame_rate, glfw, window, maxtime=100):
    x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
    x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
    global Y, x, y
    if not glfw.init():
        return

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
        sleep_time = (1.0 / frame_rate - (end_time - begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()

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

def get_Luminance_all(Quest_fit_result_path, Quest_json_save_path):
    df = pd.read_csv(Quest_fit_result_path)
    glfw, window = start_opengl()
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    json_log_data = {}
    frame_rate = 60
    for index, row in df.iterrows():
        # vrr_f_value = row['VRR_Frequency'].item()
        size_value = row['Size_Degree']
        if size_value != 'full':
            size_value = float(size_value)
        color_value_threshold = row['threshold']
        if np.isnan(color_value_threshold):
            continue
        response = get_Luminance(size_value, color_value_threshold, frame_rate, glfw, window)
        if response == -1:
            return  # 有人想要退出了
        else:
            json_log_data[f'S_{size_value}_C_{color_value_threshold}'] = response
    with open(Quest_json_save_path, 'w') as fp:
        json.dump(json_log_data, fp)

if __name__ == "__main__":
    root_path = r'..\VRR_subjective_Quest\Result_Quest_4\Observer_Yancheng_Cai_2'
    Quest_fit_result_path = os.path.join(root_path, 'reorder_result.csv')
    Quest_json_save_path = os.path.join(root_path, 'color2luminance.json')
    get_Luminance_all(Quest_fit_result_path, Quest_json_save_path)
