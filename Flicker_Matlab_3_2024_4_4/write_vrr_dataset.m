clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
valids = zeros(length(FRR_indices), length(size_indices));
S_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_S_gather.csv';
data = readtable(S_subjective_path);

yancheng2024_csv = struct();
yancheng2024_csv.Radius = {};
yancheng2024_csv.Area = {};
yancheng2024_csv.FRR = {};
yancheng2024_csv.Luminance = {};
yancheng2024_csv.Sensitivity = {};
yancheng2024_csv.high_Sensitivity = {};
yancheng2024_csv.low_Sensitivity = {};

for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
    else
        area_value = pi*(size_value/2)^2;
        radius = size_value/2;
    end
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        % Subjective Experiment Result
        filtered_data = data(data.Size_Degree == size_value & data.FRR == FRR_value, :);
        if (height(filtered_data) >= 1)
            valids(FRR_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.Sensitivity), :);
        average_S = 10.^nanmean(log10(valid_data.Sensitivity));
        average_Luminance = 10.^nanmean(log10(valid_data.Luminance));
        high_S = 10.^nanmean(log10(valid_data.Sensitivity_low));
        low_S = 10.^nanmean(log10(valid_data.Sensitivity_high));

        yancheng2024_csv.Radius{end+1} = radius;
        yancheng2024_csv.Area{end+1} = area_value;
        yancheng2024_csv.FRR{end+1} = FRR_value;
        yancheng2024_csv.Luminance{end+1} = average_Luminance;
        yancheng2024_csv.Sensitivity{end+1} = average_S;
        yancheng2024_csv.high_Sensitivity{end+1} = high_S;
        yancheng2024_csv.low_Sensitivity{end+1} = low_S;
    end
end

yancheng2024_csv.Radius = yancheng2024_csv.Radius';
yancheng2024_csv.Area = yancheng2024_csv.Area';
yancheng2024_csv.FRR = yancheng2024_csv.FRR';
yancheng2024_csv.Luminance = yancheng2024_csv.Luminance';
yancheng2024_csv.Sensitivity = yancheng2024_csv.Sensitivity';
yancheng2024_csv.high_Sensitivity = yancheng2024_csv.high_Sensitivity';
yancheng2024_csv.low_Sensitivity = yancheng2024_csv.low_Sensitivity';

yancheng2024_table = struct2table(yancheng2024_csv);
writetable(yancheng2024_table, fullfile('E:\Matlab_codes\csf_datasets\raw_data\yancheng2024', 'yancheng2024_sensitivity_average.csv'));