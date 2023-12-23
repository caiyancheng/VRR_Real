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

# plt.figure()
# Luminance_array = np.arange(0.01,10,0.01)
# C_t = L_to_C_t(Luminance_array)
# plt.plot(np.log10(Luminance_array), C_t)
# plt.show()

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_4\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr.csv')) #这里是一堆Color Value
with open(os.path.join(Quest_exp_path, 'color2luminance.json'), 'r') as fp:
    color2luminance = json.load(fp)

Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']

C_t_result_csv = {}
C_t_result_csv['Size_Degree'] = []
C_t_result_csv['VRR_Frequency'] = []
C_t_result_csv['Luminance'] = []
C_t_result_csv['C_t'] = []

for vrr_f_index in range(len(Quest_VRR_Fs)):
    vrr_f_value = Quest_VRR_Fs[vrr_f_index]
    if vrr_f_value == 16:
        continue
    for size_index in range(len(Quest_Sizes)):
        size_value = Quest_Sizes[size_index]
        filtered_df = df[(df['Size_Degree'] == str(size_value)) & (df['VRR_Frequency'] == vrr_f_value)]
        Color_value = filtered_df['threshold'].item()
        popt = fit_result[f'size_{size_value}']['popt']
        if np.isnan(Color_value):
            continue
        if size_value != 'full':
            size_value_new = float(size_value)
            C_t_result_csv['Size_Degree'].append(size_value)
        else:
            size_value_new = 'full'
            C_t_result_csv['Size_Degree'].append(-1) #-1 means full
        Luminance = color2luminance[f'S_{size_value_new}_C_{Color_value}'][0]
        C_t = L_to_C_t(Luminance = Luminance, popt = popt)
        C_t_result_csv['VRR_Frequency'].append(vrr_f_value)
        C_t_result_csv['Luminance'].append(Luminance)
        C_t_result_csv['C_t'].append(C_t)
df = pd.DataFrame(C_t_result_csv)
df.to_csv(os.path.join(Quest_exp_path, 'reorder_result_D_thr_C_t.csv'), index=False)
