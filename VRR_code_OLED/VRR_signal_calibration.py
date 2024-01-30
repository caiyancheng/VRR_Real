import glfw
from OpenGL.GL import *
import time
import cv2
import numpy as np
import math
from G1_Calibration.compute_size_real import compute_scale_from_degree

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + (sleep_time)
    while time.perf_counter_ns() / 1e9 < end_time:
        pass

def vrr_generate(rect_params, frame_rates, interval_times, total_time):
    if not glfw.init():
        return
    num_segments = 1000
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    print('Screen_Width', screen_width)
    print('Screen_Height', screen_height)
    glfw.window_hint(glfw.VISIBLE, glfw.FALSE)
    window = glfw.create_window(screen_width, screen_height, "Color Disappearing Effect", second_monitor, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.swap_interval(1)
    glfw.show_window(window)

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    real_all_begin_time = all_begin_time = time.perf_counter_ns() / 1e9
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter_ns() / 1e9
        display_t = begin_time - all_begin_time
        real_display_t = begin_time - real_all_begin_time
        if real_display_t > total_time:
            break
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        if display_t < interval_times[0]:
            frame_rate = frame_rates[0]
        elif display_t < interval_times[0] + interval_times[1]:
            frame_rate = frame_rates[1]
        else:
            all_begin_time = time.perf_counter_ns() / 1e9

        glColor3f(rect_params['color'][0], rect_params['color'][1], rect_params['color'][2])
        x_center = rect_params['x_center']
        y_center = rect_params['y_center']
        x_scale, y_scale = compute_scale_from_degree(visual_degree=rect_params['diameter'])

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
        sleep_time = (1.0 / frame_rate - (end_time - begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    glfw.terminate()

if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        'diameter': 0.5,  # 长方形宽度
        'color': [1.0, 1.0, 1.0]  # 长方形颜色 (白色)\
        # 'color': [0.0703125, 0.0703125, 0.0703125]
    }
    frame_rates = [30, 120] # 第二个应该比第一个大
    interval_times = [0.1, 0.1]
    total_time = 10000 #总共展示的s数量
    vrr_generate(rect_params, frame_rates, interval_times, total_time)