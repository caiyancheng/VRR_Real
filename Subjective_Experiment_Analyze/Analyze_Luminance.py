# 对subjective experiment 做出分析
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from scipy.stats import binom

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
accuracy_array = np.zeros(shape=(len(luminance_values), len(df_dict.keys())))
for luminace_index in range(len(luminance_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][df_dict[obs]['Luminance'] == luminance_values[luminace_index]]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[luminace_index][obs_index] = accuracy

mean_array = np.mean(accuracy_array, axis=1)
std_dev_array = np.std(accuracy_array, axis=1)
N = len(df) * num_obs / len(luminance_values)
bino_error_bar = np.zeros(shape=(len(luminance_values),2))
for luminace_index in range(len(luminance_values)):
    bino_error_bar[luminace_index] = binom.ppf([0.005, 0.995], N, mean_array[luminace_index]) / N

# 绘制柱状图
x_values = np.log10(luminance_values)
bar_width = 0.02
color = ['red', 'yellow', 'green', 'blue']
for obs_index in range(num_obs):
    rect = plt.bar(x_values + bar_width * (obs_index - (num_obs-1) / 2), accuracy_array[:, obs_index], width=bar_width, label=obs_list[obs_index], color=color[obs_index])
plt.xlabel('Log Luminance (nits)')
plt.ylabel('Accuracy')
plt.legend()
plt.show()
# 所有人平均
bar_width = 0.06
plt.figure()
plt.bar(x_values, mean_array, width=bar_width, label='Mean Accuracy', color='green')
plt.errorbar(x_values, mean_array, yerr=std_dev_array,
             fmt='none', color='red', capsize=3, label='Standard Deviation across Observers')
plt.errorbar(x_values, mean_array, yerr=[mean_array - bino_error_bar[:, 0], bino_error_bar[:, 1] - mean_array],
             fmt='none', color='blue', capsize=3, label='99% Binomial Confidence Interval')
plt.xlabel('Log Luminance (nits)')
plt.ylabel('Mean Accuracy')
plt.legend()
plt.show()