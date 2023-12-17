import numpy as np
import matplotlib.pyplot as plt
import json
import os
from matplotlib.ticker import MaxNLocator, LogLocator

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
with open(os.path.join(Quest_exp_path, 'color2luminance.json'), 'r') as fp:
    Color2Luminance_dict = json.load(fp)

MOA_VRR_Fs = MOA_config['change_parameters']['VRR_Frequency']
MOA_Sizes = MOA_config['change_parameters']['Size']
Quest_VRR_Fs = Quest_config['change_parameters']['VRR_Frequency']
Quest_Sizes = Quest_config['change_parameters']['Size']

MOA_result_luminance_array = np.zeros((len(MOA_VRR_Fs), len(MOA_Sizes)))
for vrr_f_index in range(len(MOA_VRR_Fs)):
    for size_index in range(len(MOA_Sizes)):
        color_value = np.array(MOA_result[f'V_{MOA_VRR_Fs[vrr_f_index]}_S_{MOA_Sizes[size_index]}']).mean()
        MOA_result_luminance_array[vrr_f_index][size_index] = Color2Luminance_dict[f'S_{MOA_Sizes[size_index]}_C_{color_value}_MOA'][0]

Quest_result_luminance_array_mean = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_luminance_array_mode = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_luminance_array_quantile = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
Quest_result_luminance_array_quantile_05 = np.zeros((len(Quest_VRR_Fs), len(Quest_Sizes)))
for vrr_f_index in range(len(Quest_VRR_Fs)):
    for size_index in range(len(Quest_Sizes)):
        size_value = Quest_Sizes[size_index]
        vrr_f_value = Quest_VRR_Fs[vrr_f_index]
        Quest_result_luminance_array_mean[vrr_f_index][size_index] = Color2Luminance_dict[
            f"S_{size_value}_C_{Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Mean']}_Quest_mean"][0]
        Quest_result_luminance_array_mode[vrr_f_index][size_index] = Color2Luminance_dict[
            f"S_{size_value}_C_{Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Mode']}_Quest_mode"][0]
        Quest_result_luminance_array_quantile[vrr_f_index][size_index] = Color2Luminance_dict[
            f"S_{size_value}_C_{Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Quantile']}_Quest_quantile"][0]
        Quest_result_luminance_array_quantile_05[vrr_f_index][size_index] = Color2Luminance_dict[
            f"S_{size_value}_C_{Quest_final_result[f'V_{vrr_f_value}_S_{size_value}']['Quantile_05']}_Quest__quantile_05"][0]

plt.figure(figsize=(10,12))
# plt.figure()
# plt.suptitle('Frequency of RR Switch VS Color Value')
plt.figtext(0.5, 0.98, 'Critical Luminance under different sizes', ha='center', fontsize=12)
for size_index in range(len(MOA_Sizes)):
    ax = plt.subplot(len(MOA_Sizes), 1, size_index + 1)
    X_axis_vrr_f = np.array(MOA_VRR_Fs)
    MOA_Y_axis_luminance = MOA_result_luminance_array[:, size_index]
    Quest_Y_axis_luminance_mean = Quest_result_luminance_array_mean[:, size_index]
    Quest_Y_axis_luminance_mode = Quest_result_luminance_array_mode[:, size_index]
    Quest_Y_axis_luminance_quantile = Quest_result_luminance_array_quantile[:, size_index]
    Quest_Y_axis_luminance_quantile_05 = Quest_result_luminance_array_quantile_05[:, size_index]
    plt.plot(X_axis_vrr_f, MOA_Y_axis_luminance, marker='o', markersize=8, label='MOA experiment')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_luminance_mean, marker='+', markersize=8, label='Quest experiment Mean')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_luminance_mode, marker='+', markersize=8, label='Quest experiment Mode')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_luminance_quantile, marker='+', markersize=8, label='Quest experiment Quantile')
    plt.plot(X_axis_vrr_f, Quest_Y_axis_luminance_quantile_05, marker='+', markersize=8, label='Quest experiment Quantile_05')
    # ymin, ymax = ax.get_ylim()
    plt.xscale('log')
    plt.yscale('log')
    # ax.set_yticks([ymin, (ymin+ymax)/2, ymax])
    # ax.get_yaxis().set_major_formatter(plt.ScalarFormatter())
    # ax.yaxis.set_major_locator(LogLocator(subs=[1.0]))
    # plt.ylim([0.2,3])
    ax.text(0.5, 0.92, f'Size: {MOA_Sizes[size_index]}x{MOA_Sizes[size_index]} degrees', ha='center', transform=ax.transAxes, fontsize=10)
plt.legend(bbox_to_anchor=(0.5, 3.5), loc='lower center', borderaxespad=0.0, borderpad=1.5, ncol=3, frameon=True, edgecolor='black')
plt.xlabel('Frequency of RR Switch (Hz) - Log scale',fontsize=12)
plt.figtext(0.02, 0.5, 'Luminance (nits) - Log scale', va='center', rotation='vertical', fontsize=12)
plt.show()

plt.figure(figsize=(8,16))
# plt.figure()
plt.figtext(0.5, 0.98, 'Critical Luminance under different Frequency of RR Switch', ha='center', fontsize=15)
for vrr_f_index in range(len(Quest_VRR_Fs)):
    ax = plt.subplot(len(Quest_VRR_Fs), 1, vrr_f_index+1)
    X_axis_size = np.array(MOA_Sizes)
    for size_index in range(len(X_axis_size)):
        if X_axis_size[size_index] == 'full':
            X_axis_size[size_index] = 40
    MOA_Y_axis_luminance = MOA_result_luminance_array[vrr_f_index,]
    Quest_Y_axis_luminance_mean = Quest_result_luminance_array_mean[vrr_f_index,]
    Quest_Y_axis_luminance_mode = Quest_result_luminance_array_mode[vrr_f_index,]
    Quest_Y_axis_luminance_quantile = Quest_result_luminance_array_quantile[vrr_f_index,]
    Quest_Y_axis_luminance_quantile_05 = Quest_result_luminance_array_quantile_05[vrr_f_index,]
    plt.plot(X_axis_size, MOA_Y_axis_luminance, marker='o', markersize=8, label='MOA experiment')
    plt.plot(X_axis_size, Quest_Y_axis_luminance_mean, marker='+', markersize=8, label='Quest experiment Mean')
    plt.plot(X_axis_size, Quest_Y_axis_luminance_mode, marker='+', markersize=8, label='Quest experiment Mode')
    plt.plot(X_axis_size, Quest_Y_axis_luminance_quantile, marker='+', markersize=8, label='Quest experiment Quantile')
    plt.plot(X_axis_size, Quest_Y_axis_luminance_quantile_05, marker='+', markersize=8, label='Quest experiment Quantile_05')
    # plt.xscale('log')
    plt.yscale('log')
    ax.text(0.5, 0.92, f'Frequency of RR Switch: {Quest_VRR_Fs[vrr_f_index]} Hz', ha='center',
            transform=ax.transAxes, fontsize=8)
plt.legend(bbox_to_anchor=(0.5, 7.2), loc='lower center', borderaxespad=0.0, borderpad=1.1, ncol=3, frameon=True, edgecolor='black')
plt.xlabel('Size (degree)')
plt.figtext(0.02, 0.5, 'Luminance (nits) - Log scale', va='center', rotation='vertical', fontsize=12)
plt.show()
