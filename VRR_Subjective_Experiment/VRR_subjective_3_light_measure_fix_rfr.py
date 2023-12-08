# 这段代码与2相比，加入了声音作为提示
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

def vrr_one_block(glfw, window, vrr_params, c_params):
    x_center, y_center, x_scale, y_scale, vrr_color = c_params
    center_point_color = np.array(vrr_color) * 2
    winsound.Beep(6000, 100)  # Begin

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    VRR_Begin = False
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        glColor3f(vrr_color[0], vrr_color[1], vrr_color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        glBegin(GL_QUADS)
        glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        glEnd()

        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        glfw.poll_events()

    winsound.Beep(10000, 100)
    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        color = vrr_color
        frame_rate = vrr_params['fix_frame_rate']
        glColor3f(color[0], color[1], color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        glBegin(GL_QUADS)
        glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        glEnd()

        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_exp_main(change_parameters, vrr_params):
    with open('E:\Py_codes\VRR_Real\G1_Calibration\Official_Config\Aim_L_[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 50, 100]_Size_[4, 16]_Hot/result_dict.json', 'r') as fp:
        luminance_dict = json.load(fp)
    glfw, window = start_opengl()
    lum = change_parameters['Luminance']
    size = change_parameters['Size']
    ecc = change_parameters['Eccentricity']
    print('Luminace', lum, 'Size', size)
    x_center, y_center = compute_x_y_from_eccentricity(eccentricity=ecc)
    x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
    color = luminance_dict[f'L_{lum}_S_{size}']
    vrr_color = [color, color, color]
    c_params = x_center, y_center, x_scale, y_scale, vrr_color
    vrr_one_block(glfw=glfw,
                  window=window,
                  vrr_params=vrr_params,
                  c_params=c_params)


if __name__ == "__main__":
    # 这段代码即为完整代码
    change_parameters = {
        'Luminance': 100, #[1, 2, 3, 4, 5, 10, 100],
        'Size': 16, #[4, 16],
        'Eccentricity': 0,
    }
    vrr_params = {
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    print(change_parameters)
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params,)