import glfw
from OpenGL.GL import *
from OpenGL.GLUT.freeglut import *
import time
import cv2
import numpy as np
import random
import keyboard

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + sleep_time
    while time.perf_counter() < end_time:
        pass

def vrr_exp_1(rect_params, vrr_params, other_params, random_vrr_period):
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    # print('Screen_Width', screen_width)
    # print('Screen_Height', screen_height)
    # glfw.window_hint(glfw.VISIBLE, glfw.FALSE)
    window = glfw.create_window(screen_width, screen_height, "Color Disappearing Effect", second_monitor, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.swap_interval(1)
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    glfw.show_window(window)
    while not glfw.window_should_close(window):
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        glColor3f(rect_params['color'][0],rect_params['color'][1],rect_params['color'][2])
        glBegin(GL_QUADS)
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glEnd()
        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        glfw.poll_events()

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    VRR_Begin = False
    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        display_t = frame_begin_time - all_begin_time
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        if display_t < other_params['signal_time']: #第一个红色signal
            color = other_params['signal_1_color']
            frame_rate = vrr_params['fix_frame_rate']
        elif display_t < other_params['signal_time'] + vrr_params['vrr_total_time']: #第一个展示片段
            color = rect_params['color']
            if random_vrr_period == 0: #VRR
                if not VRR_Begin:
                    begin_vrr_time = time.perf_counter()
                    VRR_Begin = True
                if time.perf_counter() - begin_vrr_time < vrr_params['interval_time']:
                    frame_rate = vrr_params['frame_rate_min']
                elif time.perf_counter() - begin_vrr_time < vrr_params['interval_time'] * 2:
                    frame_rate = vrr_params['frame_rate_max']
                else:
                    begin_vrr_time = time.perf_counter()
                    frame_rate = vrr_params['frame_rate_max']
            else:
                frame_rate = vrr_params['fix_frame_rate']
        elif display_t < other_params['signal_time'] * 2 + vrr_params['vrr_total_time']:
            color = other_params['signal_2_color']
            frame_rate = vrr_params['fix_frame_rate']
        elif display_t < other_params['signal_time'] * 2 + vrr_params['vrr_total_time'] * 2:
            color = rect_params['color']
            if random_vrr_period == 1:  # VRR
                if not VRR_Begin:
                    begin_vrr_time = time.perf_counter()
                    VRR_Begin = True
                if time.perf_counter() - begin_vrr_time < vrr_params['interval_time']:
                    frame_rate = vrr_params['frame_rate_min']
                elif time.perf_counter() - begin_vrr_time < vrr_params['interval_time'] * 2:
                    frame_rate = vrr_params['frame_rate_max']
                else:
                    begin_vrr_time = time.perf_counter()
                    frame_rate = vrr_params['frame_rate_max']
            else:
                frame_rate = vrr_params['fix_frame_rate']
        else:
            break
        glColor3f(color[0], color[1], color[2])
        glBegin(GL_QUADS)
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glEnd()
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    glfw.terminate()

if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        'width_scale': 1,  # 长方形宽度
        'height_scale': 1,  # 长方形高度
        # 'color': [0.515625, 0.515625, 0.515625],  # 长方形颜色 (白色)\
        # 'color': [0.171875, 0.171875, 0.171875],  # 长方形颜色 (白色)\
        # 'color': [0.062500, 0.062500, 0.062500],  # 长方形颜色 (白色)\
        'color': [0.6640625, 0.6640625, 0.6640625],
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'interval_time': 0.1,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    other_params = {
        'signal_1_color': [0.1, 0.1, 0.1],
        'signal_2_color': [0.1, 0.1, 0.1],
        'signal_time': 0.2,
    }
    # random_vrr_period = random.randint(0, 1)
    random_vrr_period = 0
    print(f'VRR will be shown on the {random_vrr_period + 1} period')
    vrr_exp_1(rect_params, vrr_params, other_params, random_vrr_period)