# 对subjective experiment 做出分析
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd

def autolabel(rects, xpos='center'):
    xpos = xpos.lower()
    ha = {'center': 'center', 'right': 'left', 'left': 'right'}
    offset = {'center': 0, 'right': 1, 'left': -1}

    for rect in rects:
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width() / 2 + offset[xpos] * 0.05, height,
                '{:.2f}'.format(height), ha=ha[xpos], va='bottom' if height > 0 else 'top')

exp_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1'
exp_path_list = os.listdir(exp_base_path)
df_dict = {}
for exp_path in exp_path_list:
    df = pd.read_csv(os.path.join(exp_base_path, exp_path, 'result.csv'))
    df_dict[exp_path] = df
obs_list = list(df_dict.keys())

# 与照明相关的准确率变化
size_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['Size_Degree'].unique()
accuracy_array = np.zeros(shape=(len(size_values), len(df_dict.keys())))
for size_index in range(len(size_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][df_dict[obs]['Size_Degree'] == size_values[size_index]]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[size_index][obs_index] = accuracy
# 绘制柱状图
x_values = np.array(size_values)
# x_values = np.array([4,16])
bar_width = 0.2
rect1_1 = plt.bar(x_values - bar_width, accuracy_array[:, 0], width=bar_width, label=obs_list[0], color='red')
rect1_2 = plt.bar(x_values, accuracy_array[:, 1], width=bar_width, label=obs_list[1], color='green')
rect1_3 = plt.bar(x_values + bar_width, accuracy_array[:, 2], width=bar_width, label=obs_list[2], color='blue')
plt.xlabel('Size (Degree)')
plt.ylabel('Accuracy')
plt.legend()
autolabel(rect1_1, "center")
autolabel(rect1_2, "center")
autolabel(rect1_3, "center")
plt.show()
# 所有人平均
bar_width = 0.6
plt.figure()
rect2_1 = plt.bar(x_values, (accuracy_array[:, 0] + accuracy_array[:, 1] + accuracy_array[:, 2])/3, width=bar_width, label='Mean Accuracy', color='green')
plt.xlabel('Size (Degree)')
plt.ylabel('Mean Accuracy')
plt.legend()
autolabel(rect2_1, "center")
plt.show()