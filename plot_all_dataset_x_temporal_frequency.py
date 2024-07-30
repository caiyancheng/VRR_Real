import json
import pandas as pd
import matplotlib.pyplot as plt
import os

dataset_json_path = r'E:\Matlab_codes\csf_datasets/datasets_yancheng.json'
csv_file_path = r'E:\Matlab_codes\csf_datasets/data_aggregated_merged_yancheng.csv'

with open(dataset_json_path, 'r') as fp:
    dataset_json_data = json.load(fp)
dataset_name_list = list(dataset_json_data['datasets'].keys())
dataset_name_list.sort()
datasets_csv_data = pd.read_csv(csv_file_path)

for dataset_index in range(len(dataset_name_list)):
    dataset_name = dataset_name_list[dataset_index]
    X = 1