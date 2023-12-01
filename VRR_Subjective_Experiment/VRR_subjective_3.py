# 这段代码与2相比，加入了声音作为提示
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
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter() + sleep_time
    while time.perf_counter() < end_time:
        pass
def start_opengl():
    global center_point_size_y
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
    glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    glfw.show_window(window)
    return glfw, window

def vrr_one_block(glfw, window, vrr_params, signal_params, random_vrr_period, c_params):
    x_center, y_center, x_scale, y_scale, interval_time, vrr_color = c_params
    center_point_color = np.array(vrr_color) * 2
    winsound.Beep(6000, 100)  # Begin
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        glColor3f(vrr_color[0], vrr_color[1], vrr_color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        glBegin(GL_QUADS)
        glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        glEnd()

        glfw.swap_buffers(window)
        if keyboard.is_pressed("enter"):
            break
        if keyboard.is_pressed("Backspace"):
            return 2
        glfw.poll_events()

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    VRR_Begin = False
    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        display_t = frame_begin_time - all_begin_time
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        if display_t < signal_params['signal_time']: #第一个红色signal
            color = signal_params['signal_1_color']
            frame_rate = vrr_params['fix_frame_rate']
        elif display_t < signal_params['signal_time'] + vrr_params['vrr_total_time']: #第一个展示片段
            color = vrr_color
            if random_vrr_period == 0: #VRR
                if not VRR_Begin:
                    begin_vrr_time = time.perf_counter()
                    VRR_Begin = True
                if time.perf_counter() - begin_vrr_time < interval_time:
                    frame_rate = vrr_params['frame_rate_min']
                elif time.perf_counter() - begin_vrr_time < interval_time * 2:
                    frame_rate = vrr_params['frame_rate_max']
                else:
                    begin_vrr_time = time.perf_counter()
                    frame_rate = vrr_params['frame_rate_max']
            else:
                frame_rate = vrr_params['fix_frame_rate']
        elif display_t < signal_params['signal_time'] * 2 + vrr_params['vrr_total_time']:
            color = signal_params['signal_2_color']
            frame_rate = vrr_params['fix_frame_rate']
        elif display_t < signal_params['signal_time'] * 2 + vrr_params['vrr_total_time'] * 2:
            color = vrr_color
            if random_vrr_period == 1:  # VRR
                if not VRR_Begin:
                    begin_vrr_time = time.perf_counter()
                    VRR_Begin = True
                if time.perf_counter() - begin_vrr_time < interval_time:
                    frame_rate = vrr_params['frame_rate_min']
                elif time.perf_counter() - begin_vrr_time < interval_time * 2:
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
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        glBegin(GL_QUADS)
        glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        glEnd()

        glfw.swap_buffers(window)

        end_time = time.perf_counter()
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()

    while not glfw.window_should_close(window): # Make Decision
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            break
        glColor3f(vrr_color[0], vrr_color[1], vrr_color[2])
        glBegin(GL_QUADS)
        glVertex2f(x_center - x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center - y_scale)
        glVertex2f(x_center + x_scale, y_center + y_scale)
        glVertex2f(x_center - x_scale, y_center + y_scale)
        glEnd()

        # glColor3f(center_point_color[0], center_point_color[1], center_point_color[2])
        # glBegin(GL_QUADS)
        # glVertex2f(x_center - center_point_size_x / 2, y_center - center_point_size_y / 2)
        # glVertex2f(x_center + center_point_size_x / 2, y_center - center_point_size_y / 2)
        # glVertex2f(x_center + center_point_size_x / 2, y_center + center_point_size_y / 2)
        # glVertex2f(x_center - center_point_size_x / 2, y_center + center_point_size_y / 2)
        # glEnd()

        glfw.swap_buffers(window)
        glfw.poll_events()
        if keyboard.is_pressed('1'):
            # winsound.Beep(4000, 100)
            return 0
        if keyboard.is_pressed('2'):
            # winsound.Beep(4000, 100)
            return 1


def vrr_exp_main(change_parameters, vrr_params, signal_params, save_path):
    with open('E:\Py_codes\VRR_Real\G1_Calibration\Official_Config\Aim_L_[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 50, 100]_Size_[4, 16]_Hot/result_dict.json', 'r') as fp:
        luminance_dict = json.load(fp)
    experiment_record = {'Block_ID': [], 'VRR_Frequency': [], 'Luminance': [], 'Size_Degree': [], 'Eccentricity': [],
                         'Repeat_ID': [], 'Real_VRR_period': [], 'Observer_choice': [], 'VRR_Color': []}
    glfw, window = start_opengl()
    setting_list = []
    for lum in change_parameters['Luminance']:
        for vrr_f in change_parameters['VRR_Frequency']:
            for size in change_parameters['Size']:
                for ecc in change_parameters['Eccentricity']:
                    for re_i in range(change_parameters['Repeat_times']):
                        setting_params = lum, vrr_f, size, ecc, re_i
                        setting_list.append(setting_params)

    index = 0
    while index < len(setting_list):
        setting_params = setting_list[index]
        lum, vrr_f, size, ecc, re_i = setting_params
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=ecc)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
        interval_time = 1 / (2 * vrr_f)
        color = luminance_dict[f'L_{lum}_S_{size}']
        vrr_color = [color, color, color]
        random_vrr_period = random.randint(0, 1)  # 0代表第一段闪烁，1代表第二段闪烁
        c_params = x_center, y_center, x_scale, y_scale, interval_time, vrr_color
        observer_choice = vrr_one_block(glfw=glfw,
                                        window=window,
                                        vrr_params=vrr_params,
                                        signal_params=signal_params,
                                        random_vrr_period=random_vrr_period,
                                        c_params=c_params)
        if observer_choice == 2:
            index = index - 1
            winsound.Beep(10000, 100)
            print('Something Wrong! Return to the previous one.')
            experiment_record['Block_ID'].pop()
            experiment_record['VRR_Frequency'].pop()
            experiment_record['Luminance'].pop()
            experiment_record['Size_Degree'].pop()
            experiment_record['Eccentricity'].pop()
            experiment_record['Repeat_ID'].pop()
            experiment_record['Real_VRR_period'].pop()
            experiment_record['Observer_choice'].pop()
            experiment_record['VRR_Color'].pop()
        else:
            print('Ground Truth is', random_vrr_period, 'Observer Choice is', observer_choice)
            experiment_record['Block_ID'].append(index)
            experiment_record['VRR_Frequency'].append(vrr_f)
            experiment_record['Luminance'].append(lum)
            experiment_record['Size_Degree'].append(size)
            experiment_record['Eccentricity'].append(ecc)
            experiment_record['Repeat_ID'].append(re_i)
            experiment_record['Real_VRR_period'].append(random_vrr_period)
            experiment_record['Observer_choice'].append(observer_choice)
            experiment_record['VRR_Color'].append(vrr_color)

            index = index + 1

    glfw.terminate()
    df = pd.DataFrame(experiment_record)
    df.to_csv(os.path.join(save_path, 'result.csv'), index=False)


