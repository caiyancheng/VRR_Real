size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
beta = 3.5;
continuous_vrr_f_range = logspace(log10(0.25), log10(10), 100)';
fit_poly_degree = 4;
area_fix = 1;
Luminance_lb = 0.05;
Luminance_ub = 8;
beta = 3.5;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Fundamental Frequency)', 'stelaCSF_{HF} (Fundamental Frequency)', 'BartenCSF_{HF} (Fundamental Frequency)', ...
            'stelaCSF transient (Fundamental Frequency)', 'stelaCSF_{HF} transient (Fundamental Frequency)', ...
            'stelaCSF (Peak)', 'stelaCSF_{HF} (Peak)', 'BartenCSF_{HF} (Peak)', ...
            'stelaCSF transient (Peak)', 'stelaCSF_{HF} transient (Peak)'};

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

Ct_results_range = zeros(length(suffixes), length(continuous_vrr_f_range), length(size_indices));
L_thr_results_range = zeros(length(suffixes), length(continuous_vrr_f_range), length(size_indices));
average_Luminance_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
peak_spatial_frequency = logspace(log10(0.5), log10(10), 100)'; %peak部分
initial_k_scale_values = [1.6544, 1.7040, 1.0257, 21.9889, 35.8821, 0.8539, 0.8676, 0.5272, 20.2182, 32.9925]';


optimize_need = 0;
csv_generate = 0;
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (62.666+37.808)/4;
    else
        area_value = pi*size_value^2;
        radius = size_value;
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
        average_Luminance_matrix = mean(valid_data.Luminance);
        average_C_t = mean(valid_data.C_t);
        high_C_t = mean(valid_data.C_t_high);
        low_C_t = mean(valid_data.C_t_low);
        average_C_t_matrix(vrr_f_i, size_i) = average_C_t;
        high_C_t_matrix(vrr_f_i, size_i) = high_C_t;
        low_C_t_matrix(vrr_f_i, size_i) = low_C_t;
    end
end

% 拟合参数,尤其是那10个E
loss_multiple_factor = 1; %e10;

optimized_k_scale_values = zeros(length(suffixes), 1);
fvals = zeros(length(suffixes), 1);
lb = 0;  % 下界
ub = Inf; % 上界

