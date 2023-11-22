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

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time) / 1e6
    while time.perf_counter() < end_time:
        pass
def get_color_thread():
    global Y, x, y
    time.sleep(3) #休息10s等待刷新率正常
    measuring_speed = " "  # Set your measuring speed
    command = f"E:/Matlab_codes/matlab_toolboxes/display_calibration/Konica/Konica_Measure_Light/Debug/Konica_Measure_Light.exe {measuring_speed}"
    result = subprocess.run(command, text=True, capture_output=True, shell=True)
    cmdout = result.stdout.strip()
    cmdout = ''.join(cmdout.split())
    split_str = cmdout.split(',')
    Y = float(split_str[9])
    x = float(split_str[10])
    y = float(split_str[11])

def frame_generate(rect_params, colors_range, maxtime=10000000):
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
    for color_i in tqdm(colors_range):
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
            glColor3f(color_i, color_i, color_i)
            glBegin(GL_QUADS)
            glVertex2f(rect_params['x_center'] / screen_width - rect_params['width'] / (2 * screen_width),
                       rect_params['y_center'] / screen_height - rect_params['height'] / (2 * screen_height))
            glVertex2f(rect_params['x_center'] / screen_width + rect_params['width'] / (2 * screen_width),
                       rect_params['y_center'] / screen_height - rect_params['height'] / (2 * screen_height))
            glVertex2f(rect_params['x_center'] / screen_width + rect_params['width'] / (2 * screen_width),
                       rect_params['y_center'] / screen_height + rect_params['height'] / (2 * screen_height))
            glVertex2f(rect_params['x_center'] / screen_width - rect_params['width'] / (2 * screen_width),
                       rect_params['y_center'] / screen_height + rect_params['height'] / (2 * screen_height))
            glEnd()
            glfw.swap_buffers(window)

            end_time = time.perf_counter()
            sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
            microsecond_sleep(sleep_time)
            glfw.poll_events()
        print('Color:', color_i)
        print('Luminance:', Y)
    glfw.terminate()


def interleave_arrays(arr1, arr2):
    return [item for pair in zip(arr1, arr2) for item in pair]
def calibration_color(rect_params, color_params):
    color_range = np.linspace(color_params['color_min'], color_params['color_max'], color_params['sample_points'])
    num_colors = color_params['sample_points']
    color_range_new = interleave_arrays(color_range[:int(num_colors/2)], color_range[int(num_colors/2):])
    frame_generate(rect_params=rect_params, colors_range=color_range_new)



if __name__ == "__main__":
    rect_params = {
        'x_center': 0,  # 长方形中心 x 坐标
        'y_center': 0,  # 长方形中心 y 坐标
        'width': 1600,  # 长方形宽度
        'height': 1600,  # 长方形高度
    }
    color_params = {
        'color_min': 0.5,
        'color_max': 1,
        'sample_points': 100,
    }
    calibration_color(rect_params, color_params)