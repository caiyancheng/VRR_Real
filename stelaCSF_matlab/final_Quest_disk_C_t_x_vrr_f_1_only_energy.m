size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
beta = 3.5;
continuous_vrr_f_range = logspace(log10(0.5), log10(10), 10)';
fit_poly_degree = 4;
area_fix = 1;
Luminance_lb = 0.05;
Luminance_ub = 8;
beta = 3.5;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Energy)', 'stelaCSF_{HF} (Energy)', 'barten_{HF} (Energy)', ...
            'stelaCSF transient (Energy)', 'stelaCSF_{HF} transient (Energy)', ...
            'stelaCSF (Energy fix area)', 'stelaCSF_{HF} (Energy fix area)', 'barten_{HF} (Energy fix area)', ...
            'stelaCSF transient (Energy fix area)', 'stelaCSF_{HF} transient (Energy fix area)', ...
            'stelaCSF (Energy fix area + beta)', 'stelaCSF_{HF} (Energy fix area + beta)', 'barten_{HF} (Energy fix area + beta)', ...
            'stelaCSF transient (Energy fix area + beta)', 'stelaCSF_{HF} transient (Energy fix area + beta)'};

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

CSF_results_fit = zeros(length(suffixes), length(vrr_f_indices), length(size_indices));
CSF_results_range = zeros(length(suffixes), length(continuous_vrr_f_range), length(size_indices));
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
peak_spatial_frequency = logspace(log10(0.2), log10(10), 100); %peak部分
% initial_E_thr_values = [0.225499639710616, 0.176807621389691, 1.133618092401632, 0.030043015925068, 0.006653541774230, ...
%     0.225499639710616, 0.176807621389691, 1.133618092401632, 0.030043015925068, 0.006653541774230]';
% initial_E_thr_values = [0.224475167157883, 0.176807621389691, 0.967358822969788, 0.0300430158138094, 0.00665354177423, ...
%     0.0541568980480747, 0.0389815382024571, 0.359687212302881, 0.00207145282326101, 0.000440901594222934, ...
%     0.130868756741627, 0.127615945131127, 0.797774365442363, 0.00747906911078759, 0.00163305008264278]';
initial_E_thr_values = [0.271706705875821, 0.175973530164629, 1.10003922892297, 0.0299723852245313, 0.00621610615086627,
                        0.0369594192529463, 0.0287812693120049, 0.319297144564044, 0.00196439278857942, 0.000629376515490757,
                        0.0877530770189669, 0.0707837284360293, 0.797774332855692, 0.00407515851336185, 0.00154290482096361]';


optimize_need = 0;
csv_generate = 1;
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

    writematrix(optimized_E_thr_values, 'optimized_E_thr_values_x_vrr_f_1_beta.csv');
    writematrix(fvals, 'fvals_x_vrr_f_1_beta.csv');
