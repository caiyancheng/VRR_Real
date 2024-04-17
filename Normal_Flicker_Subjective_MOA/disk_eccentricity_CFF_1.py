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
from Color_and_Luminance import Color2Luminance_LG_G1

CL_transform = Color2Luminance_LG_G1()
CL_transform.__int__(degree_C2L=7, degree_L2C=7)


def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + sleep_time
    while time.perf_counter_ns() / 1e9 < end_time:
        pass


def start_opengl():
    global center_point_size_y, screen_width, screen_height
    if not glfw.init():
        return
    second_monitor = glfw.get_monitors()[1]
    screen_width, screen_height = glfw.get_video_mode(second_monitor).size
    # center_point_size_y = center_point_size_x * screen_width / screen_height
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


def cff_one_block_disk(glfw, window, all_params):
    global screen_width, screen_height
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, cs_x_scale, cs_y_scale, s_contrast, s_color, s_pers, c_color = all_params
    num_segments_s = 40
    num_segments_c = 20
    # 刚开始的休息循环
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        glColor3f(s_color, s_color, s_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments_s + 1):
            theta = i * (2.0 * math.pi / num_segments_s)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glColor3f(c_color, c_color, c_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0)
        for i in range(num_segments_c + 1):
            theta = i * (2.0 * math.pi / num_segments_c)
            x = cs_x_scale * math.cos(theta)
            y = cs_y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()
        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        if keyboard.is_pressed("Backspace"):
            return -2
        glfw.poll_events()
    winsound.Beep(4000, 100)

    # 中间的调整循环，变更的是CFF闪烁频率
    frame_rate = 20
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        frame_begin_time = time.perf_counter_ns() / 1e9
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        T_frame = 1 / frame_rate
        bright_frame_color = CL_transform.L2C(
            CL_transform.C2L(s_color) * (1 + s_contrast) / (1 + (2 * s_pers - 1) * s_contrast))
        dark_frame_color = CL_transform.L2C(
            CL_transform.C2L(s_color) * (1 - s_contrast) / (1 + (2 * s_pers - 1) * s_contrast))
        if keyboard.is_pressed("control"):
            bright_frame_color = dark_frame_color = s_color
        if keyboard.is_pressed("space"):
            return frame_rate
        elif keyboard.is_pressed("up") or keyboard.is_pressed("up arrow"):
            if keyboard.is_pressed("shift"):
                frame_rate = frame_rate + 2
            else:
                frame_rate = frame_rate + 0.1
        elif keyboard.is_pressed("down") or keyboard.is_pressed("down arrow"):
            if keyboard.is_pressed("shift"):
                frame_rate = frame_rate - 2
            else:
                frame_rate = frame_rate - 0.1

        if frame_rate > 100:
            frame_rate = 100
            winsound.Beep(10000, 100)
        elif frame_rate < 4:
            frame_rate = 4

            winsound.Beep(2000, 100)

        # Bright Frame
        glColor3f(bright_frame_color, bright_frame_color, bright_frame_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments_s + 1):
            theta = i * (2.0 * math.pi / num_segments_s)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glColor3f(c_color, c_color, c_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0)
        for i in range(num_segments_c + 1):
            theta = i * (2.0 * math.pi / num_segments_c)
            x = cs_x_scale * math.cos(theta)
            y = cs_y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns() / 1e9
        sleep_time = (T_frame * s_pers - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)

        # Dark Frame
        glClear(GL_COLOR_BUFFER_BIT)
        glColor3f(dark_frame_color, dark_frame_color, dark_frame_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments_s + 1):
            theta = i * (2.0 * math.pi / num_segments_s)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glColor3f(c_color, c_color, c_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0)
        for i in range(num_segments_c + 1):
            theta = i * (2.0 * math.pi / num_segments_c)
            x = cs_x_scale * math.cos(theta)
            y = cs_y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns() / 1e9
        sleep_time = (T_frame * s_pers - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def CFF_exp_main(stimulus_params, center_point_params, save_path, random_shuffle, continue_exp):
    # 判断是否能继续实验
    if continue_exp:
        if not os.path.exists(os.path.join(save_path, 'result_in_progress.json')):
            raise ValueError('Unable to continue, necessary files are missing!')
        else:
            print('Continue!')
            with open(os.path.join(save_path, 'result_in_progress.json'), 'r') as fp:
                experiment_json_dict = json.load(fp)
            df = pd.read_csv(os.path.join(save_path, 'result_in_progress.csv'))
            experiment_record = df.to_dict(orient='list')
    else:
        experiment_record = {'Block_ID': [], 'Stimulus_Contrast': [], 'Stimulus_Size': [],
                             'Stimulus_Color': [], 'Stimulus_Persistence': [], 'Stimulus_Eccentricity': [],
                             'Center_point_size': [], 'Center_point_color': [], 'Repeat_ID': [], 'CFF': []}
        experiment_json_dict = {}

    glfw, window = start_opengl()
    setting_list = []
    for s_contrast in stimulus_params['Contrast']:
        for s_size in stimulus_params['Size']:
            for s_color in stimulus_params['Color']:
                for s_pers in stimulus_params['Persistence']:
                    for s_ecc in stimulus_params['Eccentricity']:
                        for c_size in center_point_params['Size']:
                            for c_color in center_point_params['Color']:
                                setting_params = s_contrast, s_size, s_color, s_pers, s_ecc, c_size, c_color
                                setting_list.append(setting_params)

    for re_i in range(stimulus_params['Repeat_times']):  # 做两次正好可以验证一下local adaptation
        if random_shuffle:
            random.shuffle(setting_list)
        index = 0
        while index < len(setting_list):
            setting_params = setting_list[index]
            s_contrast, s_size, s_color, s_pers, s_ecc, c_size, c_color = setting_params
            print('Stimulus_Contrast', s_contrast, 'Stimulus_Size', s_size, 'Stimulus_Color', s_color,
                  'Stimulus_Persistence', s_pers, 'Stimulus_Eccentricity', s_ecc, 'Center_point_size', c_size,
                  'Center_point_color', c_color)
            file_name = f'SCT_{s_contrast}_SS_{s_size}_SCR_{s_color}_SP_{s_pers}_SE_{s_ecc}_CS_{c_size}_CC_{c_color}'
            if continue_exp and file_name in experiment_json_dict.keys():
                print('Jump (Already has this data)')
                index = index + 1
                continue
            experiment_json_dict[file_name] = []
            x_center, y_center = compute_x_y_from_eccentricity(eccentricity=s_ecc)
            x_scale, y_scale = compute_scale_from_degree(visual_degree=s_size)
            cs_x_scale, cs_y_scale = compute_scale_from_degree(visual_degree=c_size)
            all_params = x_center, y_center, x_scale, y_scale, cs_x_scale, cs_y_scale, s_contrast, s_color, s_pers, c_color
            if s_size == 'full' or s_size > 10:
                raise ValueError('In the Eccentricity Experiment the Stimulus Size could not be too large.')
            else:
                observer_choice = cff_one_block_disk(glfw=glfw, window=window, all_params=all_params)
            if observer_choice == -1:  # -1代表想要退出
                print('You want to quit? OK!')
                return 0
            elif observer_choice == -2:  # -2代表认为前一个出现了错误，希望重来
                index = index - 1
                winsound.Beep(8000, 100)
                print('Something Wrong! Return to the previous one.')
                for key in experiment_record.keys():
                    experiment_record[key].pop()
                s_contrast, s_size, s_color, s_pers, s_ecc, c_size, c_color = setting_list[index]
                experiment_json_dict[
                    f'SCT_{s_contrast}_SS_{s_size}_SCR_{s_color}_SP_{s_pers}_SE_{s_ecc}_CS_{c_size}_CC_{c_color}'].pop()

            else:  # 否则这个observer_choice就是对应的Color
                print('Repeat_ID:', re_i, 'Observer_CFF_value:', observer_choice)
                experiment_record['Block_ID'].append(index)
                experiment_record['Stimulus_Contrast'].append(s_contrast)
                experiment_record['Stimulus_Size'].append(s_size)
                experiment_record['Stimulus_Color'].append(s_color)
                experiment_record['Stimulus_Persistence'].append(s_pers)
                experiment_record['Stimulus_Eccentricity'].append(s_ecc)
                experiment_record['Center_point_size'].append(c_size)
                experiment_record['Center_point_color'].append(c_color)
                experiment_record['Repeat_ID'].append(re_i)
                experiment_record['CFF'].append(observer_choice)
                experiment_json_dict[file_name].append(observer_choice)
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
    stimulus_params = {
        'Contrast': [0.5, 1],
        'Size': [1, 4],
        'Color': [0.2, 0.5],
        'Persistence': [0.1, 0.5],
        'Repeat_times': 2,
        'Eccentricity': [0, 5, 10, 15, 20],
    }
    center_point_params = {
        'Size': [0.1, 1],
        'Color': [0.1, 1],
    }
    observer_params = {
        'name': 'Yancheng_Cai',
        'age': 23,
        'gender': 'M',
    }
    print(stimulus_params)
    print(center_point_params)
    save_base_path = r'Result_MOA_disk_eccentricity_CFF_1/'
    save_path = os.path.join(save_base_path, f"Observer_{observer_params['name']}")
    os.makedirs(save_path, exist_ok=True)
    config_json = {'stimulus_params': stimulus_params,
                   'center_point_params': center_point_params,
                   'observer_params': observer_params, }
    with open(os.path.join(save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    CFF_exp_main(stimulus_params=stimulus_params,
                 center_point_params=center_point_params,
                 save_path=save_path,
                 random_shuffle=True,
                 continue_exp=True)
