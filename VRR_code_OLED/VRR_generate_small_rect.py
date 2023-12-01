import glfw
from OpenGL.GL import *
import time
import cv2
import numpy as np

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time) / 1e6
    while time.perf_counter() < end_time:
        pass

def vrr_generate(rect_params, frame_rates, interval_times, total_time):
    if not glfw.init():
        return
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
    real_all_begin_time = all_begin_time = time.perf_counter()
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter()
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
            all_begin_time = time.perf_counter()

        glColor3f(rect_params['color'][0], rect_params['color'][1], rect_params['color'][2])
        glBegin(GL_QUADS)
        # glVertex2f(rect_params['x_center'] / screen_width - rect_params['width'] / (2 * screen_width),
        #            rect_params['y_center'] / screen_height - rect_params['height'] / (2 * screen_height))
        # glVertex2f(rect_params['x_center'] / screen_width + rect_params['width'] / (2 * screen_width),
        #            rect_params['y_center'] / screen_height - rect_params['height'] / (2 * screen_height))
        # glVertex2f(rect_params['x_center'] / screen_width + rect_params['width'] / (2 * screen_width),
        #            rect_params['y_center'] / screen_height + rect_params['height'] / (2 * screen_height))
        # glVertex2f(rect_params['x_center'] / screen_width - rect_params['width'] / (2 * screen_width),
        #            rect_params['y_center'] / screen_height + rect_params['height'] / (2 * screen_height))
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] - rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] + rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glVertex2f(rect_params['x_center'] - rect_params['width_scale'], rect_params['y_center'] + rect_params['height_scale'])
        glEnd()
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    glfw.terminate()

if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        'width_scale': 0.05,  # 长方形宽度
        'height_scale': 0.05,  # 长方形高度
        # 'color': [1.0, 1.0, 1.0]  # 长方形颜色 (白色)\
        'color': [0.0703125, 0.0703125, 0.0703125]
    }
    frame_rates = [30, 120] # 第二个应该比第一个大
    interval_times = [0.1, 0.1]
    total_time = 10000 #总共展示的s数量
    vrr_generate(rect_params, frame_rates, interval_times, total_time)