else
    optimized_E_thr_values = readmatrix('optimized_E_thr_values_x_vrr_f_1_beta.csv');
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
            % objective_function_1 = @(E_thr_value) final_stela_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree).*loss_multiple_factor;
            % loss_initial_1 = objective_function_1(initial_E_thr_values(1));
            [~,~,~,CSF_results_range(1,vrr_f_range_i,size_i), CSF_results_range(2,vrr_f_range_i,size_i), CSF_results_range(3,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model(vrr_f_range_value, area_value, radius, optimized_E_thr_values(1:3), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(4,vrr_f_range_i,size_i), CSF_results_range(5,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model_transient(vrr_f_range_value, area_value, radius, optimized_E_thr_values(4:5), fit_poly_degree, Luminance_lb, Luminance_ub);
            [~,~,~,CSF_results_range(6,vrr_f_range_i,size_i), CSF_results_range(7,vrr_f_range_i,size_i), CSF_results_range(8,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model_fix_area(vrr_f_range_value, radius, optimized_E_thr_values(6:8), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
            [~,~,CSF_results_range(9,vrr_f_range_i,size_i), CSF_results_range(10,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model_transient_fix_area(vrr_f_range_value, radius, optimized_E_thr_values(9:10), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub);
            [~,~,~,CSF_results_range(11,vrr_f_range_i,size_i), CSF_results_range(12,vrr_f_range_i,size_i), CSF_results_range(13,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model_fix_area_beta(vrr_f_range_value, radius, optimized_E_thr_values(11:13), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta);
            [~,~,CSF_results_range(14,vrr_f_range_i,size_i), CSF_results_range(15,vrr_f_range_i,size_i)] = ...
                final_contrast_energy_model_transient_fix_area_beta(vrr_f_range_value, radius, optimized_E_thr_values(14:15), fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta);
        end
    end
    writematrix(CSF_results_range, 'CSF_results_range_x_vrr_f_1_beta.csv');
else
    CSF_results_range_flat = readmatrix('CSF_results_range_x_vrr_f_1_beta.csv');
    CSF_results_range = reshape(CSF_results_range_flat, [length(suffixes), length(continuous_vrr_f_range), length(size_indices)]);
end

objective_function_13 = @(E_thr_value) final_barten_mod_energy_loss_fix_area_beta(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub, beta).*loss_multiple_factor;
loss_initial_13 = objective_function_13(initial_E_thr_values(13));

group_num = 6;
figure;
ha = tight_subplot(length(size_indices), group_num, [.04 .02],[.2 .03],[.05 .05]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]); 
set(ha,'XTick',[0.5, 1, 2, 4, 8]); 
set(ha,'XTickLabel',[0.5, 1, 2, 4, 8]);
x_axis = vrr_f_indices;
x_axis_range = continuous_vrr_f_range;
y_lim_range = [0.001, 0.1];
for size_i = 1:length(size_indices)-1
    error_upper = high_C_t_matrix(:, size_i) - average_C_t_matrix(:, size_i);
    error_lower = average_C_t_matrix(:, size_i) - low_C_t_matrix(:, size_i);

    axes(ha(((size_i)-1)*group_num+1));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    ylabel('C_t (Detection Threshold)','FontSize',12);
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(1,:,size_i), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(2,:,size_i), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(3,:,size_i), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+2));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(4,:,size_i), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(5,:,size_i), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+3));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(6,:,size_i), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(7,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.8, 0.1], 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(8,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+4));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(9,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(10,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+5));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(11,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.4, 0.9, 0.1], 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(12,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.2, 0.9], 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(13,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.9, 0.1], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+6));
    title(['Size (Radius): ' num2str(size_indices(size_i)), ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis_range, CSF_results_range(14,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.9], 'MarkerSize', 3);
    plot(x_axis_range, CSF_results_range(15,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.7], 'MarkerSize', 3);
    grid on;
end

size_i = length(size_indices);
axes(ha(((size_i)-1)*group_num+1));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylabel('C_t (Detection Threshold)','FontSize',12);
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(1,:,size_i), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3, 'DisplayName', suffixes{1});
plot(x_axis_range, CSF_results_range(2,:,size_i), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3, 'DisplayName', suffixes{2});
plot(x_axis_range, CSF_results_range(3,:,size_i), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3, 'DisplayName', suffixes{3});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((size_i)-1)*group_num+2));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(4,:,size_i), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3, 'DisplayName', suffixes{4});
plot(x_axis_range, CSF_results_range(5,:,size_i), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3, 'DisplayName', suffixes{5});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((size_i)-1)*group_num+3));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(6,:,size_i), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3,'DisplayName', suffixes{6});
plot(x_axis_range, CSF_results_range(7,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.8, 0.1], 'MarkerSize', 3, 'DisplayName', suffixes{7});
plot(x_axis_range, CSF_results_range(8,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3, 'DisplayName', suffixes{8});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((size_i)-1)*group_num+4));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(9,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3, 'DisplayName', suffixes{9});
plot(x_axis_range, CSF_results_range(10,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3, 'DisplayName', suffixes{10});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((size_i)-1)*group_num+5));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(11,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.4, 0.9, 0.1], 'MarkerSize', 3, 'DisplayName', suffixes{11});
plot(x_axis_range, CSF_results_range(12,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.2, 0.9], 'MarkerSize', 3, 'DisplayName', suffixes{12});
plot(x_axis_range, CSF_results_range(13,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.9, 0.1], 'MarkerSize', 3, 'DisplayName', suffixes{13});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((size_i)-1)*group_num+6));
title('Size: 62.666 \times 37.808 degree');
hold on;
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis_range, CSF_results_range(14,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.9], 'MarkerSize', 3, 'DisplayName', suffixes{14});
plot(x_axis_range, CSF_results_range(15,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.7], 'MarkerSize', 3, 'DisplayName', suffixes{15});
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

hold off;