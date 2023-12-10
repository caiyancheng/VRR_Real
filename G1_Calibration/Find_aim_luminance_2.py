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


def find_aim_color(rect_params, aim_luminance, Tolerance, size, maxtime=1000):
    global Y, x, y
    if not glfw.init():
        return
    x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
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
        glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] - y_scale)
        glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] - y_scale)
        glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] + y_scale)
        glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] + y_scale)
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
        glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] - y_scale)
        glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] - y_scale)
        glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] + y_scale)
        glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] + y_scale)
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
            glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] - y_scale)
            glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] - y_scale)
            glVertex2f(rect_params['x_center'] + x_scale, rect_params['y_center'] + y_scale)
            glVertex2f(rect_params['x_center'] - x_scale, rect_params['y_center'] + y_scale)
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

def find_aim_color_list(rect_params, aim_luminance_list, tolerance_list, size_list, save_dir_path):
    json_result = {}
    for size in size_list:
        for aim_luminance, tolerance in zip(aim_luminance_list, tolerance_list):
            color_list, luminance_list = find_aim_color(rect_params, aim_luminance, tolerance, size)
            csv_data = {'Color': color_list, 'Luminance': luminance_list}
            df = pd.DataFrame(csv_data)
            df.to_csv(os.path.join(save_dir_path, f'Aim_L_{aim_luminance}_Size_{size}_result.csv'), index=False)
            json_result[f'L_{aim_luminance}_S_{size}'] = color_list[-1]
    with open(os.path.join(save_dir_path, 'result_dict.json'), 'w') as fp:
        json.dump(json_result, fp)



if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        # 'scale': 1,
        # 'size' : 4,
    }
    aim_luminance_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 50, 100]
    tolerance_list = [0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.2, 0.5, 0.5, 1, 1]
    # aim_luminance_list = [2, 3, 4]
    # tolerance_list = [0.1, 0.1, 0.1]
    if not len(aim_luminance_list) == len(tolerance_list):
        assert ValueError('The Length of aim_luminance_list is not equal to tolerance_list')
    size_list = [0.5, 1, 2, 4, 8, 16, 32]

    # now = datetime.now()
    # formatted_time = now.strftime("%Y_%m_%d_%H_%M_%S")
    save_dir_path = f"E:\Py_codes\VRR_Real\G1_Calibration\Official_Config/Aim_L_{aim_luminance_list}_Size_{size_list}_Hot"
    os.makedirs(save_dir_path, exist_ok=True)
    config_json = {'rect_params': rect_params, 'aim_luminance_list': aim_luminance_list,
                   'tolerance_list': tolerance_list, 'size_list': size_list}
    with open(os.path.join(save_dir_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp=fp)
    find_aim_color_list(rect_params, aim_luminance_list, tolerance_list, size_list, save_dir_path)