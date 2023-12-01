# 对subjective experiment 做出分析
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd

exp_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1'
exp_path_list = os.listdir(exp_base_path)
df_dict = {}
for exp_path in exp_path_list:
    df = pd.read_csv(os.path.join(exp_base_path, exp_path, 'result.csv'))
    df_dict[exp_path] = df
obs_list = list(df_dict.keys())

# 与照明相关的准确率变化
luminance_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['Luminance'].unique()
accuracy_array = np.zeros(shape=(len(luminance_values), len(df_dict.keys())))
for luminace_index in range(len(luminance_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][df_dict[obs]['Luminance'] == luminance_values[luminace_index]]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[luminace_index][obs_index] = accuracy
# 绘制柱状图
x_values = np.log10(luminance_values)
bar_width = 0.02
plt.bar(x_values - bar_width, accuracy_array[:, 0], width=bar_width, label=obs_list[0], color='red')
plt.bar(x_values, accuracy_array[:, 1], width=bar_width, label=obs_list[1], color='green')
plt.bar(x_values + bar_width, accuracy_array[:, 2], width=bar_width, label=obs_list[2], color='blue')
plt.xlabel('Log Luminance (nits)')
plt.ylabel('Accuracy')
plt.legend()
plt.show()
# 所有人平均
bar_width = 0.06
plt.figure()
plt.bar(x_values, (accuracy_array[:, 0] + accuracy_array[:, 1] + accuracy_array[:, 2])/3, width=bar_width, label='Mean Accuracy', color='green')
plt.xlabel('Log Luminance (nits)')
plt.ylabel('Mean Accuracy')
plt.legend()
plt.show()