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
from G1_Calibration.compute_spatial_frequency import compute_spatial_frequency

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + sleep_time
    while time.perf_counter_ns() / 1e9 < end_time:
        pass

def create_gabor_patch(width, height, frequency, theta, amplitude, base_color, std_x, std_y):
    x, y = np.meshgrid(np.linspace(-1, 1, width), np.linspace(-1, 1, height))
    x_rotated = x * np.cos(theta) - y * np.sin(theta)
    y_rotated = x * np.sin(theta) + y * np.cos(theta)
    gabor = amplitude * np.exp(-0.5 * (x_rotated**2 / (std_x**2) + y_rotated**2 / (std_y**2))) * np.cos(2 * np.pi * frequency * x_rotated) + base_color
    # gabor = (gabor - np.min(gabor)) / (np.max(gabor) - np.min(gabor))  # 将值范围缩放到 [0, 1]
    gabor_patch = (255 * gabor).astype(np.uint8)
    gabor_patch = np.dstack([gabor_patch] * 3)
    return gabor_patch


def create_gabor_patch_disk(width, height, frequency, theta, amplitude, base_color, std_x, std_y):
    x, y = np.meshgrid(np.linspace(-1, 1, width), np.linspace(-1, 1, height))
    x_rotated = x * np.cos(theta) - y * np.sin(theta)
    y_rotated = x * np.sin(theta) + y * np.cos(theta)
    gabor = amplitude * np.exp(-0.5 * (x_rotated ** 2 / (std_x ** 2) + y_rotated ** 2 / (std_y ** 2))) * np.cos(
        2 * np.pi * frequency * x_rotated) + base_color
    gabor_patch = (255 * gabor).astype(np.uint8)

    outside_ellipse = (x ** 2 / (std_x ** 2) + y ** 2 / (std_y ** 2)) > 1
    gabor_patch[outside_ellipse] = 0

    gabor_patch = np.dstack([gabor_patch] * 3)
    return gabor_patch


def create_texture(gabor_patch):
    texture_id = glGenTextures(1)
    glBindTexture(GL_TEXTURE_2D, texture_id)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    width, height = gabor_patch.shape[1], gabor_patch.shape[0]  # 获取纹理的宽度和高度
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, gabor_patch)
    return texture_id

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
    x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range, f = c_params
    gabor_f = compute_spatial_frequency(cpd=f)
    initial_color = initial_color*2
    # gabor_patch = create_gabor_patch_disk(screen_width, screen_height, gabor_f, 0, 0.1, 0.5, 5, 5)
    gabor_patch = create_gabor_patch_disk(screen_width, screen_height, gabor_f, 0, 0.5, 0.5, x_scale, y_scale)
    create_texture(gabor_patch)
    glEnable(GL_TEXTURE_2D)

    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        glColor3f(initial_color, initial_color, initial_color)
        glBegin(GL_QUADS)
        glTexCoord2f(0, 0)
        glVertex2f(-1, -1)
        glTexCoord2f(1, 0)
        glVertex2f(1, -1)
        glTexCoord2f(1, 1)
        glVertex2f(1, 1)
        glTexCoord2f(0, 1)
        glVertex2f(-1, 1)
        glEnd()

        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        if keyboard.is_pressed("Backspace"):
            return -2
        glfw.poll_events()
    winsound.Beep(4000, 100)

    begin_vrr_time = time.perf_counter_ns()/1e9
    color = initial_color
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        frame_begin_time = time.perf_counter_ns()/1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        elif time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter_ns()/1e9
            frame_rate = vrr_params['frame_rate_max']
        if keyboard.is_pressed("control"):
            frame_rate =  vrr_params['fix_frame_rate']
        if keyboard.is_pressed("space"):
            return color
        elif keyboard.is_pressed("up") or keyboard.is_pressed("up arrow"):
            if keyboard.is_pressed("shift"):
                color = color + 0.02
            else:
                color = color + 0.0005
        elif keyboard.is_pressed("down") or keyboard.is_pressed("down arrow"):
            if keyboard.is_pressed("shift"):
                color = color - 0.02
            else:
                color = color - 0.0005

        if color > color_range[1]:
            color = color_range[1]
            winsound.Beep(10000, 100)
        elif color < color_range[0]:
            color = color_range[0]
            winsound.Beep(2000, 100)

        glColor3f(color*2, color*2, color*2)
        glBegin(GL_QUADS)
        glTexCoord2f(0, 0)
        glVertex2f(-1, -1)
        glTexCoord2f(1, 0)
        glVertex2f(1, -1)
        glTexCoord2f(1, 1)
        glVertex2f(1, 1)
        glTexCoord2f(0, 1)
        glVertex2f(-1, 1)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns()/1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()
    glBindTexture(GL_TEXTURE_2D, 0)

