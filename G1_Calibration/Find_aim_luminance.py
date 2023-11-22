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
import pandas as pd
from datetime import datetime
import os
import json

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time) / 1e6
    while time.perf_counter() < end_time:
        pass
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


def find_aim_color(rect_params, aim_luminance, Tolerance, maxtime=1000):
    global Y, x, y
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
    frame_rate = 60
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    color_list = []
    luminance_list = []
    color_down = 0
    color_up = 1

    Y = x = y = None
    measurement_thread = threading.Thread(target=get_color_thread)
    measurement_thread.start()
    while not glfw.window_should_close(window):
        if Y:
            break
        begin_time = time.perf_counter()
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        real_display_t = begin_time - all_begin_time
        if real_display_t > maxtime:
            break
        glColor3f(color_down, color_down, color_down)
        glBegin(GL_QUADS)
        glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
        glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
        glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
        glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
        glEnd()
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    luminance_down = Y
    print('Color Down:', color_down)
    print('Luminance Down:', luminance_down)
    color_list.append(color_down)
    luminance_list.append(luminance_down)
    if np.abs(luminance_down - aim_luminance) < Tolerance:
        print('Success up! Finished')
        glfw.terminate()
        return color_list, luminance_list

    # Up
    Y = x = y = None
    measurement_thread = threading.Thread(target=get_color_thread)
    measurement_thread.start()
    while not glfw.window_should_close(window):
        if Y:
            break
        begin_time = time.perf_counter()
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        real_display_t = begin_time - all_begin_time
        if real_display_t > maxtime:
            break
        glColor3f(color_up, color_up, color_up)
        glBegin(GL_QUADS)
        glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
        glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
        glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
        glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
        glEnd()
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    luminance_up = Y
    print('Color Up:', color_up)
    print('Luminance Up:', luminance_up)
    color_list.append(color_up)
    luminance_list.append(luminance_up)
    if np.abs(luminance_up - aim_luminance) < Tolerance:
        print('Success up! Finished')
        glfw.terminate()
        return color_list, luminance_list

    while True:
        color_next = (color_down + color_up) / 2
        Y = x = y = None
        measurement_thread = threading.Thread(target=get_color_thread)
        measurement_thread.start()
        while not glfw.window_should_close(window):
            if Y:
                break
            begin_time = time.perf_counter()
            if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
                break
            real_display_t = begin_time - all_begin_time
            if real_display_t > maxtime:
                break
            glColor3f(color_next, color_next, color_next)
            glBegin(GL_QUADS)
            glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
            glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] - rect_params['scale'])
            glVertex2f(rect_params['x_center'] + rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
            glVertex2f(rect_params['x_center'] - rect_params['scale'], rect_params['y_center'] + rect_params['scale'])
            glEnd()
            glfw.swap_buffers(window)

            end_time = time.perf_counter()
            sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
            microsecond_sleep(sleep_time)
            glfw.poll_events()
        luminance_next = Y
        print('Color:', color_next)
        print('Luminance:', luminance_next)
        color_list.append(color_next)
        luminance_list.append(luminance_next)
        if np.abs(luminance_next - aim_luminance) < Tolerance:
            print('Success up! Finished')
            glfw.terminate()
            return color_list, luminance_list
        if luminance_next < aim_luminance:
            color_down = color_next
        else:
            color_up = color_next




if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        'scale': 0.5,
    }
    aim_luminance = 100
    Tolerance = 0.1
    now = datetime.now()
    formatted_time = now.strftime("%Y_%m_%d_%H_%M_%S")
    save_dir_path = f'E:\Py_codes\VRR_Real\G1_Calibration\py_display_calibration_results/LG-G1-Std-{formatted_time}-AimL-{aim_luminance}'
    os.makedirs(save_dir_path)
    config_json = {'rect_params': rect_params, 'aim_luminance': aim_luminance, 'Tolerance': Tolerance}
    with open(os.path.join(save_dir_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp=fp)
    color_list, luminance_list = find_aim_color(rect_params, aim_luminance, Tolerance)
    csv_data = {'Color': color_list, 'Luminance': luminance_list}
    df = pd.DataFrame(csv_data)
    df.to_csv(os.path.join(save_dir_path, 'result_data.csv'), index=False)