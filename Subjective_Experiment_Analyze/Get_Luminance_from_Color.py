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

def check_dl_L_all(MOA_exp_path, Quest_exp_path):
    with open(os.path.join(MOA_exp_path, 'config.json'), 'r') as fp:
        MOA_config = json.load(fp)
    with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
        Quest_config = json.load(fp)
    with open(os.path.join(MOA_exp_path, 'result.json'), 'r') as fp:
        MOA_result = json.load(fp)
    with open(os.path.join(Quest_exp_path, 'final_result.json'), 'r') as fp:
        Quest_final_result = json.load(fp)

    MOA_VRR_Fs = MOA_config['change_parameters']['VRR_Frequency']
    MOA_Sizes = MOA_config['change_parameters']['Size']
    Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
    Quest_Sizes = Quest_config['change_parameters']['Size']

    glfw, window = start_opengl()
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    json_log_data = {}
    frame_rate = 60
    for vrr_f_index in range(len(MOA_VRR_Fs)):
        for size_index in range(len(MOA_Sizes)):
            size_value = MOA_Sizes[size_index]
            vrr_f_value = MOA_VRR_Fs[vrr_f_index]
            color_value = np.array(MOA_result[f'V_{vrr_f_value}_S_{size_value}']).mean()
            response = check_dl_L(size_value, color_value, frame_rate, glfw, window)
            if response == -1:
                return  # 有人想要退出了
            else:
                json_log_data[f'S_{size_value}_C_{color_value}_MOA'] = response
    for vrr_f_index in range(len(Quest_VRR_Fs)):
        for size_index in range(len(Quest_Sizes)):
            size_value = Quest_Sizes[size_index]
            vrr_f_value = Quest_VRR_Fs[vrr_f_index]
            color_value_mean = Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Mean']
            color_value_mode = Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Mode']
            color_value_quantile = Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Quantile']
            color_value_quantile_05 = Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Quantile_05']

            response = check_dl_L(size_value, color_value_mean, frame_rate, glfw, window)
            if response == -1:
                return  # 有人想要退出了
            else:
                json_log_data[f'S_{size_value}_C_{color_value_mean}_Quest_mean'] = response

            response = check_dl_L(size_value, color_value_mode, frame_rate, glfw, window)
            if response == -1:
                return  # 有人想要退出了
            else:
                json_log_data[f'S_{size_value}_C_{color_value_mode}_Quest_mode'] = response

            response = check_dl_L(size_value, color_value_quantile, frame_rate, glfw, window)
            if response == -1:
                return  # 有人想要退出了
            else:
                json_log_data[f'S_{size_value}_C_{color_value_quantile}_Quest_quantile'] = response

            response = check_dl_L(size_value, color_value_quantile_05, frame_rate, glfw, window)
            if response == -1:
                return  # 有人想要退出了
            else:
                json_log_data[f'S_{size_value}_C_{color_value_quantile_05}_Quest__quantile_05'] = response
    with open(os.path.join(Quest_exp_path, 'color2luminance.json'), 'w') as fp:
        json.dump(json_log_data, fp)

if __name__ == "__main__":
    MOA_exp_path = r'..\VRR_Subjective_MOA\Result_MOA_1\Observer_Yancheng_Cai_Test_10'
    Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_1\Observer_Yancheng_Cai_Test_10'
    check_dl_L_all(MOA_exp_path, Quest_exp_path)
