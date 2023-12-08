# 对subjective experiment 做出分析
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from scipy.stats import binom
from Computational_Model.Fit_Psychometric_function_simple import *

def find_value(new_y_values, value):
    differences = np.abs(new_y_values - value)
    index = np.argmin(differences)
    return index

exp_base_path = r'E:\Py_codes\VRR_Real\VRR_Subjective_Experiment\Result_pilot_1'
exp_path_list = os.listdir(exp_base_path)
df_dict = {}
for exp_path in exp_path_list:
    df = pd.read_csv(os.path.join(exp_base_path, exp_path, 'result.csv'))
    df_dict[exp_path] = df
obs_list = list(df_dict.keys())
num_obs = len(obs_list)

# 与照明相关的准确率变化
luminance_values = df_dict['Observer_Yancheng_Cai_Test_Repeat_10']['Luminance'].unique()
accuracy_array = np.zeros(shape=(len(luminance_values), len(df_dict.keys())))
for luminace_index in range(len(luminance_values)):
    for obs_index in range(len(obs_list)):
        obs = obs_list[obs_index]
        sub_df = df_dict[obs][df_dict[obs]['Luminance'] == luminance_values[luminace_index]]
        accuracy = (sub_df['Real_VRR_period'] == sub_df['Observer_choice']).mean()
        accuracy_array[luminace_index][obs_index] = accuracy

x_array = luminance_values
y_array = np.mean(accuracy_array, axis=1)

beta = 3.5
target_p = 0.75
guess_p = 0.5
initial_guess = [2]
fitted_params = fit_pf_dec_exp(x_array, y_array, beta, target_p, guess_p, initial_guess)
print("Fitted Parameters:")
print("mu:", fitted_params[0])
new_x_values = np.arange(1,100,0.01)
new_y_values = pf_dec_exp(new_x_values, fitted_params[0],  beta, target_p, guess_p)
index = find_value(new_y_values, target_p)
print("Ct:", new_x_values[index])

mean_array = np.mean(accuracy_array, axis=1)
std_dev_array = np.std(accuracy_array, axis=1)
N = len(df) * num_obs / len(luminance_values)
bino_error_bar = np.zeros(shape=(len(luminance_values),2))
for luminace_index in range(len(luminance_values)):
    bino_error_bar[luminace_index] = binom.ppf([0.005, 0.995], N, mean_array[luminace_index]) / N

# 所有人
bar_width = 0.06
plt.figure()
plt.bar(np.log10(x_array), y_array, width=bar_width, label='Mean Accuracy', color='green')
plt.plot(np.log10(new_x_values), new_y_values)
plt.scatter(np.log10(new_x_values[index]), new_y_values[index], color='red', s=50, label='Target Point')
plt.annotate(f'Detection Threshold\n(C_t={new_x_values[index]:.2f}, p={new_y_values[index]:.2f})',
             xy=(np.log10(new_x_values[index]), new_y_values[index]),
             xytext=(np.log10(new_x_values[index]) + 0.5, new_y_values[index] - 0.07),
             arrowprops=dict(facecolor='black', shrink=0.03), color='red')
plt.errorbar(np.log10(x_array), mean_array, yerr=std_dev_array,
             fmt='none', color='red', capsize=3, label='Standard Deviation across Observers')
plt.errorbar(np.log10(x_array), mean_array, yerr=[mean_array - bino_error_bar[:, 0], bino_error_bar[:, 1] - mean_array],
             fmt='none', color='blue', capsize=3, label='99% Binomial Confidence Interval')

plt.xlabel('Log Luminance (nits)')
plt.ylabel('Mean Accuracy / Probability')
plt.legend()
plt.show()