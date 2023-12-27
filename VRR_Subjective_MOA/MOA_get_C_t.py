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
# with open(f'..\G1_Calibration/KONICA_Color_Luminance_Fit_result_poly_{degree}.json', 'r') as fp:
#     fit_set = json.load(fp)
with open(f'..\dL_L/KONICA_Lmean_Color_Fit_result_poly_{degree}.json', 'r') as fp:
    fit_set = json.load(fp)
def color_to_L(coefficients, color):
    luminance = 10**np.polyval(coefficients, color)
    return luminance

MOA_exp_path = r'..\VRR_Subjective_MOA/Result_MOA_3/Observer_Rafal_2'
with open(os.path.join(MOA_exp_path, 'config.json'), 'r') as fp:
    MOA_config = json.load(fp)
with open(os.path.join(MOA_exp_path, 'result.json'), 'r') as fp:
    MOA_result = json.load(fp)

MOA_Sizes = MOA_config['change_parameters']['Size']
MOA_VRR_Fs = MOA_config['change_parameters']['VRR_Frequency']
C_t_result_json = {}

for size_index in range(len(MOA_Sizes)):
    size_value = MOA_Sizes[size_index]
    for vrr_f_index in range(len(MOA_VRR_Fs)):
        vrr_f_value = MOA_VRR_Fs[vrr_f_index]
        color_value_list = MOA_result[f'V_{vrr_f_value}_S_{size_value}']
        color_value = np.array(color_value_list).mean()
        # if Color_value < 0.04:
        #     Color_value = 0.04
        coefficients = fit_set[f'size_{size_value}']['coefficients']
        popt = fit_result[f'size_{size_value}']['popt']
        Luminance = color_to_L(coefficients=coefficients, color=color_value)
        C_t = L_to_C_t(Luminance=Luminance, popt=popt)
        C_t_result_json[f'V_{vrr_f_value}_S_{size_value}'] = {
            'Luminance': Luminance,
            'C_t': C_t,
        }

with open(os.path.join(MOA_exp_path, 'result_MOA_C_t.json'), 'w') as fp:
    json.dump(C_t_result_json, fp=fp)