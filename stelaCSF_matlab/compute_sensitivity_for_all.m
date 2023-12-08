exp_log_path = 'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1';
luminance_indices = [1, 2, 3, 4, 5, 10, 100];
size_indices = [4, 16];
vrr_f_indices = [2, 5, 10];
repeat_indices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

result_data_json = struct();
csv_data = cell(numel(luminance_indices) * numel(size_indices) * numel(vrr_f_indices) * numel(repeat_indices), 5);
index = 1;
csf_model = CSF_stelaCSF();
t_frequency = linspace( 0, 240 ,1000)';
s_frequency = linspace(0, 60, 1000)';
h = waitbar(0, 'Processing...');
total_iterations = numel(luminance_indices) * numel(size_indices) * numel(vrr_f_indices) * numel(repeat_indices);
for luminance_index = luminance_indices
    for size_index = size_indices
        for vrr_f_index = vrr_f_indices
            for repeat_index = repeat_indices
                csf_model = CSF_stelaCSF();                
                S_t_values = zeros(size(t_frequency));
                for t_frequency_index = 1:length(t_frequency)                    
                    csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency(t_frequency_index), 'orientation', 0, 'luminance', luminance_index, 'area', size_index, 'eccentricity', 0);
                    S = csf_model.sensitivity(csf_pars);
                    % plot( s_frequency, S );
                    % xlabel( 'Spatial frequency [cpd]' );
                    % ylabel( 'Sensitivity' );
                    S_max = max(S);
                    S_t_values(t_frequency_index) = S_max;
                end
                
                plot(t_frequency,S_t_values);
                xlabel( 'Temporal frequency [Hz]' );
                ylabel( 'Sensitivity (Spatial Max)' );

                result_entry = struct('luminance_index', luminance_index, 'size_index', size_index, 'vrr_f_index', vrr_f_index, 'repeat_index', repeat_index, 'sensitivity', S_t_values);
                result_data_json = setfield(result_data_json, sprintf('result_luminance_%d_size_%d_vrr_f_%d_repeat_%d', luminance_index, size_index, vrr_f_index, repeat_index), result_entry);
                
                [~, flicker_vrr_frequency_indice] = min(abs(t_frequency - vrr_f_index));

                csv_data{index, 1} = luminance_index;
                csv_data{index, 2} = size_index;
                csv_data{index, 3} = vrr_f_index;
                csv_data{index, 4} = repeat_index;
                csv_data{index, 5} = S_t_values(flicker_vrr_frequency_indice,1);
                index = index + 1;

                waitbar(index / total_iterations, h, sprintf('Processing... %.2f%%', index / total_iterations * 100));
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
csv_table = cell2table(csv_data, 'VariableNames', {'Luminance', 'Size', 'VRR_f', 'Repeat', 'S_VRR'});

% Save as CSV file
csv_file_path = 'sensitivity_results.csv';
writetable(csv_table, csv_file_path);
