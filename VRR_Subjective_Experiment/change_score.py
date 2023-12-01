#有人不小心写反了所有分数
import pandas as pd

change_path = 'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1\Observer_Yaru_Liu_Test_Repeat_10/result.csv'

df = pd.read_csv(change_path)

df['Observer_choice'] = 1 - df['Observer_choice']

df.to_csv(change_path, index=False)