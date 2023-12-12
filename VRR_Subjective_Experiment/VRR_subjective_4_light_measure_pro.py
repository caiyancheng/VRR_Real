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

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + sleep_time
    while time.perf_counter() < end_time:
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

def vrr_one_block(glfw, window, vrr_params, c_params, time_display_params):
    x_center, y_center, x_scale, y_scale, interval_time, vrr_color = c_params
    center_point_color = np.array(vrr_color) * 2
    winsound.Beep(6000, 100)  # Begin

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    VRR_Begin = False
    # while not glfw.window_should_close(window):
    #     glClear(GL_COLOR_BUFFER_BIT)
    #     if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
    #         break
    #     glColor3f(vrr_color[0], vrr_color[1], vrr_color[2])
    #     glBegin(GL_QUADS)
    #     glVertex2f(x_center - x_scale, y_center - y_scale)
    #     glVertex2f(x_center + x_scale, y_center - y_scale)
    #     glVertex2f(x_center + x_scale, y_center + y_scale)
    #     glVertex2f(x_center - x_scale, y_center + y_scale)
    #     glEnd()
    #
    #     glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
    #     glBegin(GL_QUADS)
    #     glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
    #     glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
    #     glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
    #     glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
    #     glEnd()
    #
    #     glfw.swap_buffers(window)
    #     if keyboard.is_pressed("enter"):
    #         break
    #     glfw.poll_events()

    winsound.Beep(10000, 100)
    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        if frame_begin_time - all_begin_time > time_display_params['time_one_pattern']:
            break
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        color = vrr_color
        if not VRR_Begin:
            begin_vrr_time = time.perf_counter()
            VRR_Begin = True
        if time.perf_counter() - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter() - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter()
            frame_rate = vrr_params['frame_rate_max']
        glColor3f(color[0], color[1], color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        # glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        # glBegin(GL_QUADS)
        # glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        # glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        # glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        # glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        # glEnd()

        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()

    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        if frame_begin_time - all_begin_time > time_display_params['time_one_pattern'] + time_display_params['time_blank_time']:
            break
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        color = [0,0,0]
        frame_rate = vrr_params['frame_rate_max']
        glColor3f(color[0], color[1], color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_exp_main(change_parameters, vrr_params, time_display_params, real_save_path):
    with open(r'../G1_Calibration\Official_Config\Aim_L_[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 50, 100]_Size_[0.5, 1, 2, 4, 8, 16, 32]_Hot/result_dict.json', 'r') as fp:
        luminance_dict = json.load(fp)
    glfw, window = start_opengl()
    luminance_list = change_parameters['Luminance']
    vrr_f_list = change_parameters['VRR_Frequency']
    size_list = change_parameters['Size']
    ecc_list = change_parameters['Eccentricity']
    log_json = {}
    for lum in luminance_list:
        for vrr_f in vrr_f_list:
            for size in size_list:
                for ecc in ecc_list:
                    now_time = time.time()
                    print('Now_Time', now_time, 'Luminace', lum, 'VRR_Frequency', vrr_f, 'Size', size, 'Eccentricity', ecc)
                    log_json[str(now_time)] = {'Luminace': lum, 'VRR_Frequency': vrr_f, 'Size': size, 'Eccentricity': ecc}
                    x_center, y_center = compute_x_y_from_eccentricity(eccentricity=ecc)
                    x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
                    interval_time = 1 / (2 * vrr_f)
                    color = luminance_dict[f'L_{lum}_S_{size}']
                    vrr_color = [color, color, color]
                    c_params = x_center, y_center, x_scale, y_scale, interval_time, vrr_color
                    vrr_one_block(glfw=glfw,
                                  window=window,
                                  vrr_params=vrr_params,
                                  c_params=c_params,
                                  time_display_params=time_display_params,)
    with open(os.path.join(real_save_path, 'display_log.json'), 'w') as fp:
        json.dump(log_json, fp)


if __name__ == "__main__":
    change_parameters = {
        'VRR_Frequency': [0.5, 1, 2, 5, 10, 20, 50], #[2, 5, 10],
        'Luminance': [1, 2, 3, 4, 5, 10, 100], #[1, 2, 3, 4, 5, 10, 100],
        'Size': [0.5, 1, 2, 4, 8, 16, 32], #[4, 16],
        'Eccentricity': [0],
    }
    # change_parameters = {
    #     'VRR_Frequency': [0.5, 1],  # [2, 5, 10],
    #     'Luminance': [10, 100],  # [1, 2, 3, 4, 5, 10, 100],
    #     'Size': [16, 32],  # [4, 16],
    #     'Eccentricity': [0],
    # }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    time_display_params = {
        'time_one_pattern': 100, #each pattern 100s
        'time_blank_time': 10,
    }
    save_path = r'B:\Py_codes\VRR_Real\VRR_Subjective_Experiment/Subjective_4_Light_Measure_set'
    current_time = datetime.now()
    readable_timestamp = current_time.strftime("%Y-%m-%d-%H-%M-%S")
    real_save_path = os.path.join(save_path, readable_timestamp)
    os.makedirs(real_save_path)
    config_json = {
        'change_params': change_parameters,
        'vrr_params': vrr_params,
        'time_display_params': time_display_params,
    }
    with open(os.path.join(real_save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    print(change_parameters)
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params,
                 time_display_params=time_display_params,
                 real_save_path=real_save_path)