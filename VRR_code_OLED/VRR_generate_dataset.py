import glfw
from OpenGL.GL import *
import time
import cv2
import numpy as np
# 使用普通的计时方法，发现并没真正意义上实现Variable Refresh Rate（相当于在里面插帧）

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time) / 1e6
    while time.perf_counter() < end_time:
        pass

def vrr_generate(color, frame_rates, interval_times, total_time):
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

        glClearColor(color[0], color[1], color[2], 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    glfw.terminate()

if __name__ == "__main__":
    time.sleep(600)
    color = [1.0, 1.0, 1.0]
    frame_rates = [30, 120] # 第二个应该比第一个大
    interval_times = [0.1, 0.1]
    total_time = 10 #总共展示的s数量
    vrr_generate(color, frame_rates, interval_times, total_time)