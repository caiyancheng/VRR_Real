import matplotlib.pyplot as plt
import numpy as np
import os
import json
from tqdm import tqdm

Dataset_path = r'E:\Py_codes\VRR_Real\Datasets/VRR_interval_time_changeo_Formal'
Image_Data_path = os.path.join(Dataset_path, 'Images')
os.makedirs(Image_Data_path, exist_ok=True)
json_file_list = os.listdir(Dataset_path)

for file_index in tqdm(range(len(json_file_list))):
    if not json_file_list[file_index].endswith('.json'):
        continue
    with open(os.path.join(Dataset_path, json_file_list[file_index]), 'r') as fp:
        json_data = json.load(fp)
    x_time = json_data['x_time']
    y_luminance = json_data['y_luminance']
    fig = plt.figure(figsize=(100, 5))
    plt.plot(x_time, y_luminance)
    plt.ylim((0, 1))
    plt.xlabel('time(s)')
    plt.ylabel('Luminance')
    # plt.show()
    file_name = json_file_list[file_index].split('.json')[0]
    plt.savefig(os.path.join(Image_Data_path, f'{file_name}.png'))
    plt.close()