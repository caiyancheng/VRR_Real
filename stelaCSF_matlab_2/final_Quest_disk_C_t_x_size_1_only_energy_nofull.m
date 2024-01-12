size_indices = [0.5, 1, 16]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
area_indices = zeros(size(size_indices));
num_obs = 1;
num_points = 1000;
beta = 3.5;
continuous_size_range = logspace(log10(0.3), log10(70), 10)';
continuous_area_range = zeros(size(continuous_size_range));
fit_poly_degree = 4;
area_fix = 1;
Luminance_lb = 0.05;
Luminance_ub = 10;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Energy)', 'stelaCSF_{mod} (Energy)', 'barten_{mod} (Energy)', ...
            'stelaCSF transient (Energy)', 'stelaCSF_{mod} transient (Energy)', ...
            'stelaCSF (Energy fix area)', 'stelaCSF_{mod} (Energy fix area)', 'barten_{mod} (Energy fix area)', ...
            'stelaCSF transient (Energy fix area)', 'stelaCSF_{mod} transient (Energy fix area)'};

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

CSF_results_fit = zeros(length(suffixes), length(vrr_f_indices), length(size_indices));
CSF_results_range = zeros(length(suffixes), length(vrr_f_indices), length(continuous_size_range));
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
peak_spatial_frequency = logspace(log10(0.2), log10(10), 100); %peak部分
% initial_E_thr_values = ones(10)' * 1000;
% initial_E_thr_values = [0.2074, 0.1991, 0.7065, 6.4205e-04, 2.4111e-04, 0.2603, 0.2499, 0.8811, 8.0630e-04, 3.0279e-04]';
% initial_E_thr_values = [0.225499639710616, 0.176807621389691, 1.133618092401632, 0.030043015925068, 0.006653541774230, 0.225499639710616, 0.176807621389691, 1.133618092401632, 0.030043015925068, 0.006653541774230]';
initial_E_thr_values = [0.224406315224329, 0.179647580685911, 0.967358821596143, 0.0300430158138094, 0.00665354138703247, 0.0541591637601433, 0.0389815376246871, 0.359728526944502, 0.00207145282326101,0.000440901594222934]';

optimize_need = 0;
csv_generate = 0;
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (62.666+37.808)/4;
        area_indices(size_i) = area_value;
    else
        area_value = pi*size_value^2;
        radius = size_value;
        area_indices(size_i) = area_value;
    end
    for vrr_f_i = 1:length(vrr_f_indices)
        vrr_f_value = vrr_f_indices(vrr_f_i);
        % Subjective Experiment Result
        filtered_data = data(data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
        if (height(filtered_data) >= 1)
            valids(vrr_f_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.C_t), :);
        average_C_t = mean(valid_data.C_t);
        high_C_t = mean(valid_data.C_t_high);
        low_C_t = mean(valid_data.C_t_low);

        
        average_C_t_matrix(vrr_f_i, size_i) = average_C_t;
        high_C_t_matrix(vrr_f_i, size_i) = high_C_t;
        low_C_t_matrix(vrr_f_i, size_i) = low_C_t;

        % [~,~,~,CSF_results_fit(1,vrr_f_i,size_i), CSF_results_fit(2,vrr_f_i,size_i), CSF_results_fit(3,vrr_f_i,size_i)] = ...
        %     final_contrast_energy_model(vrr_f_value, area_value, radius, initial_E_thr_values(1:3), fit_poly_degree);
        % [~,~,CSF_results_fit(4,vrr_f_i,size_i), CSF_results_fit(5,vrr_f_i,size_i)] = ...
        %     final_contrast_energy_model_transient(vrr_f_value, area_value, radius, initial_E_thr_values(4:5), fit_poly_degree);
        % [~,~,~,CSF_results_fit(6,vrr_f_i,size_i), CSF_results_fit(7,vrr_f_i,size_i), CSF_results_fit(8,vrr_f_i,size_i)] = ...
        %     final_contrast_energy_model_fix_area(vrr_f_value, radius, initial_E_thr_values(6:8), fit_poly_degree, area_fix);
        % [~,~,CSF_results_fit(9,vrr_f_i,size_i), CSF_results_fit(10,vrr_f_i,size_i)] = ...
        %     final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, initial_E_thr_values(9:10), fit_poly_degree, area_fix);
    end
