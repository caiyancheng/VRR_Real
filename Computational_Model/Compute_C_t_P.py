import numpy as np
import matplotlib.pyplot as plt
import os
import json
from tqdm import tqdm
import pandas as pd

from Computational_Model.FFT import compute_signal_FFT
from Computational_Model.Fit_Psychometric_function_simple import pf_dec_exp

# we only focus on the peak on VRR Frequency
# C_T_1 = delta L / L_0
# C_T_2 = 1 / S

def find_nearest_index(array, value):
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx

def compute_C_T_1(luminance_index, size_index, vrr_f_index):
    # delta L / L_0
    exp_log_path = r'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1'
    repeat_indexs = range(10)
    C_T_1_array = np.zeros(len(repeat_indexs))
    for repeat_index in repeat_indexs:
        file_name = os.path.join(exp_log_path,
                                 f'Luminance_{luminance_index}_Size_{size_index}_VRR_Frequency_{vrr_f_index}',
                                 f'{repeat_index}.json')
        with open(file_name, 'r') as fp:
            exp_data = json.load(fp)
        x_time_array = np.array(exp_data['x_time'])
        y_luminance_array = np.array(exp_data['y_luminance_scale'])
        plt.figure()
        plt.plot(x_time_array, y_luminance_array)
        plt.xlim(0,0.2)
        plt.show()
        x_freq_sub, K_FFT_sub = compute_signal_FFT(x_time_array=x_time_array, y_luminance_array=y_luminance_array,
                                                   frequency_upper=120, plot_FFT=True, skip_0=False, force_equal=True)
        nearest_index = find_nearest_index(x_freq_sub, vrr_f_index)
        delta_L = K_FFT_sub[nearest_index]
        C_T_1_array[repeat_index] = delta_L / luminance_index
    return C_T_1_array.mean()

def compute_C_T_2(luminance_index, size_index, vrr_f_index):
    # 1 / S
    exp_log_path = r'E:\Py_codes\VRR_Real\stelaCSF_matlab/sensitivity_results.csv'
    df = pd.read_csv(exp_log_path)
    repeat_indexs = range(10)
    C_T_2_array = np.zeros(len(repeat_indexs))
    for repeat_index in repeat_indexs:
        result = df.loc[(df['Luminance'] == luminance_index) &
                        (df['Size'] == size_index) &
                        (df['VRR_f'] == vrr_f_index) &
                        (df['Repeat'] == repeat_index), 'S_VRR']
        C_T_2_array[repeat_index] = 1 / result.item()
    return C_T_2_array.mean()

def compute_C_T_1_2_all():
    luminance_list = [1, 2, 3, 4, 5, 10, 100]
    size_list = [4, 16]
    vrr_f_list = [2, 5, 10]
    C_1_array = np.zeros((len(luminance_list), len(size_list), len(vrr_f_list)))
    C_2_array = np.zeros((len(luminance_list), len(size_list), len(vrr_f_list)))
    for luminance_i in tqdm(range(len(luminance_list))):
        luminance_index = luminance_list[luminance_i]
        for size_i in range(len(size_list)):
            size_index = size_list[size_i]
            for vrr_f_i in range(len(vrr_f_list)):
                vrr_f_index = vrr_f_list[vrr_f_i]
                C_1_array[luminance_i, size_i, vrr_f_i] = compute_C_T_1(luminance_index, size_index, vrr_f_index)
                C_2_array[luminance_i, size_i, vrr_f_i] = compute_C_T_2(luminance_index, size_index, vrr_f_index)
    return C_1_array, C_2_array


if __name__ == '__main__':
    C_1_array, C_2_array = compute_C_T_1_2_all()
    with open(r'E:\Py_codes\VRR_Real\Computational_Model/C_1_array.json', 'w') as fp:
        json.dump(C_1_array.tolist(), fp)
    with open(r'E:\Py_codes\VRR_Real\Computational_Model/C_2_array.json', 'w') as fp:
        json.dump(C_2_array.tolist(), fp)