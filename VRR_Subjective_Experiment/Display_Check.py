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

def main(frame_rate_zone, time_per_zone, clear_Color_steady, clear_Color_change, cotinue=False, black_frame=False):
    if not glfw.init():
        return

    # 获取第二个显示器的信息
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size

    # 设置窗口位置为第二个显示器的左上角
    glfw.window_hint(glfw.VISIBLE, glfw.FALSE)
    window = glfw.create_window(screen_width, screen_height, "Color Disappearing Effect", second_monitor, None)
    if not window:
        glfw.terminate()
        return

    glfw.make_context_current(window)
    glfw.swap_interval(1)
    glfw.show_window(window)

    # 设置视频输出
    # fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    # out = cv2.VideoWriter('output.mp4', fourcc, frame_rate_zone[1], (screen_width, screen_height))

    all_begin_time = time.perf_counter()
    while not glfw.window_should_close(window):
        begin_time = time.perf_counter()
        display_t = begin_time - all_begin_time
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
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
            frame_rate = frame_rate_zone[1] + (frame_rate_zone[2] - frame_rate_zone[1]) / time_per_zone[3] * (display_t - sum(time_per_zone[0:3]))
            clear_Color = clear_Color_change
        elif display_t < sum(time_per_zone[0:5]):
            frame_rate = frame_rate_zone[2]
            clear_Color = clear_Color_steady
        elif cotinue:
            all_begin_time = time.perf_counter()
        else:
            break

        if black_frame:
            glClearColor(0, 0, 0, 1.0)
            glClear(GL_COLOR_BUFFER_BIT)
            glfw.swap_buffers(window)

        # 读取OpenGL渲染的帧并保存为视频
        # glPixelStorei(GL_PACK_ALIGNMENT, 1)
        # data = glReadPixels(0, 0, screen_width, screen_height, GL_RGB, GL_UNSIGNED_BYTE)
        # image = np.frombuffer(data, dtype=np.uint8).reshape(screen_height, screen_width, 3)[::-1, :, :]

        # out.write(image)

        glClearColor(clear_Color[0], clear_Color[1], clear_Color[2], 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - begin_time)) * 1e6
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    # out.release()
    glfw.terminate()

if __name__ == "__main__":
    # clear_Color_change = [1.0, 0.5, 0.5]
    # clear_Color_steady = [1.0, 0.5, 0.5]
    clear_Color_steady = [0.0703125, 0.0703125, 0.0703125]
    clear_Color_change = [0.0703125, 0.0703125, 0.0703125]
    # clear_Color_steady = [0.8, 0.8, 0.8]
    # clear_Color_change = [0.8, 0.8, 0.8]
    # clear_Color_steady = [0.6, 0.6, 0.6]
    # clear_Color_change = [0.6, 0.6, 0.6]
    # clear_Color_steady = [0.4, 0.4, 0.4]
    # clear_Color_change = [0.4, 0.4, 0.4]
    # clear_Color_steady = [0.2, 0.2, 0.2]
    # clear_Color_change = [0.2, 0.2, 0.2]
    frame_rate_zone = [30, 30, 30]
    # frame_rate_zone = [30, 240, 30]
    # frame_rate_zone = [80, 120, 80]
    # time_per_zone = [4, 2, 2, 2, 2]
    time_per_zone = [0.1, 0, 0.1, 0, 0]
    # time_per_zone = [1,1,1,1,1]
    main(frame_rate_zone, time_per_zone, clear_Color_steady, clear_Color_change, cotinue=True, black_frame=False)