end

% 拟合参数,尤其是那10个E
loss_multiple_factor = 1; %e10;

optimized_E_thr_values = zeros(10, 1);
fvals = zeros(10, 1);
lb = 0;  % 下界
ub = Inf; % 上界

if (optimize_need == 1)
    options = optimset('Display', 'iter');

    objective_function_1 = @(E_thr_value) final_stela_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_1 = objective_function_1(initial_E_thr_values(1));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_1(E_thr_value), initial_E_thr_values(1), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(1) = optimized_E_thr_value;
    fvals(1) = fval./loss_multiple_factor;

    objective_function_2 = @(E_thr_value) final_stela_mod_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_2 = objective_function_2(initial_E_thr_values(2));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_2(E_thr_value), initial_E_thr_values(2), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(2) = optimized_E_thr_value;
    fvals(2) = fval./loss_multiple_factor;

    objective_function_3 = @(E_thr_value) final_barten_mod_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_3 = objective_function_3(initial_E_thr_values(3));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_3(E_thr_value), initial_E_thr_values(3), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(3) = optimized_E_thr_value;
    fvals(3) = fval./loss_multiple_factor;

    objective_function_4= @(E_thr_value) final_stela_transient_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_4 = objective_function_4(initial_E_thr_values(4));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_4(E_thr_value), initial_E_thr_values(4), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(4) = optimized_E_thr_value;
    fvals(4) = fval./loss_multiple_factor;

    objective_function_5= @(E_thr_value) final_stela_mod_transient_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_5 = objective_function_5(initial_E_thr_values(5));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_5(E_thr_value), initial_E_thr_values(5), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(5) = optimized_E_thr_value;
    fvals(5) = fval./loss_multiple_factor;

    objective_function_6 = @(E_thr_value) final_stela_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_6 = objective_function_6(initial_E_thr_values(6));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_6(E_thr_value), initial_E_thr_values(6), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(6) = optimized_E_thr_value;
    fvals(6) = fval./loss_multiple_factor;

    objective_function_7 = @(E_thr_value) final_stela_mod_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_7 = objective_function_7(initial_E_thr_values(7));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_7(E_thr_value), initial_E_thr_values(7), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(7) = optimized_E_thr_value;
    fvals(7) = fval./loss_multiple_factor;

    objective_function_8 = @(E_thr_value) final_barten_mod_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_8 = objective_function_8(initial_E_thr_values(8));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_8(E_thr_value), initial_E_thr_values(8), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(8) = optimized_E_thr_value;
    fvals(8) = fval./loss_multiple_factor;

    objective_function_9= @(E_thr_value) final_stela_transient_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_9 = objective_function_9(initial_E_thr_values(9));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_9(E_thr_value), initial_E_thr_values(9), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(9) = optimized_E_thr_value;
    fvals(9) = fval./loss_multiple_factor;

    objective_function_10= @(E_thr_value) final_stela_mod_transient_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_10 = objective_function_10(initial_E_thr_values(10));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_10(E_thr_value), initial_E_thr_values(10), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(10) = optimized_E_thr_value;
    fvals(10) = fval./loss_multiple_factor;
    % writematrix(optimized_E_thr_values, 'optimized_E_thr_values.csv');
else
    optimized_E_thr_values = readmatrix('optimized_E_thr_values_x_size_1_nofull.csv');
end

