import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

# Quest_exp_path = r'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4'
# Observer_list = ['Ale', 'Maliha', 'Yancheng_Cai', 'Ali', 'Shushan', 'Hongyun_Gao', 'Zhen', 'Yaru', 'Yuan', 'Claire', 'haoyu', 'pupu', 'Dounia', 'Jane']
Quest_exp_path = r'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all'
Observer_list = ['Ale', 'Ali', 'Chuyao', 'Claire', 'Dounia', 'haoyu', 'Hongyun_Gao', 'Jane', 'Maliha', 'pupu', 'Shushan', 'Tianbo_Liang', 'Yancheng_Cai', 'Yaru', 'Yuan', 'Zhen']

plt.figure(figsize=(12,9))
size_ticks = [0.5, 1, 16, 'full']
vrr_f_ticks = [0.5, 2, 4, 8, 10, 12, 14, 16]
frr_ticks = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9]
Luminance_value_vrr_f = np.full((len(Observer_list), len(size_ticks), len(vrr_f_ticks)), np.nan)

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
        luminance_list = []
        luminance_high_list = []
        luminance_low_list = []
        for vrr_f_index in range(len(VRR_Frequency_list)):
            vrr_f_value = VRR_Frequency_list[vrr_f_index]
            if size_value == 'full':
                sub_df = df[(df["VRR_Frequency"] == vrr_f_value) & (df["Size_Degree"] == -1)]
            else:
                sub_df = df[(df["VRR_Frequency"] == vrr_f_value)&(df["Size_Degree"] == size_value)]
            if len(sub_df) == 1:
                vrr_f_list.append(vrr_f_value)
                luminance_list.append(sub_df['Luminance'].item())
                luminance_high_list.append(sub_df['Luminance_high'].item())
                luminance_low_list.append(sub_df['Luminance_low'].item())
                Luminance_value_vrr_f[Observer_id, size_index, vrr_f_index] = sub_df['Luminance'].item()
            else:
                continue
        error_bar = np.array([luminance_list, luminance_high_list]) - np.array([luminance_low_list, luminance_list])
        if size_index == len(Size_list) - 1:
            plt.errorbar(vrr_f_list, np.array(luminance_list), yerr=error_bar, fmt='-o', label=f'Observer {Observer}')
        else:
            plt.errorbar(vrr_f_list, np.array(luminance_list), yerr=error_bar, fmt='-o')
        plt.xscale('log')
        plt.yscale('log')
        plt.xticks([0.5, 2, 4, 8, 10, 12, 14, 16], ['0.5', '2', '4', '8', '10', '12', '14', '16'])
        plt.yticks([0.5,1,2,5], ['0.5', '1', '2', '5'])
        plt.ylabel('Luminance')
        plt.xlim([0.4, 18])
        plt.ylim([0.4, 7])
        plt.title(f'Size {size_value}')
        plt.grid(True)
# plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.8), ncol=6)
plt.xlabel('VRR Frequency')

# 在这里再画平均值的那个
for size_index in range(len(Size_list)):
    size_value = Size_list[size_index]
    plt.subplot(len(Size_list), 2, 2*size_index+2)
    L_mean_array = np.nanmean(Luminance_value_vrr_f, axis=0)[size_index,:]
    plt.plot(vrr_f_ticks, L_mean_array, '-o', linewidth=4, label=f'Mean Luminance of All Observers')
    plt.xscale('log')
    plt.yscale('log')
    plt.xticks([0.5, 2, 4, 8, 10, 12, 14, 16], ['0.5', '2', '4', '8', '10', '12', '14', '16'])
    plt.yticks([0.5, 1, 2, 5], ['0.5', '1', '2', '5'])
    plt.xlim([0.4, 18])
    plt.ylim([0.4, 7])
    plt.title(f'Size {size_value}')
    plt.grid(True)

L_mean_dict = {'L_mean_list': np.nanmean(Luminance_value_vrr_f, axis=0).tolist(),
               'size_list': size_ticks,
               'vrr_f_list': vrr_f_ticks}

with open(os.path.join(Quest_exp_path, 'Luminance_mean.json'), 'w') as fp:
    json.dump(L_mean_dict, fp)

plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.8), ncol=3)
plt.xlabel('VRR Frequency')
plt.tight_layout()
plt.show()