if __name__ == "__main__":
    # 这段代码即为完整代码
    change_parameters = {
        'VRR_Frequency': [2, 5, 10],
        # 'Luminance': [1, 10],
        'Luminance': [1, 2, 3, 4, 5, 10, 100],
        'Size': [4, 16],
        # 'Size': [4],
        # 'Eccentricity': [0,15],
        'Eccentricity': [0] ,
        'Repeat_times': 10, #同一个setting重复多少遍
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    signal_params = {
        # 'signal_1_color': [0.1, 0.1, 0.1],
        # 'signal_2_color': [0.1, 0.1, 0.1],
        'signal_1_color': [0.01, 0.01, 0.01],
        'signal_2_color': [0.01, 0.01, 0.01],
        # 'signal_1_color': [0.1, 0., 0.],
        # 'signal_2_color': [0., 0.1, 0.],
        'signal_time': 0.2,
    }
    observer_params = {
        'name': 'Yancheng_Cai_Test_Repeat_10',
        'age': 22,
        'gender': 'M',
    }
    # observer_params = {
    #     'name': 'Yaru_Liu_Test_Repeat_10',
    #     'age': 26,
    #     'gender': 'F',
    # observer_params = {
    #     'name': 'Boyue_Zhang_Test_Repeat_10',
    #
    #     'age': 23,
    #     'gender': 'M',
    # }
    # observer_params = {
    #     'name': 'Rafal_Test_Repeat_1',
    #     'age': 45,
    #     'gender': 'M',
    # }
    print(change_parameters)
    save_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment/Result_VRR_3/'
    save_path = os.path.join(save_base_path, f"Observer_{observer_params['name']}")
    os.makedirs(save_path, exist_ok=True)
    config_json = {'change_parameters': change_parameters,
                   'vrr_params': vrr_params,
                   'signal_params': signal_params,
                   'observer_params': observer_params,}
    with open(os.path.join(save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    # random_vrr_period = random.randint(0, 1)
    # # random_vrr_period = 0
    # print(f'VRR will be shown on the {random_vrr_period + 1} period')
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params,
                 signal_params=signal_params,
                 save_path=save_path)