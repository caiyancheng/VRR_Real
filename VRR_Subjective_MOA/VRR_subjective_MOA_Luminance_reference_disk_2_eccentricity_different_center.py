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

def vrr_one_block_disk(glfw, window, vrr_params, c_params):
    global screen_width, screen_height
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range, cs_x_scale, cs_y_scale, c_color = c_params
    num_segments = 100
    while not glfw.window_should_close(window):
        glClear(GL_COLOR_BUFFER_BIT)
        if glfw.get_key(window, glfw.KEY_ESCAPE) == glfw.PRESS:
            return -1
        glColor3f(initial_color, initial_color, initial_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)

        glEnd()

        glColor3f(c_color, c_color, c_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
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
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(x_center, y_center)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
            x = x_center + x_scale * math.cos(theta)
            y = y_center + y_scale * math.sin(theta)
            glVertex2f(x, y)

        glEnd()

        glColor3f(c_color, c_color, c_color)
        glBegin(GL_TRIANGLE_FAN)
        glVertex2f(0, 0)
        for i in range(num_segments + 1):
            theta = i * (2.0 * math.pi / num_segments)
            x = cs_x_scale * math.cos(theta)
            y = cs_y_scale * math.sin(theta)
            glVertex2f(x, y)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns()/1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_exp_main(change_parameters, center_point_params, vrr_params, save_path, random_shuffle, continue_exp):
    #如果是连续调节，其实都不需要预先校准了，直接在最后得出pixel value进行一个校准就可以了
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
        experiment_record = {'Block_ID': [], 'VRR_Frequency': [], 'Size_Degree': [],
                             'Eccentricity': [], 'Observer_color_value': [],
                             'Repeat_ID': []}
        experiment_json_dict = {}
    glfw, window = start_opengl()
    setting_list = []
    for vrr_f in change_parameters['VRR_Frequency']:
        for size in change_parameters['Size']:
            for ecc in change_parameters['Eccentricity']:
                for c_size in center_point_params['size_list']:
                    for c_color in center_point_params['color_list']:
                        setting_params = vrr_f, size, ecc, c_size, c_color
                        setting_list.append(setting_params)

    for re_i in range(change_parameters['Repeat_times']):
        if random_shuffle:
            random.shuffle(setting_list)
        index = 0
        while index < len(setting_list):
            setting_params = setting_list[index]
            vrr_f, size, ecc, c_size, c_color = setting_params
            print('VRR_Frequency', vrr_f, 'Size', size, 'Eccentricity', ecc, 'Center_point_size', c_size, 'Center_point_color', c_color)
            if continue_exp and f'V_{vrr_f}_S_{size}_E_{ecc}_CS_{c_size}_CC_{c_color}' in experiment_json_dict.keys():
                print('Jump')
                index = index + 1
                continue
            experiment_json_dict[f'V_{vrr_f}_S_{size}_E_{ecc}_CS_{c_size}_CC_{c_color}'] = []
            x_center, y_center = compute_x_y_from_eccentricity(eccentricity=ecc)
            x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
            cs_x_scale, cs_y_scale = compute_scale_from_degree(visual_degree=c_size)
            interval_time = 1 / (2 * vrr_f)
            initial_color = random.uniform(0, 0.3)
            color_range = change_parameters['Color_Value_adjust_range']
            c_params = x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range, cs_x_scale, cs_y_scale, c_color
            if size == 'full' or size > 10:
                raise ValueError('In the Eccentricity Experiment the Stimulus Size could not be too large.')
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
                vrr_f, size, _ = setting_list[index]
                experiment_json_dict[f'V_{vrr_f}_S_{size}_E_{ecc}'].pop()

            else:  # 否则这个observer_choice就是对应的Color
                print('VRR_Frequency:', vrr_f, 'Size_Degree:', size, 'Eccentricity', ecc, 'Repeat_ID:', re_i, 'Observer_color_value:', observer_choice)
                experiment_record['Block_ID'].append(index)
                experiment_record['VRR_Frequency'].append(vrr_f)
                experiment_record['Observer_color_value'].append(observer_choice)
                experiment_record['Size_Degree'].append(size)
                experiment_record['Eccentricity'].append(ecc)
                experiment_record['Repeat_ID'].append(re_i)
                experiment_json_dict[f'V_{vrr_f}_S_{size}_E_{ecc}'].append(observer_choice)
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
        'Color_Value_adjust_range': [0, 0.2],
        'Size': [4],
        'Repeat_times': 3,
        'Eccentricity': [0, 5, 10, 15, 20],
    }
    center_point_params = {
        'size_list': [0.01, 0.1, 1],
        'color_list': [0, 0.2, 0.5],
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    observer_params = {
        'name': 'Yancheng_Cai_2',
        'age': 23,
        'gender': 'M',
    }
    print(change_parameters)
    save_base_path = r'../VRR_Subjective_MOA/Result_MOA_disk_eccentricity_different_center_1/'
    save_path = os.path.join(save_base_path, f"Observer_{observer_params['name']}")
    os.makedirs(save_path, exist_ok=True)
    config_json = {'change_parameters': change_parameters,
                   'center_point_params': center_point_params,
                   'vrr_params': vrr_params,
                   'observer_params': observer_params,}
    with open(os.path.join(save_path, 'config.json'), 'w') as fp:
        json.dump(config_json, fp)
    vrr_exp_main(change_parameters=change_parameters,
                 center_point_params=center_point_params,
                 vrr_params=vrr_params,
                 save_path=save_path,
                 random_shuffle=True,
                 continue_exp=False)