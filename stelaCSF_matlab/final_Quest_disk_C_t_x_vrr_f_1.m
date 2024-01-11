size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
beta = 3.5;
continuous_vrr_f_range = logspace(log10(0.2), log10(10), 100);
fit_poly_degree = 4;
area_fix = 1;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Energy)', 'stelaCSF_{mod} (Energy)', 'barten_{mod} (Energy)', ...
            'stelaCSF transient (Energy)', 'stelaCSF_{mod} transient (Energy)', ...
            'stelaCSF (Energy fix area)', 'stelaCSF_{mod} (Energy fix area)', 'barten_{mod} (Energy fix area)', ...
            'stelaCSF transient (Energy fix area)', 'stelaCSF_{mod} transient (Energy fix area)'};
            % 'stelaCSF 1cpd', 'stelaCSF_{mod} 1cpd', 'barten_{mod} 1cpd', ...
            % 'stelaCSF 1cpd transient', 'stelaCSF_{mod} 1cpd transient', ...
            % 'stelaCSF peak', 'stelaCSF_{mod} peak', 'barten_{mod} peak', ...
            % 'stelaCSF peak transient', 'stelaCSF_{mod} peak transient', ...
            % 'stelaCSF FSF', 'stelaCSF_{mod} FSF', 'barten_{mod} FSF', ...
            % 'stelaCSF FSF transient', 'stelaCSF_{mod} FSF transient'};

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
% initial_E_thr_values = ones(10)' * 1000;
initial_E_thr_values = [0.2074, 0.1991, 0.7065, 6.4205e-04, 2.4111e-04, 0.2603, 0.2499, 0.8811, 8.0630e-04, 3.0279e-04]';

for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = 37.808/2;
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

        [~,~,~,CSF_results_fit(1,vrr_f_i,size_i), CSF_results_fit(2,vrr_f_i,size_i), CSF_results_fit(3,vrr_f_i,size_i)] = ...
            final_contrast_energy_model(vrr_f_value, area_value, radius, initial_E_thr_values(1:3), fit_poly_degree);
        [~,~,CSF_results_fit(4,vrr_f_i,size_i), CSF_results_fit(5,vrr_f_i,size_i)] = ...
            final_contrast_energy_model_transient(vrr_f_value, area_value, radius, initial_E_thr_values(4:5), fit_poly_degree);
        [~,~,~,CSF_results_fit(6,vrr_f_i,size_i), CSF_results_fit(7,vrr_f_i,size_i), CSF_results_fit(8,vrr_f_i,size_i)] = ...
            final_contrast_energy_model_fix_area(vrr_f_value, radius, initial_E_thr_values(6:8), fit_poly_degree, area_fix);
        [~,~,CSF_results_fit(9,vrr_f_i,size_i), CSF_results_fit(10,vrr_f_i,size_i)] = ...
            final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, initial_E_thr_values(9:10), fit_poly_degree, area_fix);

        % csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        % CSF_results_fit(11,vrr_f_i,size_i) = stelacsf_model.sensitivity(csf_pars);
        % CSF_results_fit(12,vrr_f_i,size_i) = stelacsf_mod_model.sensitivity(csf_pars);
        % CSF_results_fit(13,vrr_f_i,size_i) = barten_mod_model.sensitivity(csf_pars);
        % CSF_results_fit(14,vrr_f_i,size_i) = stelacsf_transient_model.sensitivity(csf_pars);
        % CSF_results_fit(15,vrr_f_i,size_i) = stelacsf_mod_transient_model.sensitivity(csf_pars);
        % 
        % csf_pars_peak = struct('s_frequency', peak_spatial_frequency, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        % CSF_results_fit(16,vrr_f_i,size_i) = max(stelacsf_model.sensitivity(csf_pars_peak));
        % CSF_results_fit(17,vrr_f_i,size_i) = max(stelacsf_mod_model.sensitivity(csf_pars_peak));
        % CSF_results_fit(18,vrr_f_i,size_i) = max(barten_mod_model.sensitivity(csf_pars_peak));
        % CSF_results_fit(19,vrr_f_i,size_i) = max(stelacsf_transient_model.sensitivity(csf_pars_peak));
        % CSF_results_fit(20,vrr_f_i,size_i) = max(stelacsf_mod_transient_model.sensitivity(csf_pars_peak));
    end
end

% 拟合参数,尤其是那10个E
loss_multiple_factor = 1e10;

optimized_E_thr_values = zeros(10, 1);
fvals = zeros(10, 1);
for csf_model_i = 1:10
   % current_result = squeeze(results(csf_model_i, :, :));
   % current_initial_E_thr_value = initial_E_thr_values(csf_model_i);
   objective_function = @(E_thr_value) final_all_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree).*loss_multiple_factor;
   lb = 0;  % 下界
   ub = Inf; % 上界
   options = optimset('Display', 'off'); % 显示优化过程
   [optimized_E_thr_value, fval] = fmincon(@(E_thr_value) objective_function(E_thr_value), current_initial_E_thr_value, [], [], [], [], lb, ub, [], options);
   optimized_E_thr_values(csf_model_i) = optimized_E_thr_value;
   fvals(csf_model_i) = fval./loss_multiple_factor;
