% 计算某个数据的FFT
exp_log_path = 'E:\About_Cambridge\All Research Projects\Variable Refresh Rate\Subjective_Exp_1\Subjective_Exp_1';
luminance_index = 1;
size_index = 4;
vrr_f_index = 2;
repeat_index = 0;
file_name = fullfile(exp_log_path, sprintf('Luminance_%d_Size_%d_VRR_Frequency_%d', luminance_index, size_index, vrr_f_index), sprintf('%d.json', repeat_index));
exp_data = jsondecode(fileread(file_name));
x_time_array = exp_data.x_time;
y_luminance_array = exp_data.y_luminance_scale;
[x_freq_sub, K_FFT_sub] = compute_signal_FFT(x_time_array, y_luminance_array, 120, false, true, true);

freq_range = [0, 20];
valid_indices = x_freq_sub > freq_range(1) & x_freq_sub <= freq_range(2);
% 按照每个frequency计算sensitivity
csf_model = CSF_stelaCSF();
csf_pars = struct('s_frequency', 0.01, 't_frequency', x_freq_sub(valid_indices), 'orientation', 0, 'luminance', luminance_index, 'area', size_index, 'eccentricity', 0);
S = csf_model.sensitivity(csf_pars);

% 绘制图形
plot(x_freq_sub(valid_indices), S);
% set(gca, 'YScale', 'log');
xlabel('Frequency [Hz]');
ylabel('Sensitivity');


