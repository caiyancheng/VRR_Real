# 这段代码与3相比，重点关注VRR_Frequency/Size/Luminance单独的影响，受众就是Yancheng Cai
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
from psychopy import data


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
            return -1
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
        # if keyboard.is_pressed("Backspace"):
        #     return -2
        glfw.poll_events()

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    all_begin_time = time.perf_counter()
    VRR_Begin = False
    while not glfw.window_should_close(window):
        frame_begin_time = time.perf_counter()
        display_t = frame_begin_time - all_begin_time
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
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
            return -1
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

def vrr_exp_main(change_parameters, vrr_params, signal_params, save_path, MOA_save_path, random_shuffle):
    # MOA will provide the initial color value
    with open(MOA_save_path, 'r')as fp:
        MOA_result_dict = json.load(fp)
    experiment_record = {'Block_ID': [], 'VRR_Frequency': [], 'Size_Degree': [], 'Threshold_Color_Value': [],
                         'Trail_ID': [], 'Real_VRR_period': [], 'Observer_choice': [], 'Response': []} # Real_VRR_period == Observer_choice --> Response = 1
    final_result_json_dict = {}
    glfw, window = start_opengl()
    setting_list = []
    for vrr_f in change_parameters['VRR_Frequency']:
        for size in change_parameters['Size']:
            setting_params = vrr_f, size
            setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)

    index = 0
    while index < len(setting_list):
        setting_params = setting_list[index]
        vrr_f, size = setting_params
        print('VRR_Frequency', vrr_f, 'Size', size)
        MOA_result = np.array(MOA_result_dict[f'V_{vrr_f}_S_{size}'])
        MOA_mean = MOA_result.mean()
        MOA_std = MOA_result.std() * change_parameters['STD_multiple']
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
        interval_time = 1 / (2 * vrr_f)

        quest_color_data = data.QuestHandler(startVal=-MOA_mean, startValSd=MOA_std, pThreshold=0.75, beta=3.5,
                                             gamma=0.5, delta=0.01, nTrials=change_parameters['Trail_Number'])

        for quest_trail_index in range(change_parameters['Trail_Number']):  # 这里的50是你想运行Quest的次数
            next_color = -quest_color_data.next()
            if next_color < 0.01:
                next_color = 0.01
            vrr_color = [next_color, next_color, next_color]
            random_vrr_period = random.randint(0, 1)  # 0代表第一段闪烁，1代表第二段闪烁
            c_params = x_center, y_center, x_scale, y_scale, interval_time, vrr_color
            observer_choice = vrr_one_block(glfw=glfw,
                                            window=window,
                                            vrr_params=vrr_params,
                                            signal_params=signal_params,
                                            random_vrr_period=random_vrr_period,
                                            c_params=c_params)
            # observer_choice = 1

            if observer_choice == -1:
                break
            # elif observer_choice == -2:
            #     index = index - 1
            #     winsound.Beep(10000, 100)
            #     print('Something Wrong! Return to the previous one.')
            #     for key in experiment_record.keys():
            #         experiment_record[key].pop()
            else:
                if observer_choice == random_vrr_period:
                    response = 1
                else:
                    response = 0
                quest_color_data.addResponse(response, -next_color)
                print('Ground Truth is', random_vrr_period, 'Observer Choice is', observer_choice)
                experiment_record['Block_ID'].append(index)
                experiment_record['VRR_Frequency'].append(vrr_f)
                experiment_record['Size_Degree'].append(size)
                experiment_record['Threshold_Color_Value'].append(next_color)
                experiment_record['Trail_ID'].append(quest_trail_index)
                experiment_record['Real_VRR_period'].append(random_vrr_period)
                experiment_record['Observer_choice'].append(observer_choice)
                experiment_record['Response'].append(response)
        final_result_json_dict[f'V_{vrr_f}_S_{size}'] = {
            'Mean': -quest_color_data.mean(),
            'Mode': -quest_color_data.mode(),
            'Quantile': -quest_color_data.quantile(),
            'Quantile_05': -quest_color_data.quantile(0.5)
        }
        index = index + 1

    glfw.terminate()
    df = pd.DataFrame(experiment_record)
    df.to_csv(os.path.join(save_path, 'result.csv'), index=False)
    with open(os.path.join(save_path, 'final_result.json'), 'w') as fp:
        json.dump(final_result_json_dict, fp)



if __name__ == "__main__":
    # 这段代码即为完整代码
    change_parameters = {
        'VRR_Frequency': [0.5, 1, 2, 4, 8, 16],
        'Color_Value_adjust_range': [0, 1],
        'Size': [1, 16, 'full'],
        'Trail_Number': 30,
        'STD_multiple': 10,
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    signal_params = {
        'signal_1_color': [0.01, 0.01, 0.01],
        'signal_2_color': [0.01, 0.01, 0.01],
        'signal_time': 0.2,
    }
    observer_params = {
        'name': 'Yancheng_Cai_Test_10',
        'age': 22,
        'gender': 'M',
    }
    print(change_parameters)
    save_base_path = r'../VRR_Subjective_Quest/Result_Quest_3/'
    save_path = os.path.join(save_base_path, f"Observer_{observer_params['name']}")
    MOA_save_path = os.path.join(r'../VRR_Subjective_MOA/Result_MOA_1/', f"Observer_{observer_params['name']}", 'result.json')
    os.makedirs(save_path, exist_ok=True)
    config_json = {'change_parameters': change_parameters,
                   'vrr_params': vrr_params,
                   'signal_params': signal_params,
                   'observer_params': observer_params,}
    with open(os.path.join(save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    vrr_exp_main(change_parameters=change_parameters,
                 vrr_params=vrr_params,
                 signal_params=signal_params,
                 save_path=save_path,
                 MOA_save_path=MOA_save_path,
                 random_shuffle=True)