def vrr_one_block_square(glfw, window, vrr_params, c_params):
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range, gabor_f = c_params
    while not glfw.window_should_close(window):
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
    winsound.Beep(4000, 100)

    begin_vrr_time = time.perf_counter_ns()/1e9
    color = initial_color
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        frame_begin_time = time.perf_counter_ns()/1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        elif time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time:
            frame_rate = vrr_params['frame_rate_min']
        elif time.perf_counter_ns()/1e9 - begin_vrr_time < interval_time * 2:
            frame_rate = vrr_params['frame_rate_max']
        else:
            begin_vrr_time = time.perf_counter_ns()/1e9
            frame_rate = vrr_params['frame_rate_max']
        if keyboard.is_pressed("control"):
            frame_rate =  vrr_params['fix_frame_rate']
        if keyboard.is_pressed("space"):
            return color
        elif keyboard.is_pressed("up") or keyboard.is_pressed("up arrow"):
            if keyboard.is_pressed("shift"):
                color = color + 0.02
            else:
                color = color + 0.0005
        elif keyboard.is_pressed("down") or keyboard.is_pressed("down arrow"):
            if keyboard.is_pressed("shift"):
                color = color - 0.02
            else:
                color = color - 0.0005

        if color > color_range[1]:
            color = color_range[1]
            winsound.Beep(10000, 100)
        elif color < color_range[0]:
            color = color_range[0]
            winsound.Beep(2000, 100)

        glColor3f(color, color, color)
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns()/1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_exp_main(change_parameters, vrr_params, save_path, random_shuffle):
    #如果是连续调节，其实都不需要预先校准了，直接在最后得出pixel value进行一个校准就可以了
    experiment_record = {'Block_ID': [], 'VRR_Frequency': [], 'Observer_color_value': [],
                         'Size_Degree': [], 'Gabor_Frequency':[], 'Repeat_ID': []}
    experiment_json_dict = {}
    glfw, window = start_opengl()
    setting_list = []
    for vrr_f in change_parameters['VRR_Frequency']:
        for size in change_parameters['Size']:
            for gabor_f in change_parameters['Gabor_Frequency']:
                experiment_json_dict[f'V_{vrr_f}_S_{size}_G_{gabor_f}'] = []
                setting_params = vrr_f, size, gabor_f
                setting_list.append(setting_params)

    for re_i in range(change_parameters['Repeat_times']):
        if random_shuffle:
            random.shuffle(setting_list)
        index = 0
        while index < len(setting_list):
            setting_params = setting_list[index]
            vrr_f, size, gabor_f = setting_params
            x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
            x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
            interval_time = 1 / (2 * vrr_f)
            initial_color = random.uniform(0, 0.3)
            color_range = change_parameters['Color_Value_adjust_range']
            c_params = x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range, gabor_f
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
            elif observer_choice == -2:  # -2代表认为前一个出现了错误，希望重来
                index = index - 1
                winsound.Beep(8000, 100)
                print('Something Wrong! Return to the previous one.')
                for key in experiment_record.keys():
                    experiment_record[key].pop()
                vrr_f, size, gabor_f = setting_list[index]
                experiment_json_dict[f'V_{vrr_f}_S_{size}_G_{gabor_f}'].pop()

            else:  # 否则这个observer_choice就是对应的Color
                print('VRR_Frequency:', vrr_f, 'Size_Degree:', size, 'Gabor_Frequency:', gabor_f,
                      'Repeat_ID:', re_i, 'Observer_color_value:', observer_choice)
                experiment_record['Block_ID'].append(index)
                experiment_record['VRR_Frequency'].append(vrr_f)
                experiment_record['Gabor_Frequency'].append(gabor_f)
                experiment_record['Observer_color_value'].append(observer_choice)
                experiment_record['Size_Degree'].append(size)
                experiment_record['Repeat_ID'].append(re_i)
                experiment_json_dict[f'V_{vrr_f}_S_{size}_G_{gabor_f}'].append(observer_choice)
                index = index + 1

            df = pd.DataFrame(experiment_record)
            df.to_csv(os.path.join(save_path, 'result_in_progress.csv'), index=False)
            with open(os.path.join(save_path, 'result_in_progress.json'), 'w') as fp:
                json.dump(experiment_json_dict, fp)

    glfw.terminate()
    df = pd.DataFrame(experiment_record)
    df.to_csv(os.path.join(save_path, 'result.csv'), index=False)
    with open(os.path.join(save_path, 'result.json'), 'w') as fp:
        json.dump(experiment_json_dict, fp)


if __name__ == "__main__":
    # 这段代码即为完整代码
    change_parameters = {
        'VRR_Frequency': [8],
        'Color_Value_adjust_range': [0, 1],
        'Size': [16],
        'Gabor_Frequency': [0.5, 1, 2, 4, 8],
        # 'Gabor_Amplitude': [0.1], #颜色变化的百分比
        'Repeat_times': 1,
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    observer_params = {
        'name': 'Yancheng_Cai_2',
        'age': 22,
        'gender': 'M',
    }
    # observer_params = {
    #     'name': 'Ali_2',
    #     'age': 29,
    #     'gender': 'M',
    # }
    # observer_params = {
    #     'name': 'Rafal_10',
    #     'age': 45,
    #     'gender': 'M',
    # }
    print(change_parameters)
    save_base_path = r'../VRR_Subjective_MOA/Result_MOA_gabor_1/'
    save_path = os.path.join(save_base_path, f"Observer_{observer_params['name']}")
    os.makedirs(save_path, exist_ok=True)
    config_json = {'change_parameters': change_parameters,
                   'vrr_params': vrr_params,
                   'observer_params': observer_params,}
    with open(os.path.join(save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params,
                 save_path=save_path,
                 random_shuffle=True)