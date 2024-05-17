clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = logspace(log10(0.4), log10(16), 100);

initial_k = 1;

Luminance_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
c_t_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);

coeff_struct = struct();
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
    else
        area_value = pi*(size_value/2)^2;
        radius = size_value/2;
    end
    FRR_list_fit = [];
    Log_Luminance_List_fit = [];
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        % Subjective Experiment Result
        filtered_data = data(data.Size_Degree == size_value & data.FRR == FRR_value, :);
        if (height(filtered_data) >= 1)
            valids(FRR_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.Luminance), :);
        average_Luminance = 10.^(nanmean(log10(valid_data.Luminance)));
        Luminance_matrix(FRR_i, size_i) = average_Luminance;
        FRR_list_fit(end+1) = FRR_value;
        Log_Luminance_List_fit(end+1) = log10(average_Luminance);
    end
    X = FRR_list_fit;
    if size_value == 0.5
        coeff_struct.size_05_3d = polyfit(X, Log_Luminance_List_fit, 3);
        coeff_struct.size_05_4d = polyfit(X, Log_Luminance_List_fit, 4);
        coeff_struct.size_05_5d = polyfit(X, Log_Luminance_List_fit, 5);
        coeff_struct.size_05_6d = polyfit(X, Log_Luminance_List_fit, 6);
        coeff_struct.size_05_7d = polyfit(X, Log_Luminance_List_fit, 7);
    elseif size_value == 1
        coeff_struct.size_1_3d = polyfit(X, Log_Luminance_List_fit, 3);
        coeff_struct.size_1_4d = polyfit(X, Log_Luminance_List_fit, 4);
        coeff_struct.size_1_5d = polyfit(X, Log_Luminance_List_fit, 5);
        coeff_struct.size_1_6d = polyfit(X, Log_Luminance_List_fit, 6);
        coeff_struct.size_1_7d = polyfit(X, Log_Luminance_List_fit, 7);
    elseif size_value == 16
        coeff_struct.size_16_3d = polyfit(X, Log_Luminance_List_fit, 3);
        coeff_struct.size_16_4d = polyfit(X, Log_Luminance_List_fit, 4);
        coeff_struct.size_16_5d = polyfit(X, Log_Luminance_List_fit, 5);
        coeff_struct.size_16_6d = polyfit(X, Log_Luminance_List_fit, 6);
        coeff_struct.size_16_7d = polyfit(X, Log_Luminance_List_fit, 7);
    elseif size_value == -1
        coeff_struct.size_full_3d = polyfit(X, Log_Luminance_List_fit, 3);
        coeff_struct.size_full_4d = polyfit(X, Log_Luminance_List_fit, 4);
        coeff_struct.size_full_5d = polyfit(X, Log_Luminance_List_fit, 5);
        coeff_struct.size_full_6d = polyfit(X, Log_Luminance_List_fit, 6);
        coeff_struct.size_full_7d = polyfit(X, Log_Luminance_List_fit, 7);
    end
end

save_json_file_path = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/VRR_dataset_get_Luminance_FRR.json';
fid = fopen(save_json_file_path, 'w');
fwrite(fid, jsonencode(coeff_struct));
fclose(fid);