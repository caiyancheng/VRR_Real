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
def start_opengl():
    global screen_width, screen_height
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

def vrr_one_block_square(glfw, window, c_params):
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, initial_color, measure_length = c_params
    display_time_list = []
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter_ns() / 1e9
        if len(display_time_list) >= measure_length:
            return display_time_list
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        glColor3f(initial_color, initial_color, initial_color)
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        if keyboard.is_pressed("Backspace"):
            return -2
        glfw.poll_events()
        final_time = time.perf_counter_ns() / 1e9
        display_time_list.append(final_time-begin_time)
    winsound.Beep(4000, 100)

def vrr_one_block_disk(glfw, window, c_params):
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, initial_color, measure_length = c_params
    display_time_list = []
    num_segments = 100
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter_ns() / 1e9
        if len(display_time_list) >= measure_length:
            return display_time_list
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        glColor3f(initial_color, initial_color, initial_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)

        glEnd()

        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        if keyboard.is_pressed("Backspace"):
            return -2
        glfw.poll_events()
        final_time = time.perf_counter_ns() / 1e9
        display_time_list.append(final_time-begin_time)
    winsound.Beep(4000, 100)

def compare_display_time_sizes(size_list):
    initial_color = 1
    measure_length = 1000
    glfw, window = start_opengl()
    for size_value in size_list:
        print('Size:', size_value)
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size_value)
        c_params = x_center, y_center, x_scale, y_scale, initial_color, measure_length
        time_list_square = vrr_one_block_square(glfw, window, c_params)
        time_array_square = np.array(time_list_square)
        print('Square Mean Time:', np.mean(time_array_square))
        print('Square STD Time:', np.std(time_array_square))
        time_list_disk = vrr_one_block_disk(glfw, window, c_params)
        time_array_disk = np.array(time_list_disk)
        print('Disk Mean Time:', np.mean(time_array_disk))
        print('Disk STD Time:', np.std(time_array_disk))



if __name__ == '__main__':
    size_list = [0.5, 0.5, 1, 16, 'full']
    compare_display_time_sizes(size_list=size_list)
