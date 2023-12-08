exp_log_path = 'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1';
luminance_indices = [1, 2, 3, 4, 5, 10, 100];
size_indices = [4, 16];
vrr_f_indices = [2, 5, 10];
repeat_indices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

result_data_json = struct();
csv_data = cell(numel(luminance_indices) * numel(size_indices) * numel(vrr_f_indices) * numel(repeat_indices), 7);
index = 1;
for luminance_index = luminance_indices
    for size_index = size_indices
        for vrr_f_index = vrr_f_indices
            for repeat_index = repeat_indices
                file_name = fullfile(exp_log_path, sprintf('Luminance_%d_Size_%d_VRR_Frequency_%d', luminance_index, size_index, vrr_f_index), sprintf('%d.json', repeat_index));
                exp_data = jsondecode(fileread(file_name));
                x_time_array = exp_data.x_time;
                y_luminance_array = exp_data.y_luminance_scale;
                [x_freq_sub, K_FFT_sub] = compute_signal_FFT(x_time_array, y_luminance_array, 120, false, true, true);

                freq_range = [0, 120];
                valid_indices = x_freq_sub >= freq_range(1) & x_freq_sub <= freq_range(2);
                
                csf_model = CSF_stelaCSF();
                spatial_s = linspace( 0, 60 )';
                csf_pars = struct('s_frequency', 0.1, 't_frequency', x_freq_sub(valid_indices), 'orientation', 0, 'luminance', luminance_index, 'area', size_index, 'eccentricity', 0);
                S = csf_model.sensitivity(csf_pars);
                
                % 将结果保存到result_data结构中
                result_entry = struct('luminance_index', luminance_index, 'size_index', size_index, 'vrr_f_index', vrr_f_index, 'repeat_index', repeat_index, 'sensitivity', S);
                result_data_json = setfield(result_data_json, sprintf('result_luminance_%d_size_%d_vrr_f_%d_repeat_%d', luminance_index, size_index, vrr_f_index, repeat_index), result_entry);
                
                [~, flicker_vrr_frequency_indice] = min(abs(x_freq_sub - vrr_f_index));

                csv_data{index, 1} = luminance_index;
                csv_data{index, 2} = size_index;
                csv_data{index, 3} = vrr_f_index;
                csv_data{index, 4} = repeat_index;
                csv_data{index, 5} = S(flicker_vrr_frequency_indice,1);
                csv_data{index, 6} = max(S(2:end));
                csv_data{index, 7} = S(1,1);
                index = index + 1;
            end
        end
    end
end

% 将result_data保存为json文件
json_str = jsonencode(result_data_json);
json_file_path = 'sensitivity_results.json';
fid = fopen(json_file_path, 'w');
fprintf(fid, '%s', json_str);
fclose(fid);

% 将result_data保存为csv文件
csv_table = cell2table(csv_data, 'VariableNames', {'Luminance', 'Size', 'VRR_f', 'Repeat', 'S_VRR', 'S_max', 'S_0'});

% Save as CSV file
csv_file_path = 'sensitivity_results.csv';
writetable(csv_table, csv_file_path);
