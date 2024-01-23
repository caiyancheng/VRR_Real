import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import json
import os

# Quest_exp_path = r'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4'
# Observer_list = ['Ale', 'Maliha', 'Yancheng_Cai', 'Ali', 'Shushan', 'Hongyun_Gao', 'Zhen', 'Yaru', 'Yuan', 'Claire', 'haoyu', 'pupu', 'Dounia', 'Jane']
Quest_exp_path = r'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_pro'
Observer_list = ['Yancheng_Cai', 'Hongyun_Gao', 'Tianbo_Liang']


plt.figure(figsize=(8,9))
for Observer in Observer_list:
    config_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'config.json')
    csv_result_path = os.path.join(Quest_exp_path, f'Observer_{Observer}_2', 'reorder_result_D_thr_C_t.csv')
    with open(config_path, 'r') as fp:
        config_data = json.load(fp)
    VRR_Frequency_list = config_data["change_parameters"]["VRR_Frequency"]
    Size_list = config_data["change_parameters"]["Size"]
    df = pd.read_csv(csv_result_path)
    for size_index in range(len(Size_list)):
        size_value = Size_list[size_index]
        plt.subplot(len(Size_list), 1, size_index+1)
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
            else:
                continue
        error_bar = np.array([luminance_list, luminance_high_list]) - np.array([luminance_low_list, luminance_list])
        plt.errorbar(vrr_f_list, np.array(luminance_list), yerr=error_bar, fmt='-o', label=f'Observer {Observer}')
        # 其他绘图参数，可以根据需要进行修改
        # plt.xlabel('VRR Frequency')
        plt.xticks([0.5, 2, 4, 8, 10, 12, 14, 16])
        plt.xscale('log')
        plt.yscale('log')
        plt.ylabel('Luminance')
        plt.xlim([0.4, 18])
        plt.ylim([0.3,7])
        plt.title(f'Size {size_value}')
        plt.grid(True)
        plt.legend()
plt.xlabel('VRR Frequency')
plt.tight_layout()
plt.show()