if (optimize_need == 1)
    options = optimset('Display', 'iter');

    objective_function_1 = @(k_scale) final_stela_ff_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_1 = objective_function_1(initial_k_scale_values(1));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_1(k_scale), initial_k_scale_values(1), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(1) = optimized_k_scale_value;
    fvals(1) = fval./loss_multiple_factor;

    objective_function_2 = @(k_scale) final_stela_mod_ff_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_2 = objective_function_2(initial_k_scale_values(2));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_2(k_scale), initial_k_scale_values(2), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(2) = optimized_k_scale_value;
    fvals(2) = fval./loss_multiple_factor;

    objective_function_3 = @(k_scale) final_barten_mod_ff_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_3 = objective_function_3(initial_k_scale_values(3));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_3(k_scale), initial_k_scale_values(3), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(3) = optimized_k_scale_value;
    fvals(3) = fval./loss_multiple_factor;

    objective_function_4= @(k_scale) final_stela_transient_ff_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_4 = objective_function_4(initial_k_scale_values(4));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_4(k_scale), initial_k_scale_values(4), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(4) = optimized_k_scale_value;
    fvals(4) = fval./loss_multiple_factor;

    objective_function_5= @(k_scale) final_stela_mod_transient_ff_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub).*loss_multiple_factor;
    loss_initial_5 = objective_function_5(initial_k_scale_values(5));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_5(k_scale), initial_k_scale_values(5), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(5) = optimized_k_scale_value;
    fvals(5) = fval./loss_multiple_factor;

    objective_function_6 = @(k_scale) final_stela_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency).*loss_multiple_factor;
    loss_initial_6 = objective_function_6(initial_k_scale_values(6));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_6(k_scale), initial_k_scale_values(6), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(6) = optimized_k_scale_value;
    fvals(6) = fval./loss_multiple_factor;

    objective_function_7 = @(k_scale) final_stela_mod_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency).*loss_multiple_factor;
    loss_initial_7 = objective_function_7(initial_k_scale_values(7));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_7(k_scale), initial_k_scale_values(7), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(7) = optimized_k_scale_value;
    fvals(7) = fval./loss_multiple_factor;

    objective_function_8 = @(k_scale) final_barten_mod_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency).*loss_multiple_factor;
    loss_initial_8 = objective_function_8(initial_k_scale_values(8));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_8(k_scale), initial_k_scale_values(8), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(8) = optimized_k_scale_value;
    fvals(8) = fval./loss_multiple_factor;

    objective_function_9= @(k_scale) final_stela_transient_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency).*loss_multiple_factor;
    loss_initial_9 = objective_function_9(initial_k_scale_values(9));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_9(k_scale), initial_k_scale_values(9), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(9) = optimized_k_scale_value;
    fvals(9) = fval./loss_multiple_factor;

    objective_function_10= @(k_scale) final_stela_mod_transient_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency).*loss_multiple_factor;
    loss_initial_10 = objective_function_10(initial_k_scale_values(10));
    [optimized_k_scale_value, fval] = fmincon(@(k_scale) objective_function_10(k_scale), initial_k_scale_values(10), [], [], [], [], lb, ub, [], options);
    optimized_k_scale_values(10) = optimized_k_scale_value;
    fvals(10) = fval./loss_multiple_factor;

    writematrix(optimized_k_scale_values, 'optimized_k_scale_values_x_vrr_f_1_F_P.csv');
    writematrix(fvals, 'fvals_x_vrr_f_1_F_P.csv');
else
    optimized_k_scale_values = readmatrix('optimized_k_scale_values_x_vrr_f_1_F_P.csv');
end

