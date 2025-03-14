clear all;
clc;

% size_indices = [0.5, 1, 16, -1]; %-1 means full
size_indices = [0.5,1,16,-1];
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];

average_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
% std_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
high_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(FRR_indices), length(size_indices)); %这些主观实验是否有效
S_subjective_path = 'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_S_gather.csv';
data = readtable(S_subjective_path);
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
        filtered_data = data(data.Size_Degree == size_value & data.FRR == FRR_value, :);
        if (height(filtered_data) >= 1)
            valids(FRR_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.Sensitivity), :);
        average_S = 10.^nanmean(log10(valid_data.Sensitivity));
        % std_S = 10.^(nanstd(log10(valid_data.Sensitivity)) / sqrt(nansum(valid_data.Sensitivity.^0)));
        average_S_matrix(FRR_i, size_i) = average_S;
        % std_S_matrix(FRR_i, size_i) = std_S;
        high_S = 10.^nanmean(log10(valid_data.Sensitivity_high));
        low_S = 10.^nanmean(log10(valid_data.Sensitivity_low));
        high_S_matrix(FRR_i, size_i) = high_S;
        low_S_matrix(FRR_i, size_i) = low_S;
    end
end

Y_labels = [10,20,50,100,200,500,1000];
figure('Position',[100,100,600,400]);
ha = tight_subplot(1, 1, [.04 .02],[.12 .01],[.1 .01]);

set(ha,'YTick',Y_labels);
set(ha,'YTickLabel',Y_labels);
set(ha,'XTick',FRR_indices);
set(ha,'XTickLabel',FRR_indices);
xlim([0, 16]);
ylim([min(Y_labels),max(Y_labels)]);
xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
ylabel('Sensitivity','FontSize',14);
color = ['r', 'g', 'c', 'b'];
hh = [];
for size_i = 1:length(size_indices)
    error_upper = high_S_matrix(:, size_i) - average_S_matrix(:, size_i);
    error_lower = average_S_matrix(:, size_i) - low_S_matrix(:, size_i);
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
        display_name_gt = 'full screen: 62.7^{\circ}*37.8^{\circ}';
    else
        area_value = pi*size_value^2;
        radius = size_value;
        display_name_gt = ['disk diameter: ' num2str(size_value) '^{\circ}'];
    end
    hold on;
    % set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    hh(end+1) = plot(FRR_indices, average_S_matrix(:, size_i), 'o--', 'Color', color(size_i), 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name_gt);
    % ci95 = 1.96 .* std_S_matrix(:, size_i);
    % hh(end+1) = errorbar(FRR_indices, average_S_matrix(:, size_i), ci95./2, ci95./2, ...
    %     'LineStyle', 'none', 'Color', color(size_i), 'LineWidth', 1.0, ...
    %     'DisplayName', display_name_gt);
    errorbar(FRR_indices, average_S_matrix(:, size_i), error_lower, error_upper, ...
        'LineStyle', 'none', 'Color', color(size_i), 'LineWidth', 1.0, ...
        'DisplayName', display_name_gt);
    grid on;
end
lgd = legend(hh,'FontSize',9);
lgd.Position = [0.3, 0.2, 0.2, 0.1];