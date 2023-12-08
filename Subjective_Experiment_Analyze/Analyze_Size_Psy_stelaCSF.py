# 对subjective experiment 做出分析
import json

import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from scipy.stats import binom
from Computational_Model.Fit_Psychometric_function_simple import *
from Computational_Model.Compute_C_t_P import *

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

accuracy_array = np.zeros(shape=(len(size_values), len(df_dict.keys())))
for size_index in range(len(size_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][df_dict[obs]['Size_Degree'] == size_values[size_index]]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[size_index][obs_index] = accuracy

with open(r'E:\Py_codes\VRR_Real\Computational_Model/C_2_array.json', 'r') as fp:
    C_2_array = np.array(json.load(fp))

P_CSF_size = np.zeros(len(size_values))
for size_i in range(len(size_values)):
    sub_C_2_array = C_2_array[:,size_i,:]
    C_2_array_size_flat = sub_C_2_array.reshape(-1)
    P_CSF_size_i = compute_P_from_C_T(C_T=C_2_array_size_flat, mu=0.003937395993406365)
    P_CSF_size[size_i] = np.mean(P_CSF_size_i)

mean_array = np.mean(accuracy_array, axis=1)
std_dev_array = np.std(accuracy_array, axis=1)
N = len(df) * num_obs / len(size_values)
bino_error_bar = np.zeros(shape=(len(size_values),2))
for size_index in range(len(size_values)):
    bino_error_bar[size_index] = binom.ppf([0.005, 0.995], N, mean_array[size_index]) / N

# 所有人
bar_width = 0.5
plt.figure(figsize=(8,5))
plt.bar(size_values, mean_array, width=bar_width, label='Observers Real', color='lightgreen', edgecolor='green', alpha=1)
plt.bar(size_values + bar_width, P_CSF_size, width=bar_width, label='StelaCSF Prediction', color='royalblue', edgecolor='blue', alpha=1)
plt.errorbar(size_values, mean_array, yerr=std_dev_array,
             fmt='none', color='red', capsize=3, label='Standard Deviation across Observers')
plt.errorbar(size_values, mean_array, yerr=[mean_array - bino_error_bar[:, 0], bino_error_bar[:, 1] - mean_array],
             fmt='none', color='blue', capsize=3, label='99% Binomial Confidence Interval')

plt.xlabel('Size (Degree)')
plt.ylabel('Mean Accuracy = Probability')
plt.title('Group by Luminance')
plt.legend()
plt.show()