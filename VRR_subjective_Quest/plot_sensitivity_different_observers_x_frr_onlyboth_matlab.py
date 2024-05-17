import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

# 只画那些参加了所有实验的人
csv_file_path = r'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_S_gather.csv'
Observer_list = ['Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen']
Vrr_f_list = [0.5, 2, 4, 8, 10, 12, 14, 16]
Size_list = [0.5, 1, 16, -1]
FRR_dict_list = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9]

plt.figure(figsize=(12,9))

Sensitivity_value_vrr_f = np.full((len(Observer_list), len(Size_list), len(Vrr_f_list)), np.nan)

df = pd.read_csv(csv_file_path)
for Observer_id in range(len(Observer_list)):
    Observer = Observer_list[Observer_id]
    # if Observer != 'Yaru':
    #     continue
    for size_index in range(len(Size_list)):
        size_value = Size_list[size_index]
        plt.subplot(len(Size_list), 2, 2*size_index+1)
        FRR_list = []
        sensitivity_list = []
        sensitivity_high_list = []
        sensitivity_low_list = []
        s_df = df[(df["Observer_name"] == f'{Observer}_2') & (df["Size_Degree"] == size_value)]
        if len(s_df) < len(Vrr_f_list)-2:
            continue
        for vrr_f_index in range(len(Vrr_f_list)):
            vrr_f_value = Vrr_f_list[vrr_f_index]
            sub_df = df[(df["Observer_name"] == f'{Observer}_2') & (df["VRR_Frequency"] == vrr_f_value) & (df["Size_Degree"] == size_value)]
            if len(sub_df) == 1:
                FRR_list.append(sub_df['FRR'].item())
                sensitivity_list.append(sub_df['Sensitivity'].item())
                sensitivity_high_list.append(sub_df['Sensitivity_high'].item())
                sensitivity_low_list.append(sub_df['Sensitivity_low'].item())
                Sensitivity_value_vrr_f[Observer_id, size_index, vrr_f_index] = sub_df['Sensitivity'].item()
            else:
                continue
        error_bar = (np.array([sensitivity_list, sensitivity_high_list]) - np.array([sensitivity_low_list, sensitivity_list]))
        error_bar[np.isnan(error_bar)] = 0
        if size_index == len(Size_list) - 1:
            plt.errorbar(FRR_list, np.array(sensitivity_list), yerr=error_bar, fmt='-o', label=f'Observer {Observer}')
        else:
            plt.errorbar(FRR_list, np.array(sensitivity_list), yerr=error_bar, fmt='-o')
        # plt.xscale('log')
        plt.yscale('log')
        plt.xticks(FRR_dict_list, [str(item) for item in FRR_dict_list])
        # plt.yticks([10,50,250], ['10', '50', '250'])
        plt.ylabel('Sensitivity')
        plt.xlim([0.4, 16])
        plt.ylim([10, 5000])
        if size_value == -1:
            plt.title(f'Size Full Screen')
        else:
            plt.title(f'Size (Diameter) {size_value}')
        plt.grid(True)
plt.xlabel('Frequency of RR Switch')
plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.8), ncol=3)

# 在这里再画平均值的那个
for size_index in range(len(Size_list)):
    size_value = Size_list[size_index]
    plt.subplot(len(Size_list), 2, 2*size_index+2)
    S_mean_array = 10**np.nanmean(np.log10(Sensitivity_value_vrr_f), axis=0)[size_index,:]
    plt.plot(FRR_dict_list, S_mean_array, '-o', linewidth=4, label=f'Mean Sensitivity of All Observers')
    # plt.xscale('log')
    plt.yscale('log')
    plt.xticks(FRR_dict_list, [str(item) for item in FRR_dict_list])
    # plt.yticks([0.5, 1, 2, 5], ['0.5', '1', '2', '5'])
    plt.xlim([0.4, 16])
    plt.ylim([10, 5000])
    if size_value == -1:
        plt.title(f'Size Full Screen')
    else:
        plt.title(f'Size (Diameter) {size_value}')
    plt.grid(True)
plt.subplots_adjust(left=0.1, right=0.9, bottom=0.05, top=0.95, wspace=0.4, hspace=0.4)
plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.8), ncol=3)
plt.xlabel('Frequency of RR Switch')
plt.tight_layout()
plt.show()

