clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = logspace(log10(0.4), log10(16), 100);

S_IDMS = @(omega) abs(148.7 * ((1 + 2 * 1i * pi * omega * 0.00267).^(-15) - 0.882 * (1 + 2 * 1i * pi * omega * 1.834 * 0.00267).^(-16)));

initial_k = 1;

average_C_t_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(FRR_indices), length(size_indices)); %这些主观实验是否有效
Ct_results_IDMS_fit = zeros(length(FRR_indices), length(size_indices));
Ct_results_IDMS_plot = zeros(length(FRR_range), length(size_indices));
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
        average_C_t = nanmean(valid_data.C_t);
        high_C_t = nanmean(valid_data.C_t_high);
        low_C_t = nanmean(valid_data.C_t_low);
        average_C_t_matrix(FRR_i, size_i) = average_C_t;
        high_C_t_matrix(FRR_i, size_i) = high_C_t;
        low_C_t_matrix(FRR_i, size_i) = low_C_t;
        Ct_results_IDMS_fit(FRR_i,size_i) = 1/S_IDMS(FRR_value);
    end
end

%拟合阶段
options = optimset('Display', 'iter');
loss_function_IDMS = @(k_IDMS) loss_IDMS(k_IDMS, size_indices, FRR_indices, average_C_t_matrix, Ct_results_IDMS_fit);
lb = 1e-5;
ub = Inf;
[optimized_k_IDMS, fval] = fmincon(loss_function_IDMS, initial_k, [], [], [], [], lb, ub, [], options);

% optimized_k_IDMS = 1;
%正式运算阶段
for size_i = 1:length(size_indices)
    for FRR_i = 1:length(FRR_range)
        FRR_value = FRR_range(FRR_i);
        Ct_results_IDMS_plot(FRR_i,size_i) = 1/(optimized_k_IDMS*S_IDMS(FRR_value));
    end
end
%绘图阶段

figure;
ha = tight_subplot(1, 1, [.04 .02],[.12 .01],[.09 .00]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'XTick',FRR_indices); 
set(ha,'XTickLabel',FRR_indices);
xlim([0.4, 16]);
ylim([0.0002, 0.1]);
xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
ylabel('C_{thr} (Flicker Detection Contrast Threshold)','FontSize',14);
color = ['r', 'g', 'b', 'm'];
legend_plots = {};
legend_labels = {};
for size_i = 1:length(size_indices)
    error_upper = high_C_t_matrix(:, size_i) - average_C_t_matrix(:, size_i);
    error_lower = average_C_t_matrix(:, size_i) - low_C_t_matrix(:, size_i);
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
    % set(gca, 'YScale', 'log');
    legend_plots{end+1} = plot(FRR_indices, average_C_t_matrix(:, size_i), 'o-', 'Color', color(size_i), 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name);
    legend_labels{end+1} = display_name;
    if (size_i == 1)
        legend_plots{end+1} = errorbar(FRR_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
        legend_labels{end+1} = 'Psychometric function fitting error bar';
    else
        errorbar(FRR_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    end
    grid on;
end
legend_plots{end+1} = plot(FRR_range, Ct_results_IDMS_plot(:,1)/optimized_k_IDMS, '-', 'LineWidth', 3, 'Color', 'r', 'DisplayName', 'IDMS 1.1a TCSF C_{thr} Prediciton');
legend_labels{end+1} = 'IDMS 1.1a TCSF C_{thr} Prediciton';
hLegend = legend([legend_plots{1} legend_plots{3} legend_plots{4} legend_plots{5} legend_plots{2} legend_plots{6}], ...
    {legend_labels{1},legend_labels{3},legend_labels{4},legend_labels{5},legend_labels{2},legend_labels{6}},'FontSize',9);

function [loss] = loss_IDMS(k_IDMS, size_indices, FRR_indices, average_C_t_matrix, Ct_results_IDMS_fit)
    loss = 0;
    for size_i = 1:length(size_indices)
        for FRR_i = 1:length(FRR_indices)
            loss = loss + (log10(Ct_results_IDMS_fit(FRR_i,size_i)/k_IDMS)-log10(average_C_t_matrix(FRR_i,size_i)))^2;
        end
    end
end