import pandas as pd

# change_path = 'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1\Observer_Yaru_Liu_Test_Repeat_10/result.csv'
# change_path = 'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1\Observer_Boyue_Zhang_Test_Repeat_10/result.csv'
# change_path = 'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1\Observer_Yancheng_Cai_Test_Repeat_10/result.csv'
change_path = 'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1\Observer_Yuxin_Guo_Test_Repeat_10/result.csv'

df = pd.read_csv(change_path)

observer_score_list = df['Observer_choice']
gt_score_list = df['Real_VRR_period']
all_score = (observer_score_list == gt_score_list).sum()
print('Percentage', all_score / len(observer_score_list))