size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 2, 4, 8];
num_obs = 1;
num_points = 1000;
continuous_area_range = logspace(log10(pi*0.25^2*0.5), log10(62.666 * 37.808* 2), 30)';
fit_poly_degree = 4;
area_fix = 1;
Luminance_lb = 0.05;
Luminance_ub = 8;
beta = 3.5;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Original Energy)', 'stelaCSF_{HF} (Original Energy)', 'BartenCSF_{HF} (Original Energy)', ...
            'stelaCSF transient (Original Energy)', 'stelaCSF_{HF} transient (Original Energy)', ...
            'stelaCSF (Fixed Area Energy)', 'stelaCSF_{HF} (Fixed Area Energy)', 'BartenCSF_{HF} (Fixed Area Energy)', ...
            'stelaCSF transient (Fixed Area Energy)', 'stelaCSF_{HF} transient (Fixed Area Energy)', ...
            'stelaCSF (Multiple Contrast Energy Detectors)', 'stelaCSF_{HF} (Multiple Contrast Energy Detectors)', 'BartenCSF_{HF} (Multiple Contrast Energy Detectors)', ...
            'stelaCSF transient (Multiple Contrast Energy Detectors)', 'stelaCSF_{HF} transient (Multiple Contrast Energy Detectors)'};

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

CSF_results_fit = zeros(length(suffixes), length(vrr_f_indices), length(size_indices));
CSF_results_range = zeros(length(suffixes), length(vrr_f_indices), length(continuous_area_range));
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
peak_spatial_frequency = logspace(log10(0.2), log10(10), 100); %peak部分
% initial_E_thr_values = [0.271706705875821, 0.175973530164629, 1.10003922892297, 0.0299723852245313, 0.00621610615086627,
%                         0.0369594192529463, 0.0287812693120049, 0.319297144564044, 0.00196439278857942, 0.000629376515490757,
%                         0.0877530770189669, 0.0707837284360293, 0.797774332855692, 0.00407515851336185, 0.00154290482096361]';
initial_E_thr_values = [0.0879564797756015, 0.0617083099563919, 0.573718037423824, 0.0104689126669445, 0.00418767159769479, ...
                        0.0306915456691477, 0.0220186285505276, 0.309201910736347, 0.00195401829407029, 0.000687836911491976, ...
                        0.0632047075249338, 0.0465713761219498, 0.652100104749209, 0.00354172172379515, 0.0014549445237725]';


optimize_need = 0;
csv_generate = 1;
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (62.666+37.808)/4;
    else
        radius = size_value/2;
        area_value = pi*radius^2;
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
    end
end

% 拟合参数,尤其是那10个E
loss_multiple_factor = 1; %e10;

optimized_E_thr_values = zeros(length(suffixes), 1);
fvals = zeros(length(suffixes), 1);
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

    objective_function_11 = @(E_thr_value) final_stela_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
    loss_initial_11 = objective_function_11(initial_E_thr_values(11));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_11(E_thr_value), initial_E_thr_values(11), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(11) = optimized_E_thr_value;
    fvals(11) = fval./loss_multiple_factor;

    objective_function_12 = @(E_thr_value) final_stela_mod_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
    loss_initial_12 = objective_function_12(initial_E_thr_values(12));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_12(E_thr_value), initial_E_thr_values(12), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(12) = optimized_E_thr_value;
    fvals(12) = fval./loss_multiple_factor;

    objective_function_13 = @(E_thr_value) final_barten_mod_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
    loss_initial_13 = objective_function_13(initial_E_thr_values(13));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_13(E_thr_value), initial_E_thr_values(13), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(13) = optimized_E_thr_value;
    fvals(13) = fval./loss_multiple_factor;

    objective_function_14= @(E_thr_value) final_stela_transient_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
    loss_initial_14 = objective_function_14(initial_E_thr_values(14));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_14(E_thr_value), initial_E_thr_values(14), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(14) = optimized_E_thr_value;
    fvals(14) = fval./loss_multiple_factor;

    objective_function_15 = @(E_thr_value) final_stela_mod_transient_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
    loss_initial_15 = objective_function_15(initial_E_thr_values(15));
    [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function_15(E_thr_value), initial_E_thr_values(15), [], [], [], [], lb, ub, [], options);
    optimized_E_thr_values(15) = optimized_E_thr_value;
    fvals(15) = fval./loss_multiple_factor;

    writematrix(optimized_E_thr_values, 'optimized_E_thr_values_x_size_1_beta.csv');
    writematrix(fvals, 'fvals_x_size_1_beta.csv');
else
    optimized_E_thr_values = readmatrix('optimized_E_thr_values_x_vrr_f_1_beta.csv');
end

