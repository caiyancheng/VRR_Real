# 因为QUEST实验中我们打断了实验顺序，因此我们需要重新整理csv_file
import os
import pandas as pd
import numpy as np
import json

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_duration_1\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'result.csv'))
original_keys = df.keys()
new_csv_log = {}
for key in original_keys:
    new_csv_log[key] = []

Durations = Quest_config['change_parameters']['Duration']
Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']
Trail_number = Quest_config['change_parameters']['Trail_Number']

ordered_indices = []
for duration_index in range(len(Durations)):
    duration_value = Durations[duration_index]
    for vrr_f_index in range(len(Quest_VRR_Fs)):
        vrr_f_value = Quest_VRR_Fs[vrr_f_index]
        for size_index in range(len(Quest_Sizes)):
            size_value = Quest_Sizes[size_index]
            for trail_id in range(Trail_number):
                subset = df[(df['Duration'] == duration_value) & (df['VRR_Frequency'] == vrr_f_value) & (df['Size_Degree'] == size_value) & (df['Trail_ID'] == trail_id)]
                for key in original_keys:
                    new_csv_log[key].append(subset[key].item())
new_df = pd.DataFrame(new_csv_log)
new_df.to_csv(os.path.join(Quest_exp_path, 'reorder_result.csv'), index=False)

