import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import json
import os
import pandas as pd

with open(r'B:\Py_codes\VRR_Real\dL_L/KONICA_Fit_result_sigmoid.json', 'r') as fp:
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

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_disk_3\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr.csv')) #这里是一堆Color Value

Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']

C_t_result_csv = {}
C_t_result_csv['Size_Degree'] = []
C_t_result_csv['VRR_Frequency'] = []
C_t_result_csv['Luminance'] = []
C_t_result_csv['Luminance_high'] = []
C_t_result_csv['Luminance_low'] = []
C_t_result_csv['C_t'] = []
C_t_result_csv['C_t_high'] = []
C_t_result_csv['C_t_low'] = []

for vrr_f_index in range(len(Quest_VRR_Fs)):
    vrr_f_value = Quest_VRR_Fs[vrr_f_index]
    for size_index in range(len(Quest_Sizes)):
        size_value = Quest_Sizes[size_index]
        filtered_df = df[(df['Size_Degree'] == str(size_value)) & (df['VRR_Frequency'] == vrr_f_value)]
        Color_value = filtered_df['threshold'].item()
        Color_value_low = filtered_df['threshold_ci_low'].item()
        Color_value_high = filtered_df['threshold_ci_high'].item()
        if np.isnan(Color_value):
            print('Invalid')
            continue
        coefficients = fit_set[f'size_{size_value}']['coefficients']
        popt = fit_result[f'size_{size_value}']['popt']
        if np.isnan(Color_value):
            continue
        if size_value != 'full':
            size_value_new = float(size_value)
            C_t_result_csv['Size_Degree'].append(size_value)
        else:
            size_value_new = 'full'
            C_t_result_csv['Size_Degree'].append(-1) #-1 means full
        Luminance = color_to_L(coefficients=coefficients, color=Color_value)
        Luminance_high = color_to_L(coefficients=coefficients, color=Color_value_high)
        Luminance_low = color_to_L(coefficients=coefficients, color=Color_value_low)
        C_t = L_to_C_t(Luminance = Luminance, popt = popt)
        C_t_low = L_to_C_t(Luminance=Luminance_high, popt=popt)
        C_t_high = L_to_C_t(Luminance=Luminance_low, popt=popt)

        C_t_result_csv['VRR_Frequency'].append(vrr_f_value)
        C_t_result_csv['Luminance'].append(Luminance)
        C_t_result_csv['Luminance_high'].append(Luminance_high)
        C_t_result_csv['Luminance_low'].append(Luminance_low)
        C_t_result_csv['C_t'].append(C_t)
        C_t_result_csv['C_t_high'].append(C_t_high)
        C_t_result_csv['C_t_low'].append(C_t_low)
df = pd.DataFrame(C_t_result_csv)
df.to_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr_C_t.csv'), index=False)
