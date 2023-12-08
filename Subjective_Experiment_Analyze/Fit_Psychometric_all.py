# 对subjective experiment 做出分析
import json
import warnings

import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from scipy.stats import binom
from Computational_Model.Fit_Psychometric_function_simple import *
from Computational_Model.Compute_C_t_P import *

# 应该对每个setting， 每个不同人做拟合
def find_value(new_y_values, value):
    differences = np.abs(new_y_values - value)
    index = np.argmin(differences)
    return index

exp_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1'
exp_path_list = os.listdir(exp_base_path)
df_dict = {}
for exp_path in exp_path_list:
    df = pd.read_csv(os.path.join(exp_base_path, exp_path, 'result.csv'))
    df_dict[exp_path] = df
obs_list = list(df_dict.keys())
num_obs = len(obs_list)

# 与照明相关的准确率变化
luminance_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['Luminance'].unique()
size_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['Size_Degree'].unique()
vrr_f_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['VRR_Frequency'].unique()

# c_array = np.zeros(shape=(len(luminance_values), len(size_values), len(vrr_f_values), len(df_dict.keys())))
# prob_array = np.zeros(shape=(len(luminance_values), len(size_values), len(vrr_f_values), len(df_dict.keys())))
mu_csv_dict = {'Luminance': [],'Size_Degree': [],'VRR_Frequency': [], 'Observer': [], 'C_t': []}
# mu_array_fit = np.zeros(shape=(len(luminance_values), len(size_values), len(vrr_f_values), len(df_dict.keys())))

skip_num = 0
with open(r'E:\Py_codes\VRR_Real\Computational_Model/C_1_array.json', 'r') as fp:
    C_1_array = np.array(json.load(fp))

for luminance_index in range(len(luminance_values)):
    for size_index in range(len(size_values)):
        for vrr_f_index in range(len(vrr_f_values)):
            for obs_index in range(len(obs_list)):
                obs = obs_list[obs_index]
                obs_df = df_dict[obs]
                sub_df = obs_df[(obs_df['Luminance'] == luminance_values[luminance_index]) &
                                (obs_df['Size_Degree'] == size_values[size_index]) &
                                (obs_df['VRR_Frequency'] == vrr_f_values[vrr_f_index])]
                accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
                c = C_1_array[luminance_index][size_index][vrr_f_index]

                mu_csv_dict['Luminance'].append(luminance_values[luminance_index])
                mu_csv_dict['Size_Degree'].append(size_values[size_index])
                mu_csv_dict['VRR_Frequency'].append(vrr_f_values[vrr_f_index])
                mu_csv_dict['Observer'].append(obs)
                if accuracy <= 0.5 or accuracy >= 1:
                    skip_num += 1
                    mu_csv_dict['C_t'].append(np.nan)
                    continue
                mu = invert_pf_inc_exp(intensity=c, P=accuracy, beta=3.5, target_p=0.75, guess_p=0.5)
                predict_p = pf_inc_exp(intensity=c, mu=mu, beta=3.5, target_p=0.75, guess_p=0.5)
                if np.abs(predict_p - accuracy) > 0.001:
                    warnings.warn('Wrong Prediction!')
                    print('Loss', np.abs(predict_p - accuracy))
                mu_csv_dict['C_t'].append(mu)

print(f'Skip {skip_num} points because the prob is smaller than 0.5 or larger than 1')
mu_csv_df = pd.DataFrame(mu_csv_dict)
mu_csv_file_path = r'E:\Py_codes\VRR_Real\Computational_Model\mu_results.csv'
mu_csv_df.to_csv(mu_csv_file_path, index=False)




