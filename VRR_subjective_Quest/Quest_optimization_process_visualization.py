import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import json

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_4\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
with open(os.path.join(Quest_exp_path, 'final_result.json'), 'r') as fp:
    Quest_final_result = json.load(fp)
# with open(os.path.join(Quest_exp_path, 'color2luminance.json'), 'r') as fp:
#     Color2Luminance_dict = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'result.csv'))

Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']
Trail_number = Quest_config['change_parameters']['Trail_Number']

plt.figure(figsize=(10,12))
for vrr_f_index in range(len(Quest_VRR_Fs)):
    for size_index in range(len(Quest_Sizes)):
        ax = plt.subplot(len(Quest_VRR_Fs), len(Quest_Sizes), vrr_f_index * len(Quest_Sizes) + size_index + 1)
        size_value = Quest_Sizes[size_index]
        vrr_f_value = Quest_VRR_Fs[vrr_f_index]
        filtered_df = df[(df['Size_Degree'] == str(size_value)) & (df['VRR_Frequency'] == vrr_f_value)]
        x_trail_num = []
        y_color = []
        # y_decision = []
        # y_luminance = []
        for trail_i in range(Trail_number):
            x_trail_num.append(trail_i)
            log_df = filtered_df[filtered_df['Trail_ID'] == trail_i]
            y_color.append(log_df['Threshold_Color_Value'])
            # y_decision.append(log_df['Response'])
        plt.plot(x_trail_num, y_color, marker='o', markersize=8)
# plt.xlabel('Trail ID',fontsize=12)
# plt.ylabel('Threshold Color Value',fontsize=12)
plt.figtext(0.02, 0.5, 'Threshold Color Value', va='center', rotation='vertical', fontsize=15)
plt.figtext(0.5, 0.05, 'Trail ID', ha='center', fontsize=15)
plt.show()
