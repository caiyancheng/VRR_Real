import matplotlib.pyplot as plt
import numpy as np
import json

gather_result_path = r'E:\Datasets\RD-80SA/2024-4-14_gather_result_2.json'
with open(gather_result_path, 'r') as fp:
    gather_result_data = json.load(fp)

L_list = gather_result_data['L_list']
dL_list = gather_result_data['dL_list']
change_parameters = gather_result_data['change_parameters']
color_values = np.linspace(change_parameters['Color_Value_adjust_range'][0],
                           change_parameters['Color_Value_adjust_range'][1],
                           num=change_parameters['Color_sample_numbers'])
ff_dict = gather_result_data['ff_dict']

length = 10
index = 0
plt.figure(figsize=(7,6))
for vrr_f in change_parameters['VRR_Frequency']:
    for size in change_parameters['Size']:
        L_plot_array = np.array(L_list[index * length:(index + 1) * length])
        dL_plot_array = np.array(dL_list[index * length:(index + 1) * length])
        contrast_plot_list = dL_plot_array / L_plot_array
        plt.plot(L_plot_array, contrast_plot_list, label=f'vrr_f = {vrr_f}, size = {size}')
        index += 1
plt.xscale('log')
plt.yscale('log')
plt.ylim([0.001,1])
plt.xticks([0.5, 1, 2, 4, 8], [0.5, 1, 2, 4, 8])
plt.subplots_adjust(left=0.1, bottom=0.35, right=0.99, top=0.99)
plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.5), ncol=3)
plt.xlabel('Luminance')
plt.ylabel('Contrast')
plt.show()

index = 0
plt.figure(figsize=(7,6))
for vrr_f in change_parameters['VRR_Frequency']:
    for size in change_parameters['Size']:
        L_plot_array = np.array(L_list[index * length:(index + 1) * length])
        dL_plot_array = np.array(dL_list[index * length:(index + 1) * length])
        contrast_plot_list = dL_plot_array / L_plot_array
        plt.plot(L_plot_array, dL_plot_array, label=f'vrr_f = {vrr_f}, size = {size}')
        index += 1
plt.xscale('log')
plt.xticks([0.5, 1, 2, 4, 8], [0.5, 1, 2, 4, 8])
plt.subplots_adjust(left=0.1, bottom=0.35, right=0.99, top=0.99)
plt.legend(loc='lower center', bbox_to_anchor=(0.5, -0.5), ncol=3)
plt.xlabel('Luminance')
plt.ylabel('delta Luminance')
plt.show()

# Please check the Matlab Code for the fitting function