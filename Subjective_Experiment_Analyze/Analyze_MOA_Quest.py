import numpy as np
import matplotlib.pyplot as plt
import json
import os

MOA_exp_path = r'..\VRR_Subjective_MOA\Result_MOA_1\Observer_Yancheng_Cai_Test_10'
Quest_exp_path = r'..\VRR_subjective_Quest\Result_Quest_1\Observer_Yancheng_Cai_Test_10'

with open(os.path.join(MOA_exp_path, 'config.json'), 'r') as fp:
    MOA_config = json.load(fp)
with open(os.path.join(Quest_exp_path, 'config.json'), 'r') as fp:
    Quest_config = json.load(fp)
with open(os.path.join(MOA_exp_path, 'result.json'), 'r') as fp:
    MOA_result = json.load(fp)
with open(os.path.join(Quest_exp_path, 'final_result.json'), 'r') as fp:
    Quest_final_result = json.load(fp)

MOA_VRR_Fs = MOA_config['change_parameters']['VRR_Frequency']
MOA_Sizes = MOA_config['change_parameters']['Size']
Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']

MOA_result_color_array = np.zeros((len(MOA_VRR_Fs), len(MOA_Sizes)))
for vrr_f_index in range(len(MOA_VRR_Fs)):
    for size_index in range(len(MOA_Sizes)):
        MOA_result_color_array[vrr_f_index][size_index] = np.array(MOA_result[f'V_{MOA_VRR_Fs[vrr_f_index]}_S_{MOA_Sizes[size_index]}']).mean()
Quest_result_color_array_mean = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_color_array_mode = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_color_array_quantile = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_color_array_quantile_05 = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
for vrr_f_index in range(len(Quest_VRR_Fs)):
    for size_index in range(len(Quest_Sizes)):
        Quest_result_color_array_mean[vrr_f_index][size_index] = \
        Quest_final_result[f'V_{Quest_VRR_Fs[vrr_f_index]}_S_{Quest_Sizes[size_index]}']['Mean']
        Quest_result_color_array_mode[vrr_f_index][size_index] = \
        Quest_final_result[f'V_{Quest_VRR_Fs[vrr_f_index]}_S_{Quest_Sizes[size_index]}']['Mode']
        Quest_result_color_array_quantile[vrr_f_index][size_index] = \
        Quest_final_result[f'V_{Quest_VRR_Fs[vrr_f_index]}_S_{Quest_Sizes[size_index]}']['Quantile']
        Quest_result_color_array_quantile_05[vrr_f_index][size_index] = \
        Quest_final_result[f'V_{Quest_VRR_Fs[vrr_f_index]}_S_{Quest_Sizes[size_index]}']['Quantile_05']

plt.figure(figsize=(10,10))
# plt.figure()
plt.suptitle('Frequency of RR Switch VS Color Value')
for size_index in range(len(MOA_Sizes)):
    plt.subplot(len(MOA_Sizes), 1, size_index+1)
    X_axis_vrr_f = np.array(MOA_VRR_Fs)
    MOA_Y_axis_Color = MOA_result_color_array[:, size_index]
    Quest_Y_axis_Color_mean = Quest_result_color_array_mean[:, size_index]
    Quest_Y_axis_Color_mode = Quest_result_color_array_mode[:, size_index]
    Quest_Y_axis_Color_quantile = Quest_result_color_array_quantile[:, size_index]
    Quest_Y_axis_Color_quantile_05 = Quest_result_color_array_quantile_05[:, size_index]
    plt.plot(X_axis_vrr_f, MOA_Y_axis_Color, marker='o', markersize=8, label='MOA experiment')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_Color_mean, marker='+', markersize=8, label='Quest experiment Mean')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_Color_mode, marker='+', markersize=8, label='Quest experiment Mode')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_Color_quantile, marker='+', markersize=8, label='Quest experiment Quantile')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_Color_quantile_05, marker='+', markersize=8, label='Quest experiment Quantile_05')
    plt.legend()
    plt.xscale('log')
    # plt.yscale('log')
plt.xlabel('Frequency of RR Switch (Hz)')
plt.ylabel('Color Value')
plt.show()

# plt.figure(figsize=(8,16))
# # plt.figure()
# plt.title('Size Switch VS Color Value')
# for vrr_f_index in range(len(Quest_VRR_Fs)):
#     plt.subplot(len(Quest_VRR_Fs), 1, vrr_f_index+1)
#     X_axis_size = np.array(MOA_Sizes)
#     for size_index in range(len(X_axis_size)):
#         if X_axis_size[size_index] == 'full':
#             X_axis_size[size_index] = 40
#     MOA_Y_axis_Color = MOA_result_color_array[vrr_f_index,]
#     Quest_Y_axis_Color_mean = Quest_result_color_array_mean[vrr_f_index,]
#     Quest_Y_axis_Color_mode = Quest_result_color_array_mode[vrr_f_index,]
#     Quest_Y_axis_Color_quantile = Quest_result_color_array_quantile[vrr_f_index,]
#     Quest_Y_axis_Color_quantile_05 = Quest_result_color_array_quantile_05[vrr_f_index,]
#     plt.plot(X_axis_size, MOA_Y_axis_Color, marker='o', markersize=8, label='MOA experiment')
#     plt.plot(X_axis_size, Quest_Y_axis_Color_mean, marker='+', markersize=8, label='Quest experiment Mean')
#     plt.plot(X_axis_size, Quest_Y_axis_Color_mode, marker='+', markersize=8, label='Quest experiment Mode')
#     plt.plot(X_axis_size, Quest_Y_axis_Color_quantile, marker='+', markersize=8, label='Quest experiment Quantile')
#     plt.plot(X_axis_size, Quest_Y_axis_Color_quantile_05, marker='+', markersize=8, label='Quest experiment Quantile_05')
#     plt.legend()
# plt.xlabel('Size (degree)')
# plt.ylabel('Color Value')
# # plt.xscale('log')
# plt.yscale('log')
# plt.show()
