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
from G1_Calibration.compute_size_real import compute_scale_from_degree
from G1_Calibration.compute_x_y_location import compute_x_y_from_eccentricity

center_point_size_x = 0.002  # Adjust the size of the center white point as needed
# center_point_color = [1.0, 1.0, 1.0]
center_point_size_y = 0.

def microsecond_sleep(sleep_time):
    end_time = time.perf_counter_ns() / 1e9 + sleep_time
    while time.perf_counter_ns() / 1e9 < end_time:
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

def vrr_one_block(glfw, window, vrr_params, c_params):
    winsound.Beep(4000, 100)
    x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range = c_params
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

        glColor3f(initial_color*2, initial_color*2, initial_color*2)
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
            return -2
        glfw.poll_events()
    winsound.Beep(4000, 100)

    # glfw.set_input_mode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
    begin_vrr_time = time.perf_counter_ns()/1e9
    color = initial_color
    while not glfw.window_should_close(window):
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

        if keyboard.is_pressed("Y"):
            return color
        elif keyboard.is_pressed("W"):
            color = color + 0.02
        elif keyboard.is_pressed("S"):
            color = color - 0.02
        elif keyboard.is_pressed("up") or keyboard.is_pressed("up arrow"):
            color = color + 0.0005
        elif keyboard.is_pressed("down") or keyboard.is_pressed("down arrow"):
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

        glColor3f(color*2, color*2, color*2)
        glBegin(GL_QUADS)
        glVertex2f(0 - center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 - center_point_size_y / 2)
        glVertex2f(0 + center_point_size_x / 2, 0 + center_point_size_y / 2)
        glVertex2f(0 - center_point_size_x / 2, 0 + center_point_size_y / 2)
        glEnd()

        glfw.swap_buffers(window)
        end_time = time.perf_counter_ns()/1e9
        sleep_time = (1.0 / frame_rate - (end_time - frame_begin_time))
        microsecond_sleep(sleep_time)
        glfw.poll_events()


def vrr_exp_main(change_parameters, vrr_params, save_path, random_shuffle):
    #如果是连续调节，其实都不需要预先校准了，直接在最后得出pixel value进行一个校准就可以了
    experiment_record = {'Block_ID': [], 'VRR_Frequency': [], 'Observer_color_value': [],
                         'Size_Degree': [], 'Repeat_ID': []}
    experiment_json_dict = {}
    glfw, window = start_opengl()
    setting_list = []
    for vrr_f in change_parameters['VRR_Frequency']:
        for size in change_parameters['Size']:
            experiment_json_dict[f'V_{vrr_f}_S_{size}'] = []
            for re_i in range(change_parameters['Repeat_times']):
                setting_params = vrr_f, size, re_i
                setting_list.append(setting_params)
    if random_shuffle:
        random.shuffle(setting_list)

    index = 0
    while index < len(setting_list):
        setting_params = setting_list[index]
        vrr_f, size, re_i = setting_params
        x_center, y_center = compute_x_y_from_eccentricity(eccentricity=0)
        x_scale, y_scale = compute_scale_from_degree(visual_degree=size)
        interval_time = 1 / (2 * vrr_f)
        initial_color = 0.5
        color_range = change_parameters['Color_Value_adjust_range']
        c_params = x_center, y_center, x_scale, y_scale, interval_time, initial_color, color_range
        observer_choice = vrr_one_block(glfw=glfw,
                                        window=window,
                                        vrr_params=vrr_params,
                                        c_params=c_params)
        if observer_choice == -1: #-1代表想要退出
            break
        elif observer_choice == -2: #-2代表认为前一个出现了错误，希望重来
            index = index - 1
            winsound.Beep(8000, 100)
            print('Something Wrong! Return to the previous one.')
            for key in experiment_record.keys():
                experiment_record[key].pop()
            vrr_f, size, _ = setting_list[index]
            experiment_json_dict[f'V_{vrr_f}_S_{size}'].pop()

        else: #否则这个observer_choice就是对应的Color
            print('Observer Choice is', observer_choice)
            experiment_record['Block_ID'].append(index)
            experiment_record['VRR_Frequency'].append(vrr_f)
            experiment_record['Observer_color_value'].append(observer_choice)
            experiment_record['Size_Degree'].append(size)
            experiment_record['Repeat_ID'].append(re_i)
            experiment_json_dict[f'V_{vrr_f}_S_{size}'].append(observer_choice)
            index = index + 1

    glfw.terminate()
    df = pd.DataFrame(experiment_record)
    df.to_csv(os.path.join(save_path, 'result.csv'), index=False)
    with open(os.path.join(save_path, 'result.json'), 'w') as fp:
        json.dump(experiment_json_dict, fp)


if __name__ == "__main__":
    # 这段代码即为完整代码
    change_parameters = {
        'VRR_Frequency': [0.5, 1, 2, 4, 8, 16],
        'Color_Value_adjust_range': [0, 1],
        'Size': [1, 16, 'full'],
        'Repeat_times': 1,
    }
    vrr_params = {
        'frame_rate_min': 30,
        'frame_rate_max': 120,
        'vrr_total_time': 2,
        'fix_frame_rate': 60,
    }
    observer_params = {
        'name': 'Yancheng_Cai_Test_1',
        'age': 22,
        'gender': 'M',
    }
    print(change_parameters)
    save_base_path = r'../VRR_Subjective_MOA/Result_MOA_1/'
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