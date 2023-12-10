# 对subjective experiment 做出分析
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from scipy.stats import binom
import json

def autolabel(rects, xpos='center'):
    xpos = xpos.lower()
    ha = {'center': 'center', 'right': 'left', 'left': 'right'}
    offset = {'center': 0, 'right': 1, 'left': -1}

    for rect in rects:
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width() / 2 + offset[xpos] * 0.05, height,
                '{:.2f}'.format(height), ha=ha[xpos], va='bottom' if height > 0 else 'top')

exp_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_2\Size'
exp_path_list = os.listdir(exp_base_path)
df_dict = {}
config_list = []
luminance_list = []
vrr_f_list = []
for exp_path in exp_path_list:
    df = pd.read_csv(os.path.join(exp_base_path, exp_path, 'result.csv'))
    df_dict[exp_path] = df
    config_path = os.path.join(exp_base_path, exp_path, 'config.json')
    with open(config_path, 'r') as fp:
        config_data = json.load(fp)
    config_list.append(config_data)
    luminance_list.append(config_data['change_parameters']['Luminance'][0])
    vrr_f_list.append(config_data['change_parameters']['VRR_Frequency'][0])
obs_list = list(df_dict.keys())
num_obs = len(obs_list)

# 与照明相关的准确率变化
size_values = df_dict[obs_list[0]]['Size_Degree'].unique()
accuracy_array = np.zeros(shape=(len(size_values), len(df_dict.keys())))
for size_index in range(len(size_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][(df_dict[obs]['Size_Degree'] == size_values[size_index])
                             &(df_dict[obs]['Luminance'] == luminance_list[obs_index])
                             &(df_dict[obs]['VRR_Frequency'] == vrr_f_list[obs_index])]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[size_index][obs_index] = accuracy

N = len(df) * num_obs / len(size_values)
bino_error_bar = np.zeros(shape=(len(size_values), len(obs_list),2))
for size_index in range(len(size_values)):
    for obs_index in range(len(obs_list)):
        bino_error_bar[size_index][obs_index] = binom.ppf([0.025, 0.975], N, accuracy_array[size_index][obs_index]) / N

# 绘制柱状图
x_values = np.log10(size_values**2)
# x_values = np.array([4,16])
bar_width = 0.1

color = ['red', 'yellow', 'green', 'blue']
for obs_index in range(num_obs):
    rect = plt.bar(x_values + bar_width * (obs_index - (num_obs-1) / 2), accuracy_array[:, obs_index], width=bar_width, label=f'VRR_f_{vrr_f_list[obs_index]}_luminance_{luminance_list[obs_index]}', color=color[obs_index])
    if obs_index == num_obs - 1:
        plt.errorbar(x_values + bar_width * (obs_index - (num_obs - 1) / 2), accuracy_array[:, obs_index],
                     yerr=[accuracy_array[:, obs_index] - bino_error_bar[:, obs_index, 0],
                           bino_error_bar[:, obs_index, 1] - accuracy_array[:, obs_index]],
                     fmt='none', color='blue', capsize=3, label='95% Binomial Confidence Interval')
    else:
        plt.errorbar(x_values + bar_width * (obs_index - (num_obs - 1) / 2), accuracy_array[:, obs_index],
                     yerr=[accuracy_array[:, obs_index] - bino_error_bar[:, obs_index, 0],
                           bino_error_bar[:, obs_index, 1] - accuracy_array[:, obs_index]],
                     fmt='none', color='blue', capsize=3)
    autolabel(rect, "center")
plt.xlabel('Log10 Size*Size (Degree^2)')
plt.ylabel('Probability')
plt.legend()
plt.show()
# # 所有人平均
# bar_width = 0.1
# plt.figure()
# rect2_1 = plt.bar(x_values, mean_array, width=bar_width, label=f'VRR_f_{vrr_f}_luminance_{luminance}', color='green')
# plt.errorbar(x_values, mean_array, yerr=[mean_array - bino_error_bar[:, 0], bino_error_bar[:, 1] - mean_array],
#              fmt='none', color='blue', capsize=3, label='95% Binomial Confidence Interval')
# plt.xlabel('Log10 Size*Size (Degree^2)'),
# plt.ylabel('Probability')
# plt.legend()
# autolabel(rect2_1, "center")
# plt.show()