end

optimized_k_values = zeros(15, 1);
fvals = zeros(15, 1);
initial_k_values = ones(10)' * 1000;
for csf_model_i = 11:length(suffixes)
   current_result = squeeze(CSF_results_fit(csf_model_i, :, :));
   current_initial_k_value = initial_k_values(csf_model_i);
   objective_function = @(k_value) nansum(nansum((1./(k_value.*current_result) - average_C_t_matrix).^2.*valids)).*loss_multiple_factor;
   lb = 0;  % 下界
   ub = Inf; % 上界
   options = optimset('Display', 'off'); % 显示优化过程
   [optimized_k_value, fval] = fmincon(@(k_value) objective_function(k_value), current_initial_k_value, [], [], [], [], lb, ub, [], options);
   optimized_k_values(csf_model_i) = optimized_k_value;
   fvals(csf_model_i) = fval./loss_multiple_factor;
end

% 为画图做准备
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = 37.808/2;
    else
        area_value = pi*size_value^2;
        radius = size_value;
    end
    for vrr_f_range_i = 1:length(continuous_vrr_f_range)
        vrr_f_range_value = continuous_vrr_f_range(vrr_f_range_i);
        [~,~,~,CSF_results_range(1,vrr_f_range_i,size_i), CSF_results_range(2,vrr_f_range_i,size_i), CSF_results_range(3,vrr_f_range_i,size_i)] = ...
            final_contrast_energy_model(vrr_f_value, area_value, radius, initial_E_thr_value, fit_poly_degree);
        [~,~,CSF_results_range(4,vrr_f_range_i,size_i), CSF_results_range(5,vrr_f_range_i,size_i)] = ...
            final_contrast_energy_model_transient(vrr_f_value, area_value, radius, initial_E_thr_value, fit_poly_degree);
        [~,~,~,CSF_results_range(6,vrr_f_range_i,size_i), CSF_results_range(7,vrr_f_range_i,size_i), CSF_results_range(8,vrr_f_range_i,size_i)] = ...
            final_contrast_energy_model_fix_area(vrr_f_value, radius, initial_E_thr_value, fit_poly_degree, area_fix);
        [~,~,CSF_results_range(9,vrr_f_range_i,size_i), CSF_results_range(10,vrr_f_range_i,size_i)] = ...
            final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, initial_E_thr_value, fit_poly_degree, area_fix);

        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        CSF_results_range(11,vrr_f_range_i,size_i) = stelacsf_model.sensitivity(csf_pars);
        CSF_results_range(12,vrr_f_range_i,size_i) = stelacsf_mod_model.sensitivity(csf_pars);
        CSF_results_range(13,vrr_f_range_i,size_i) = barten_mod_model.sensitivity(csf_pars);
        CSF_results_range(14,vrr_f_range_i,size_i) = stelacsf_transient_model.sensitivity(csf_pars);
        CSF_results_range(15,vrr_f_range_i,size_i) = stelacsf_mod_transient_model.sensitivity(csf_pars);

        csf_pars_peak = struct('s_frequency', peak_spatial_frequency, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        CSF_results_range(16,vrr_f_range_i,size_i) = max(stelacsf_model.sensitivity(csf_pars_peak));
        CSF_results_range(17,vrr_f_range_i,size_i) = max(stelacsf_mod_model.sensitivity(csf_pars_peak));
        CSF_results_range(18,vrr_f_range_i,size_i) = max(barten_mod_model.sensitivity(csf_pars_peak));
        CSF_results_range(19,vrr_f_range_i,size_i) = max(stelacsf_transient_model.sensitivity(csf_pars_peak));
        CSF_results_range(20,vrr_f_range_i,size_i) = max(stelacsf_mod_transient_model.sensitivity(csf_pars_peak));
    end
end
disp(['Optimized k_values: ', num2str(optimized_k_values')]);
disp(['Objective function value at optimum: ', num2str(fvals')]);
C_t_s = 1./(optimized_k_values.*results);
validIndices = isfinite(C_t_s);

group_num = 6;
figure;
ha = tight_subplot(length(size_indices), group_num, [.04 .02],[.2 .03],[.05 .05]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05]); 
set(ha,'XTick',[0.5, 1, 2, 4, 8]); 
set(ha,'XTickLabel',[0.5, 1, 2, 4, 8]);
x_axis = vrr_f_indices;
y_lim_range = [0.0001, 0.07];
for size_i = 1:length(size_indices)-1
    error_upper = high_C_t_matrix(:, size_i) - average_C_t_matrix(:, size_i);
    error_lower = average_C_t_matrix(:, size_i) - low_C_t_matrix(:, size_i);

    axes(ha(((size_i)-1)*group_num+1));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    ylabel('C_t (Detection Threshold)','FontSize',12);
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(1,:,size_i), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3);
    plot(x_axis, C_t_s(2,:,size_i), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3);
    plot(x_axis, C_t_s(3,:,size_i), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+2));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(4,:,size_i), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3);
    plot(x_axis, C_t_s(5,:,size_i), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+3));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(6,:,size_i), '-o', 'LineWidth', 1, 'Color', 'y', 'MarkerSize', 3);
    plot(x_axis, C_t_s(7,:,size_i), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3);
    plot(x_axis, C_t_s(8,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+4));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(9,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3);
    plot(x_axis, C_t_s(10,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3);
    plot(x_axis, C_t_s(11,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.3], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+5));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(12,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.4, 0.3, 0.6], 'MarkerSize', 3);
    plot(x_axis, C_t_s(13,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.5], 'MarkerSize', 3);
    plot(x_axis, C_t_s(14,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.1, 0.7], 'MarkerSize', 3);
    grid on;

    axes(ha(((size_i)-1)*group_num+6));
    title(['Size: ' num2str(size_indices(size_i)), '\times' num2str(size_indices(size_i)) ' degree']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, C_t_s(15,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.3, 0.6, 0.3], 'MarkerSize', 3);
    plot(x_axis, C_t_s(16,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.7, 0.1], 'MarkerSize', 3);
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
plot(x_axis, C_t_s(1,:,size_i), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (Energy) - k: %.4f, loss: %.4f', optimized_k_values(1), fvals(1)));
plot(x_axis, C_t_s(2,:,size_i), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (Energy) - k: %.4f, loss: %.4f', optimized_k_values(2), fvals(2)));
plot(x_axis, C_t_s(3,:,size_i), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (Energy) - k: %.4f, loss: %.4f', optimized_k_values(3), fvals(3)));
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
plot(x_axis, C_t_s(4,:,size_i), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF transient (Energy) - k: %.4f, loss : %.4f', optimized_k_values(4), fvals(4)));
plot(x_axis, C_t_s(5,:,size_i), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Energy) - k: %.4f, loss: %.4f', optimized_k_values(5), fvals(5)));
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
plot(x_axis, C_t_s(6,:,size_i), '-o', 'LineWidth', 1, 'Color', 'y', 'MarkerSize', 3,'DisplayName', sprintf('stelaCSF (*frequency Energy) - k: %.4f, loss: %.4f', optimized_k_values(6), fvals(6)));
plot(x_axis, C_t_s(7,:,size_i), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (*frequency Energy) - k: %.4f, loss %.4f', optimized_k_values(7), fvals(7)));
plot(x_axis, C_t_s(8,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (*frequency Energy) - k: %.4f, loss: %.4f', optimized_k_values(8), fvals(8)));
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
plot(x_axis, C_t_s(9,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(9), fvals(9)));
plot(x_axis, C_t_s(10,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(10), fvals(10)));
plot(x_axis, C_t_s(11,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.3], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(11), fvals(11)));
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
plot(x_axis, C_t_s(12,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.4, 0.3, 0.6], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (Peak) - k: %.4f, loss: %.4f', optimized_k_values(12), fvals(12)));
plot(x_axis, C_t_s(13,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.5], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (Peak) - k: %.4f, loss: %.4f', optimized_k_values(13), fvals(13)));
plot(x_axis, C_t_s(14,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.8, 0.1, 0.7], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (Peak) - k: %.4f, loss: %.4f', optimized_k_values(14), fvals(14)));
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
plot(x_axis, C_t_s(15,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.3, 0.6, 0.3], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF transient (Peak) - k: %.4f, loss: %.4f', optimized_k_values(15), fvals(15)));
plot(x_axis, C_t_s(16,:,size_i), '-o', 'LineWidth', 1, 'Color', [0.9, 0.7, 0.1], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Peak) - k: %.4f, loss: %.4f', optimized_k_values(16), fvals(16)));
grid on;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

hold off;

%相比5，6使用了continuous的prediction