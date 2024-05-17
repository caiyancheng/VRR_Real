clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
% FRR_range = logspace(log10(0.4), log10(16), 100);
FRR_range = linspace(0.4,16,100);

% TCSF_1_initial_params = [148.7, 0.00267, 1.834, 0.882, 15, 16, 1];
% TCSF_2_initial_params = [4, 0.1898, 0.12314, 1];
TCSF_1_initial_params = [1.206494268005055e+03,0.004946350076709,0.899971409487429,0.994378031088784,50.317581995766820,56.112268500568250,0.123248028973880];
TCSF_2_initial_params = [7.612559044788514,1.063191842134452,34.195198652487434,0.423593054194143];
% TCSF_5_initial_params = [0.1, 0.2, 8, 0.5, 2, 100];
TCSF_7_initial_params = [6, 5.5, 8, 0.005, 10, 10];

% TCSF_1_initial_k = 1;
% TCSF_2_initial_k = 1;

average_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
high_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(FRR_indices), length(size_indices)); %这些主观实验是否有效
S_results_TCSF_1_plot = zeros(length(FRR_indices), length(size_indices));
S_results_TCSF_2_plot = zeros(length(FRR_range), length(size_indices));
S_results_TCSF_7_plot = zeros(length(FRR_range), length(size_indices));
c_t_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
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
        valid_data = filtered_data(~isnan(filtered_data.C_t), :);
        average_S = 10.^nanmean(log10(1 ./ valid_data.C_t));
        high_S = 10.^nanmean(log10(1 ./ valid_data.C_t_low));
        low_S = 10.^nanmean(log10(1 ./ valid_data.C_t_high));
        average_S_matrix(FRR_i, size_i) = average_S;
        high_S_matrix(FRR_i, size_i) = high_S;
        low_S_matrix(FRR_i, size_i) = low_S;
    end
end

%拟合阶段
options = optimset('Display', 'iter');
loss_function_TCSF_1 = @(params) VRR_TCSF_1_loss_function(size_indices, FRR_indices, average_S_matrix, params);
loss_function_TCSF_2 = @(params) VRR_TCSF_2_loss_function(size_indices, FRR_indices, average_S_matrix, params);
loss_function_TCSF_7 = @(params) VRR_TCSF_7_loss_function(size_indices, FRR_indices, average_S_matrix, params);
[TCSF_1_optimized_params, loss_1] = fminunc(loss_function_TCSF_1, log(TCSF_1_initial_params), options);
[TCSF_2_optimized_params, loss_2] = fminunc(loss_function_TCSF_2, log(TCSF_2_initial_params), options);
[TCSF_7_optimized_params, loss_7] = fminunc(loss_function_TCSF_7, log(TCSF_7_initial_params), options);

TCSF_1_optimized_params = exp(TCSF_1_optimized_params);
TCSF_2_optimized_params = exp(TCSF_2_optimized_params);
TCSF_7_optimized_params = exp(TCSF_7_optimized_params);
% optimized_k_IDMS = 1;
%正式运算阶段
for size_i = 1:length(size_indices)
    for FRR_i = 1:length(FRR_range)
        FRR_value = FRR_range(FRR_i);
        S_results_TCSF_1_plot(FRR_i,size_i) = S_TCSF_1(TCSF_1_optimized_params(1:6), FRR_value)./TCSF_1_optimized_params(7);
        S_results_TCSF_2_plot(FRR_i,size_i) = S_TCSF_2(TCSF_2_optimized_params(1:3), FRR_value)./TCSF_2_optimized_params(4);
        S_results_TCSF_7_plot(FRR_i,size_i) = S_TCSF_7(TCSF_7_optimized_params(1:6), FRR_value);
    end
end
%绘图阶段

figure;
Y_labels = [1,10,20,50,100,200,500,1000,2000];
ha = tight_subplot(1, 1, [.04 .02],[.12 .01],[.09 .00]);
set(ha,'YTick',Y_labels); 
set(ha,'YTickLabel',Y_labels); 
set(ha,'XTick',FRR_indices); 
set(ha,'XTickLabel',FRR_indices);
xlim([0.4, 16]);
ylim([min(Y_labels),max(Y_labels)]);
xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
ylabel('Sensitivity','FontSize',14);
color = ['r', 'g', 'b', 'm'];
hh = [];
for size_i = 1:length(size_indices)
    error_upper = high_S_matrix(:, size_i) - average_S_matrix(:, size_i);
    error_lower = average_S_matrix(:, size_i) - low_S_matrix(:, size_i);
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
        display_name = 'Subjective Psychophysical Result - Size: 62.7^{\circ}*37.8^{\circ}';
    else
        area_value = pi*size_value^2;
        radius = size_value;
        display_name = ['Subjective Psychophysical Result - Size: disk radius ' num2str(size_value) '^{\circ}'];
    end
    hold on;
    % set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    hh(end+1) = plot(FRR_indices, average_S_matrix(:, size_i), 'o-', 'Color', color(size_i), 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name);
    if (size_i == 1)
        hh(end+1) = errorbar(FRR_indices, average_S_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
    else
        errorbar(FRR_indices, average_S_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    end
    grid on;
end
hh(end+1) = plot(FRR_range, S_results_TCSF_1_plot(:,1), '-', 'LineWidth', 3, 'Color', 'r', 'DisplayName', 'IDMS 1.1a TCSF Sensitivity Prediciton');
hh(end+1) = plot(FRR_range, S_results_TCSF_2_plot(:,1), '-', 'LineWidth', 3, 'Color', 'g', 'DisplayName', 'Transient Channel TCSF Sensitivity Prediciton');
hh(end+1) = plot(FRR_range, S_results_TCSF_7_plot(:,1), '-', 'LineWidth', 3, 'Color', 'b', 'DisplayName', 'TCSF-6');
legend(hh,'FontSize',9);