if (csv_generate == 1)
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (37.808+62.666)/4;
        else
            area_value = pi*size_value^2;
            radius = size_value;
        end
        for vrr_f_range_i = 1:length(continuous_vrr_f_range)
            vrr_f_range_value = continuous_vrr_f_range(vrr_f_range_i);
            [L_thr_ff_stela, Ct_results_range(1, vrr_f_range_i, size_i)] = final_ff_stela(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(1), fit_poly_degree, Luminance_lb, Luminance_ub);
            [L_thr_ff_stela_mod, Ct_results_range(2, vrr_f_range_i, size_i)] = final_ff_stela_mod(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(2), fit_poly_degree, Luminance_lb, Luminance_ub);
            [L_thr_ff_barten_mod, Ct_results_range(3, vrr_f_range_i, size_i)] = final_ff_barten_mod(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(3), fit_poly_degree, Luminance_lb, Luminance_ub);
            [L_thr_ff_stela_transient, Ct_results_range(4, vrr_f_range_i, size_i)] = final_ff_stela_transient(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(4), fit_poly_degree, Luminance_lb, Luminance_ub);
            [L_thr_ff_stela_mod_transient, Ct_results_range(5, vrr_f_range_i, size_i)] = final_ff_stela_mod_transient(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(5), fit_poly_degree, Luminance_lb, Luminance_ub);
            [L_thr_peak_stela, Ct_results_range(6, vrr_f_range_i, size_i)] = final_peak_stela(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(6), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
            [L_thr_peak_stela_mod, Ct_results_range(7, vrr_f_range_i, size_i)] = final_peak_stela_mod(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(7), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
            [L_thr_peak_barten_mod, Ct_results_range(8, vrr_f_range_i, size_i)] = final_peak_barten_mod(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(8), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
            [L_thr_peak_stela_transient, Ct_results_range(9, vrr_f_range_i, size_i)] = final_peak_stela_transient(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(9), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
            [L_thr_peak_stela_mod_transient, Ct_results_range(10, vrr_f_range_i, size_i)] = final_peak_stela_mod_transient(vrr_f_range_value, ...
                area_value, radius, optimized_k_scale_values(10), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
        end
    end
    writematrix(Ct_results_range, 'Ct_results_range_x_vrr_f_1_F_P.csv');
else
    Ct_results_range_flat = readmatrix('Ct_results_range_x_vrr_f_1_F_P.csv');
    Ct_results_range = reshape(Ct_results_range_flat, [length(suffixes), length(continuous_vrr_f_range), length(size_indices)]);
end

[L_thr, Ct] = final_peak_stela_transient(0.5, pi*0.5^2, 0.5, optimized_k_scale_values(8), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);

figure;
ha = tight_subplot(2, 5, [.07 .02],[.11 .03],[.035 .001]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'XTick',[0.5, 1, 2, 4, 8]); 
set(ha,'XTickLabel',[0.5, 1, 2, 4, 8]);
for plot_i = 1:length(suffixes)
    axes(ha(plot_i));
    xlim([0.25, 10]);
    ylim([0.001, 0.1]);
    if (plot_i == 6)
        ylabel('              C_{thr} (Flicker Detection Contrast Threshold)','FontSize',18);
    end
    if (plot_i == 8)
        xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',18);
    end
    title(suffixes(plot_i),'FontSize',13);
    color = ['r', 'g', 'b', 'm'];
    legend_exp_plots = {};
    legend_errorbar_plots = {};
    legend_model_plots = {};
    legend_exp_labels = {};
    legend_errorbar_labels = {};
    legend_model_labels = {};

    for size_i = 1:length(size_indices)
        error_upper = high_C_t_matrix(:, size_i) - average_C_t_matrix(:, size_i);
        error_lower = average_C_t_matrix(:, size_i) - low_C_t_matrix(:, size_i);
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (62.666+37.808)/4;
            display_name_exp = 'Subjective Psychophysical Result - Size: full screen 62.7^{\circ}*37.8^{\circ}';
            display_name_model = 'Model Predicition - Size: full screen 62.7^{\circ}*37.8^{\circ}';
        else
            area_value = pi*size_value^2;
            radius = size_value;
            display_name_exp = ['Subjective Psychophysical Result - Size: disk radius ' num2str(size_value) '^{\circ}'];
            display_name_model = ['Model Predicition - Size: disk radius ' num2str(size_value) '^{\circ}'];
        end
        hold on;
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        legend_exp_plots{end+1} = scatter(vrr_f_indices, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', color(size_i), 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', display_name_exp);
        legend_exp_labels{end+1} = display_name_exp;
        if (size_i == 1)
            legend_errorbar_plots{end+1} = errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
            legend_errorbar_labels{end+1} = 'Psychometric function fitting error bar';
        else
            errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
        end
    legend_model_plots{end+1} = plot(continuous_vrr_f_range, Ct_results_range(plot_i,:,size_i), '-', 'LineWidth', 1, 'Color', color(size_i), 'DisplayName', display_name_model);
    legend_model_labels{end+1} = display_name_model;
    grid on;
    end
end

hLegend_2 = legend([legend_exp_plots{1} legend_exp_plots{2} legend_exp_plots{3} legend_exp_plots{4} legend_errorbar_plots{1} ...
                      legend_model_plots{1} legend_model_plots{2} legend_model_plots{3} legend_model_plots{4}], ...
                     {legend_exp_labels{1} legend_exp_labels{2} legend_exp_labels{3} legend_exp_labels{4} legend_errorbar_labels{1} ...
                      legend_model_labels{1} legend_model_labels{2} legend_model_labels{3} legend_model_labels{4}},'FontSize',14);
set(hLegend_2, 'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 5); 
legendPos = get(hLegend_2, 'Position');
legendPos(1) = 0.5 - legendPos(3)/2;
legendPos(2) = 0.03 - legendPos(4)/2;
set(hLegend_2, 'Position', legendPos);
