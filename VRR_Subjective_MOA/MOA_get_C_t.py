import pandas as pd
import os
import json
import numpy as np

exp_path = 'Result_MOA_3'

with open(r'B:\Py_codes\VRR_Real\dL_L/KONICA_Fit_result_sigmoid.json', 'r') as fp: #dl/L
    fit_result = json.load(fp)
def sigmoid(x, k, x0):
    return 1 / (1 + np.exp(-k * (x - x0)))
def L_to_C_t(Luminance, popt):
    C_t = sigmoid(np.log10(Luminance), *popt)
    return C_t

degree = 4 #degree的意思是这到底是几次函数拟合的
with open(f'..\G1_Calibration/KONICA_Color_Luminance_Fit_result_poly_{degree}.json', 'r') as fp:
    fit_set = json.load(fp)
def color_to_L(coefficients, color):
    luminance = 10**np.polyval(coefficients, color)
    return luminance

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_duration_1\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr.csv')) #这里是一堆Color Value

Quest_Durations = Quest_config['change_parameters']['Duration']
Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
C_t_result_csv = {}
C_t_result_csv['Duration'] = []
C_t_result_csv['Size_Degree'] = []
C_t_result_csv['VRR_Frequency'] = []
C_t_result_csv['Luminance'] = []
C_t_result_csv['C_t'] = []

for duration_index in range(len(Quest_Durations)):
    duration_value = Quest_Durations[duration_index]
    for vrr_f_index in range(len(Quest_VRR_Fs)):
        vrr_f_value = Quest_VRR_Fs[vrr_f_index]
        size_value = 16
        filtered_df = df[(df['Duration'] == duration_value) & (df['VRR_Frequency'] == vrr_f_value)]
        Color_value = filtered_df['threshold'].item()
        if np.isnan(Color_value):
            print('Invalid')
            continue
        # if Color_value < 0.04:
        #     Color_value = 0.04
        coefficients = fit_set[f'size_{size_value}']['coefficients']
        popt = fit_result[f'size_{size_value}']['popt']
        if size_value != 'full':
            size_value_new = float(size_value)
            C_t_result_csv['Size_Degree'].append(size_value)
        else:
            size_value_new = 'full'
            C_t_result_csv['Size_Degree'].append(-1) #-1 means full
        Luminance = color_to_L(coefficients=coefficients, color=Color_value)
        C_t_result_csv['Duration'].append(duration_value)
        C_t_result_csv['VRR_Frequency'].append(vrr_f_value)
        C_t_result_csv['Luminance'].append(Luminance)
        C_t = L_to_C_t(Luminance = Luminance, popt = popt)
        C_t_result_csv['C_t'].append(C_t)
df = pd.DataFrame(C_t_result_csv)
df.to_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr_C_t.csv'), index=False)