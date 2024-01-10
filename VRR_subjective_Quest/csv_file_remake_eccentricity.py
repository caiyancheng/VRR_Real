# 因为QUEST实验中我们打断了实验顺序，因此我们需要重新整理csv_file
import os
import pandas as pd
import numpy as np
import json

Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_disk_eccentricity_1\Observer_Yancheng_Cai_2'
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
df = pd.read_csv(os.path.join(Quest_exp_path, 'result.csv'))
original_keys = df.keys()
new_csv_log = {}
for key in original_keys:
    new_csv_log[key] = []

Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']
Quest_Eccentricity = Quest_config['change_parameters']['Eccentricity']
Trail_number = Quest_config['change_parameters']['Trail_Number']

ordered_indices = []
for vrr_f_index in range(len(Quest_VRR_Fs)):
    vrr_f_value = Quest_VRR_Fs[vrr_f_index]
    if vrr_f_value == 16:
        continue
    for size_index in range(len(Quest_Sizes)):
        size_value = Quest_Sizes[size_index]
        for ecc_index in range(len(Quest_Eccentricity)):
            ecc_value = Quest_Eccentricity[ecc_index]
            for trail_id in range(Trail_number):
                subset = df[(df['VRR_Frequency'] == vrr_f_value) & (df['Size_Degree'] == size_value) & (
                            df['Eccentricity'] == ecc_value) & (df['Trail_ID'] == trail_id)]
                for key in original_keys:
                    new_csv_log[key].append(subset[key].item())
new_df = pd.DataFrame(new_csv_log)
new_df.to_csv(os.path.join(Quest_exp_path, 'reorder_result.csv'), index=False)

