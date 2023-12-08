import numpy as np
import pandas as pd

signal_sensitivity_csv_file = r'E:\Py_codes\VRR_Real\stelaCSF_matlab/sensitivity_results.csv'

df = pd.read_csv(signal_sensitivity_csv_file)
result_df = df.groupby(['Luminance'])['S_VRR'].mean().reset_index()
X = 1