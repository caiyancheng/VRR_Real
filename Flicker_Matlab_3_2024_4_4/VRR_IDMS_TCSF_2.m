clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = logspace(log10(0.4), log10(16), 100);

S_IDMS = @(omega) abs(148.7 * ((1 + 2 * 1i * pi * omega * 0.00267).^(-15) - 0.882 * (1 + 2 * 1i * pi * omega * 1.834 * 0.00267).^(-16)));

initial_k = 1;

average_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
high_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(FRR_indices), length(size_indices)); %这些主观实验是否有效
S_results_IDMS_fit = zeros(length(FRR_indices), length(size_indices));
S_results_IDMS_plot = zeros(length(FRR_range), length(size_indices));
c_t_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_S_gather.csv';
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
        valid_data = filtered_data(~isnan(filtered_data.Sensitivity), :);
        average_S = 10.^nanmean(log10(valid_data.Sensitivity));
        high_S = 10.^nanmean(log10(valid_data.Sensitivity_low));
        low_S = 10.^nanmean(log10(valid_data.Sensitivity_high));
        average_S_matrix(FRR_i, size_i) = average_S;
        high_S_matrix(FRR_i, size_i) = high_S;
        low_S_matrix(FRR_i, size_i) = low_S;
        S_results_IDMS_fit(FRR_i,size_i) = S_IDMS(FRR_value);
    end
end

%拟合阶段
options = optimset('Display', 'iter');
loss_function_IDMS = @(k_IDMS) loss_IDMS(k_IDMS, size_indices, FRR_indices, average_S_matrix, S_results_IDMS_fit);
lb = 1e-5;
ub = Inf;
[optimized_k_IDMS, fval] = fmincon(loss_function_IDMS, initial_k, [], [], [], [], lb, ub, [], options);

% optimized_k_IDMS = 1;
%正式运算阶段
for size_i = 1:length(size_indices)
    for FRR_i = 1:length(FRR_range)
        FRR_value = FRR_range(FRR_i);
        S_results_IDMS_plot(FRR_i,size_i) = S_IDMS(FRR_value)./optimized_k_IDMS;
    end
end
%绘图阶段

figure;
Y_labels = [10,20,50,100,200,500];

% Y_labels = log(Y_labels);
% high_S_matrix = log(high_S_matrix);
% average_S_matrix = log(average_S_matrix);
% low_S_matrix = log(low_S_matrix);
%  S_results_IDMS_plot = log(S_results_IDMS_plot);

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
hh(end+1) = plot(FRR_range, S_results_IDMS_plot(:,1), '-', 'LineWidth', 3, 'Color', 'r', 'DisplayName', 'IDMS 1.1a TCSF Sensitivity Prediciton');
hLegend = legend(hh,'FontSize',9);

function [loss] = loss_IDMS(k_IDMS, size_indices, FRR_indices, average_S_matrix, S_results_IDMS_fit)
    loss = 0;
    for size_i = 1:length(size_indices)
        for FRR_i = 1:length(FRR_indices)
            loss = loss + (log10(S_results_IDMS_fit(FRR_i,size_i)/k_IDMS)-log10(average_S_matrix(FRR_i,size_i)))^2;
        end
    end
end