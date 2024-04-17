# Compare to the previous version

# Observer Change Luminance, VRR_f and Size is fixed by the program.
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
import os
import math
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.


def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + sleep_time
    while time.perf_counter_ns() / 1e9 < end_time:
        pass


def start_opengl():
    global center_point_size_y, screen_width, screen_height
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
    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    glfw.show_window(window)
    return glfw, window


def vrr_one_block_disk(glfw, window, vrr_params, c_params):
    global screen_width, screen_height
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, interval_time, color_value = c_params
    num_segments = 100

    begin_vrr_time = time.perf_counter_ns() / 1e9
    color = color_value
    while not keyboard.is_pressed("enter"):
        X = 1
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        frame_begin_time = time.perf_counter_ns() / 1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        elif time.perf_counter_ns() / 1e9 - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter_ns() / 1e9 - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter_ns() / 1e9
            frame_rate = vrr_params['frame_rate_max']
        if keyboard.is_pressed("control"):
            frame_rate = vrr_params['fix_frame_rate']
        if keyboard.is_pressed("space"):
            return 1

        glColor3f(color, color, color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)

        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns() / 1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_one_block_square(glfw, window, vrr_params, c_params):
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, interval_time, color_value = c_params

    begin_vrr_time = time.perf_counter_ns() / 1e9
    color = color_value
    while not keyboard.is_pressed("enter"):
        X = 1
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        frame_begin_time = time.perf_counter_ns() / 1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        elif time.perf_counter_ns() / 1e9 - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter_ns() / 1e9 - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter_ns() / 1e9
            frame_rate = vrr_params['frame_rate_max']
        if keyboard.is_pressed("space"):
            return 1

        glColor3f(color, color, color)
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


def vrr_exp_main(change_parameters, vrr_params,):
    color_values = np.linspace(change_parameters['Color_Value_adjust_range'][0],
                               change_parameters['Color_Value_adjust_range'][1],
                               num=change_parameters['Color_sample_numbers'])
    glfw, window = start_opengl()
    setting_list = []
    for vrr_f in change_parameters['VRR_Frequency']:
        for size in change_parameters['Size']:
            for color_value in color_values:
                setting_params = vrr_f, size, color_value
                setting_list.append(setting_params)
    index = 0
    while index < len(setting_list):
        setting_params = setting_list[index]
        vrr_f, size, color_value = setting_params
        print('VRR_Frequency', vrr_f, 'Size', size, 'Color Value', color_value)
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
        interval_time = 1 / (2 * vrr_f)
        c_params = x_center, y_center, x_scale, y_scale, interval_time, color_value
        if size == 'full':
            observer_choice = vrr_one_block_square(glfw=glfw,
                                                   window=window,
                                                   vrr_params=vrr_params,
                                                   c_params=c_params)
        else:
            observer_choice = vrr_one_block_disk(glfw=glfw,
                                                 window=window,
                                                 vrr_params=vrr_params,
                                                 c_params=c_params)
        if observer_choice == -1:  # -1代表想要退出
            break
        else:
            index = index + 1
    glfw.terminate()

if __name__ == "__main__":
    change_parameters = {
        'VRR_Frequency': [0.5, 2, 4, 8, 10, 12, 14, 16],
        'Color_Value_adjust_range': [0.04, 0.2],
        'Color_sample_numbers': 10,
        'Size': [16, 'full'],
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        # 'vrr_total_time': 2, #s使用空格键才会进入下一阶段
        'fix_frame_rate': 60,
    }
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params)