if (csv_generate == 1)
    for vrr_f_i = 1:length(vrr_f_indices)
        vrr_f_value = vrr_f_indices(vrr_f_i);
        for area_range_i = 1:length(continuous_area_range)
            area_value = continuous_area_range(area_range_i);
            radius = (area_value / pi)^0.5;
            [~,~,~,CSF_results_range(1,vrr_f_i,area_range_i), CSF_results_range(2,vrr_f_i,area_range_i), CSF_results_range(3,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model(vrr_f_value, area_value, radius, optimized_E_thr_values(1:3), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(4,vrr_f_i,area_range_i), CSF_results_range(5,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model_transient(vrr_f_value, area_value, radius, optimized_E_thr_values(4:5), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,~,CSF_results_range(6,vrr_f_i,area_range_i), CSF_results_range(7,vrr_f_i,area_range_i), CSF_results_range(8,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model_fix_area(vrr_f_value, radius, optimized_E_thr_values(6:8), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(9,vrr_f_i,area_range_i), CSF_results_range(10,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, optimized_E_thr_values(9:10), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
            [~,~,~,CSF_results_range(11,vrr_f_i,area_range_i), CSF_results_range(12,vrr_f_i,area_range_i), CSF_results_range(13,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model_fix_area_beta(vrr_f_value, radius, optimized_E_thr_values(11:13), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta);
            [~,~,CSF_results_range(14,vrr_f_i,area_range_i), CSF_results_range(15,vrr_f_i,area_range_i)] = ...
                final_contrast_energy_model_transient_fix_area_beta(vrr_f_value, radius, optimized_E_thr_values(14:15), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta);
        end
    end
    writematrix(CSF_results_range, 'CSF_results_range_x_size_1_beta.csv');
else
    CSF_results_range_flat = readmatrix('CSF_results_range_x_size_1_beta.csv');
    CSF_results_range = reshape(CSF_results_range_flat, [length(suffixes), length(vrr_f_indices), length(continuous_area_range)]);
end

figure;
area_indices = [pi*0.25^2, pi*0.5^2, pi*8^2, 62.666 * 37.808];
ha = tight_subplot(3, 5, [.07 .02],[.11 .03],[.035 .001]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'XTick',[pi*0.25^2, pi*0.5^2, pi*8^2, 62.666 * 37.808]); 
set(ha,'XTickLabel',[pi*0.25^2, pi*0.5^2, pi*8^2, 62.666 * 37.808]);
for plot_i = 1:length(suffixes)
    axes(ha(plot_i));
    xlim([pi*0.25^2*0.5, 62.666 * 37.808*2]);
    ylim([0.001, 0.1]);
    if (plot_i == 6)
        ylabel('C_{thr} (Flicker Detection Contrast Threshold)','FontSize',18);
    end
    if (plot_i == 13)
        xlabel('Area (degree^2)','FontSize',18);
    end
    title(suffixes(plot_i),'FontSize',13);
    color = ['r', 'g', 'b', 'm'];
    legend_exp_plots = {};
    legend_errorbar_plots = {};
    legend_model_plots = {};
    legend_exp_labels = {};
    legend_errorbar_labels = {};
    legend_model_labels = {};

    for vrr_f_i = 1:length(vrr_f_indices)
        error_upper = high_C_t_matrix(vrr_f_i, :) - average_C_t_matrix(vrr_f_i, :);
        error_lower = average_C_t_matrix(vrr_f_i, :) - low_C_t_matrix(vrr_f_i, :);
        vrr_f_value = vrr_f_indices(vrr_f_i);
        display_name_exp = ['Subjective Psychophysical Result - Frequency of RR Switch: ' num2str(vrr_f_value) ' Hz'];
        display_name_model = ['Model Predicition - Frequency of RR Switch: ' num2str(vrr_f_value) ' Hz'];
        hold on;
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        legend_exp_plots{end+1} = scatter(area_indices, average_C_t_matrix(vrr_f_i, :), 50, 'Marker', 'o', 'MarkerFaceColor', color(vrr_f_i), 'LineWidth', 1.0, 'DisplayName', display_name_exp);
        legend_exp_labels{end+1} = display_name_exp;
        if (vrr_f_i == 1)
            legend_errorbar_plots{end+1} = errorbar(area_indices, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
            legend_errorbar_labels{end+1} = 'Psychometric function fitting error bar';
        else
            errorbar(area_indices, average_C_t_matrix(vrr_f_i, :), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
        end
    legend_model_plots{end+1} = plot(continuous_area_range, reshape(CSF_results_range(plot_i,vrr_f_i,:), 1, []), '-', 'LineWidth', 1, 'Color', color(vrr_f_i), 'DisplayName', display_name_model);
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
