import os
import pandas as pd

root_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1'
obs_list = os.listdir(root_path)

# 用于存储所有Observer的DataFrame的列表
all_obs_dfs = []

for obs_name in obs_list:
    if obs_name.endswith('.csv'):
        continue
    csv_path = os.path.join(root_path, obs_name, 'result.csv')
    df = pd.read_csv(csv_path)
    df.drop('VRR_Color', axis=1, inplace=True)
    df = df.assign(Observer=obs_name)
    df['response'] = df.apply(lambda row: 1 if row['Real_VRR_period'] == row['Observer_choice'] else 0, axis=1)
    all_obs_dfs.append(df)

result_df = pd.concat(all_obs_dfs, ignore_index=True)
output_csv_path = os.path.join(root_path, 'all_data_result.csv')
result_df.to_csv(output_csv_path, index=False)

# 'Block_ID', 'VRR_Frequency', 'Luminance', 'Size_Degree', 'Eccentricity', 'Repeat_ID', 'Real_VRR_period', 'Observer_choice', 'VRR_Color', 'Observer'