if (csv_generate == 1)
    for vrr_f_i = 1:length(vrr_f_indices)
        vrr_f_value = vrr_f_indices(vrr_f_i);
        for size_range_i = 1:length(continuous_size_range)
            size_range_value = continuous_size_range(size_range_i);
            area_value = pi*size_range_value^2;
            continuous_area_range(size_range_i) = area_value;
            radius = size_range_value;
            [~,~,~,CSF_results_range(1,vrr_f_i,size_range_i), CSF_results_range(2,vrr_f_i,size_range_i), CSF_results_range(3,vrr_f_i,size_range_i)] = ...
                final_contrast_energy_model(vrr_f_value, area_value, radius, optimized_E_thr_values(1:3), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(4,vrr_f_i,size_range_i), CSF_results_range(5,vrr_f_i,size_range_i)] = ...
                final_contrast_energy_model_transient(vrr_f_value, area_value, radius, optimized_E_thr_values(4:5), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,~,CSF_results_range(6,vrr_f_i,size_range_i), CSF_results_range(7,vrr_f_i,size_range_i), CSF_results_range(8,vrr_f_i,size_range_i)] = ...
                final_contrast_energy_model_fix_area(vrr_f_value, radius, optimized_E_thr_values(6:8), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(9,vrr_f_i,size_range_i), CSF_results_range(10,vrr_f_i,size_range_i)] = ...
                final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, optimized_E_thr_values(9:10), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
        end
    end
    writematrix(CSF_results_range, 'CSF_results_range_x_size_1_nofull.csv');
    writematrix(continuous_area_range, 'continuous_area_range_nofull.csv');
else
    CSF_results_range_flat = readmatrix('CSF_results_range_x_size_1_nofull.csv');
    CSF_results_range = reshape(CSF_results_range_flat, [length(suffixes), length(vrr_f_indices), length(continuous_size_range)]);
    continuous_area_range = readmatrix('continuous_area_range_nofull.csv');
end

objective_function_6 = @(E_thr_value) final_stela_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
loss_initial_6 = objective_function_6(initial_E_thr_values(6));
% objective_function_10= @(E_thr_value) final_stela_mod_transient_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub).*loss_multiple_factor;
% loss_initial_10 = objective_function_10(initial_E_thr_values(10));

group_num = 4;
figure;
ha = tight_subplot(length(vrr_f_indices), group_num, [.04 .02],[.2 .03],[.05 .05]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'XTick',area_indices); 
formatted_area_indices = round(area_indices, 1);
set(ha,'XTickLabel',formatted_area_indices);
x_axis = area_indices;
x_axis_range = continuous_area_range;
y_lim_range = [0.001, 0.1];
for vrr_f_i = 1:length(vrr_f_indices)-1
    error_upper = high_C_t_matrix(vrr_f_i, :) - average_C_t_matrix(vrr_f_i, :);
    error_lower = average_C_t_matrix(vrr_f_i, :) - low_C_t_matrix(vrr_f_i, :);

    axes(ha(((vrr_f_i)-1)*group_num+1));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    ylabel('C_t (Detection Threshold)','FontSize',12);
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, reshape(CSF_results_range(1,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(2,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(3,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+2));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, reshape(CSF_results_range(4,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(5,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+3));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, reshape(CSF_results_range(6,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(7,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.8, 0.1], 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(8,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+4));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, reshape(CSF_results_range(9,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3);
    plot(x_axis_range, reshape(CSF_results_range(10,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3);
    grid on;
end

vrr_f_i = length(vrr_f_indices);
axes(ha(((vrr_f_i)-1)*group_num+1));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
hold on;
xlabel('Area (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylabel('C_t (Detection Threshold)','FontSize',12);
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, reshape(CSF_results_range(1,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3, 'DisplayName', suffixes{1});
plot(x_axis_range, reshape(CSF_results_range(2,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3, 'DisplayName', suffixes{2});
plot(x_axis_range, reshape(CSF_results_range(3,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3, 'DisplayName', suffixes{3});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+2));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
hold on;
xlabel('Area (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, reshape(CSF_results_range(4,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3, 'DisplayName', suffixes{4});
plot(x_axis_range, reshape(CSF_results_range(5,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3, 'DisplayName', suffixes{5});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+3));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
hold on;
xlabel('Area (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, reshape(CSF_results_range(6,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3,'DisplayName', suffixes{6});
plot(x_axis_range, reshape(CSF_results_range(7,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.8, 0.1], 'MarkerSize', 3, 'DisplayName', suffixes{7});
plot(x_axis_range, reshape(CSF_results_range(8,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3, 'DisplayName', suffixes{8});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+4));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)), ' Hz']);
hold on;
xlabel('Area (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, reshape(CSF_results_range(9,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3, 'DisplayName', suffixes{9});
plot(x_axis_range, reshape(CSF_results_range(10,vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3, 'DisplayName', suffixes{10});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

hold off;