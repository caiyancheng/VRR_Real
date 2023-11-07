# 相比VRR_1, 现在的代码将屏幕分成两半，一半展示“闪烁”，一半维持稳定
import glfw
from OpenGL.GL import *
import time
import numpy as np

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + (sleep_time - 0.6) / 1e6
    while time.perf_counter() < end_time:
        pass

def gamma_corrected_color(color, gamma=2.2):
    return [pow(c, 1.0/gamma) for c in color]

def draw_half_screen(clear_Color, left=True):
    half_width = screen_width // 2
    x_start = 0 if left else half_width

    glColor3f(*clear_Color)
    glBegin(GL_QUADS)
    glVertex2f(x_start, 0)
    glVertex2f(x_start + half_width, 0)
    glVertex2f(x_start + half_width, screen_height)
    glVertex2f(x_start, screen_height)
    glEnd()

def main(frame_rate_zone, time_per_zone, clear_Color_steady, clear_Color_change):
    global screen_width, screen_height  # 使用全局变量来在其他函数中访问这些值

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

    glOrtho(0, screen_width, 0, screen_height, -1, 1)  # 设置正投影

    all_begin_time = time.perf_counter()
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter()
        display_t = begin_time - all_begin_time

        if display_t < time_per_zone[0]:
            frame_rate = frame_rate_zone[0]
            clear_Color = clear_Color_steady
        elif display_t < sum(time_per_zone[0:2]):
            frame_rate = frame_rate_zone[0] + (frame_rate_zone[1] - frame_rate_zone[0]) / time_per_zone[1] * (display_t - time_per_zone[0])
            clear_Color = clear_Color_change
        elif display_t < sum(time_per_zone[0:3]):
            frame_rate = frame_rate_zone[1]
            clear_Color = clear_Color_steady
        elif display_t < sum(time_per_zone[0:4]):
            frame_rate = frame_rate_zone[1] + (frame_rate_zone[2] - frame_rate_zone[1]) / time_per_zone[3] * (
                        display_t - sum(time_per_zone[0:3]))
            clear_Color = clear_Color_change
        elif display_t < sum(time_per_zone[0:5]):
            frame_rate = frame_rate_zone[2]
            clear_Color = clear_Color_steady
        else:
            break

        glClearColor(0, 0, 0, 1.0)
        glClear(GL_COLOR_BUFFER_BIT)

        # 绘制左侧
        draw_half_screen(clear_Color, left=True)

        # Gamma校正后的颜色用于绘制右侧
        corrected_color = gamma_corrected_color(clear_Color)
        draw_half_screen(corrected_color, left=False)

        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()

    glfw.terminate()

if __name__ == "__main__":
    clear_Color_steady = [1.0, 1.0, 1.0]
    clear_Color_change = [1.0, 1.0, 1.0]
    frame_rate_zone = [60, 120, 60]
    time_per_zone = [3, 1, 2, 1, 3]
    main(frame_rate_zone, time_per_zone, clear_Color_steady, clear_Color_change)
