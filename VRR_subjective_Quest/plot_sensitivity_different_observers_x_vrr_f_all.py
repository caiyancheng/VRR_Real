import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

Quest_exp_path = r'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all'
Observer_list = ['Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen']

plt.figure(figsize=(12,9))
vrr_f_ticks = [0.5, 2, 4, 8, 10, 12, 14, 16]
size_ticks = [0.5, 1, 16, 'full']
Sensitivity_value_vrr_f = np.full((len(Observer_list), len(size_ticks), len(vrr_f_ticks)), np.nan)

for Observer_id in range(len(Observer_list)):
    Observer = Observer_list[Observer_id]
    config_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'config.json')
    csv_result_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'reorder_result_D_thr_C_t.csv')
    with open(config_path, 'r') as fp:
        config_data = json.load(fp)
    VRR_Frequency_list = config_data["change_parameters"]["VRR_Frequency"]
    Size_list = config_data["change_parameters"]["Size"]
    df = pd.read_csv(csv_result_path)
    for size_index in range(len(Size_list)):
        size_value = Size_list[size_index]
        plt.subplot(len(Size_list), 2, 2*size_index+1)
        vrr_f_list = []
        sensitivity_list = []
        sensitivity_high_list = []
        sensitivity_low_list = []
        for vrr_f_index in range(len(VRR_Frequency_list)):
            vrr_f_value = VRR_Frequency_list[vrr_f_index]
            if size_value == 'full':
                sub_df = df[(df["VRR_Frequency"] == vrr_f_value) & (df["Size_Degree"] == -1)]
            else:
                sub_df = df[(df["VRR_Frequency"] == vrr_f_value)&(df["Size_Degree"] == size_value)]
            if len(sub_df) == 1:
                vrr_f_list.append(vrr_f_value)
                sensitivity_list.append(1/sub_df['C_t'].item())
                sensitivity_high_list.append(1/sub_df['C_t_low'].item())
                sensitivity_low_list.append(1/sub_df['C_t_high'].item())
                Sensitivity_value_vrr_f[Observer_id, size_index, vrr_f_index] = 1/sub_df['C_t'].item()
            else:
                continue
        error_bar = (np.array([sensitivity_list, sensitivity_high_list]) - np.array([sensitivity_low_list, sensitivity_list]))
        error_bar[np.isnan(error_bar)] = 0
        if size_index == len(Size_list) - 1:
            plt.errorbar(vrr_f_list, np.array(sensitivity_list), yerr=error_bar, fmt='-o', label=f'Observer {Observer}')
        else:
            plt.errorbar(vrr_f_list, np.array(sensitivity_list), yerr=error_bar, fmt='-o')
        plt.xscale('log')
        plt.yscale('log')
        plt.xticks([0.5, 2, 4, 8, 10, 12, 14, 16], ['0.5', '2', '4', '8', '10', '12', '14', '16'])
        plt.yticks([10,50,250], ['10', '50', '250'])
        plt.ylabel('Sensitivity')
        plt.xlim([0.4, 18])
        plt.ylim([10, 400])
        plt.title(f'Size {size_value}')
        plt.grid(True)
plt.xlabel('Frequency of RR Switch')

# 在这里再画平均值的那个
for size_index in range(len(Size_list)):
    size_value = Size_list[size_index]
    plt.subplot(len(Size_list), 2, 2*size_index+2)
    S_mean_array = np.nanmean(Sensitivity_value_vrr_f, axis=0)[size_index,:]
    plt.plot(vrr_f_ticks, S_mean_array, '-o', linewidth=4, label=f'Mean Sensitivity of All Observers')
    plt.xscale('log')
    plt.yscale('log')
    plt.xticks([0.5, 2, 4, 8, 10, 12, 14, 16], ['0.5', '2', '4', '8', '10', '12', '14', '16'])
    plt.yticks([0.5, 1, 2, 5], ['0.5', '1', '2', '5'])
    plt.xlim([0.4, 18])
    plt.ylim([10, 400])
    plt.title(f'Size {size_value}')
    plt.grid(True)
plt.subplots_adjust(left=0.1, right=0.9, bottom=0.05, top=0.95, wspace=0.4, hspace=0.4)
# plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.8), ncol=3)
plt.xlabel('VRR Frequency')
plt.tight_layout()
plt.show()

