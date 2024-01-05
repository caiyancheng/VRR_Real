size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
c = 1;
beta = 3.5;
continuous_vrr_f_range = [0.2,10];

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_3/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF', 'stelaCSF_mod', 'barten_mod', 'stelaCSF_transient', 'stelaCSF_mod_transient', ...
    'stelaCSF_frequency', 'stelaCSF_mod_frequency', 'barten_mod_frequency', 'stelaCSF_1cpd', 'stelaCSF_mod_1cpd', 'barten_mod_1cpd',...
    'stelaCSF_peak', 'stelaCSF_mod_peak', 'barten_mod_peak', 'stelaCSF_peak_transient', 'stelaCSF_mod_peak_transient', ...
    'stelaCSF_fundamental_spatial_f', 'stelaCSF_mod_fundamental_spatial_f', 'barten_mod_fundamental_spatial_f', ...
    'stelaCSF_fundamental_spatial_f_transient', 'stelaCSF_mod_fundamental_spatial_f_transient'};

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

initial_k_values = ones(size(suffixes))' * 1000;
lb = zeros(size(initial_k_values));
ub = Inf(size(initial_k_values));

results = zeros(length(suffixes), length(vrr_f_indices), length(size_indices));
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices));
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
peak_spatial_frequency = linspace( 1, 10, 100)';

% Calculate the CSF result
for vrr_f_i = 1:length(vrr_f_indices)
    vrr_f_value = vrr_f_indices(vrr_f_i);
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
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

        luminance = mean(valid_data.Luminance);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
        else
            area_value = size_value^2;
        end
        average_C_t_matrix(vrr_f_i, size_i) = average_C_t;
        high_C_t_matrix(vrr_f_i, size_i) = high_C_t;
        low_C_t_matrix(vrr_f_i, size_i) = low_C_t;

        [results(1,vrr_f_i,size_i), results(2,vrr_f_i,size_i), results(3,vrr_f_i,size_i)] = multiple_contrast_energy_detectors_no_multiply(luminance, c, beta, num_points, vrr_f_value, area_value);
        [results(4,vrr_f_i,size_i), results(5,vrr_f_i,size_i)] = multiple_contrast_energy_detectors_transient_no_multiply(luminance, c, beta, num_points, vrr_f_value, area_value);
        [results(6,vrr_f_i,size_i), results(7,vrr_f_i,size_i), results(8,vrr_f_i,size_i)] = multiple_contrast_energy_detectors_cyc_1_no_multiply(luminance, c, beta, num_points, vrr_f_value, area_value);
        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        results(9,vrr_f_i,size_i) = stelacsf_model.sensitivity(csf_pars);
        results(10,vrr_f_i,size_i) = stelacsf_mod_model.sensitivity(csf_pars);
        results(11,vrr_f_i,size_i) = barten_mod_model.sensitivity(csf_pars);

        csf_pars_peak = struct('s_frequency', peak_spatial_frequency, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        results(12,vrr_f_i,size_i) = max(stelacsf_model.sensitivity(csf_pars_peak));
        results(13,vrr_f_i,size_i) = max(stelacsf_mod_model.sensitivity(csf_pars_peak));
        results(14,vrr_f_i,size_i) = max(barten_mod_model.sensitivity(csf_pars_peak));
        results(15,vrr_f_i,size_i) = max(stelacsf_transient_model.sensitivity(csf_pars_peak));
        results(16,vrr_f_i,size_i) = max(stelacsf_mod_transient_model.sensitivity(csf_pars_peak));

        csf_pars_fundamental = struct('s_frequency', 1/((pi*area_value)^0.5), 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        results(17,vrr_f_i,size_i) = stelacsf_model.sensitivity(csf_pars_fundamental);
        results(18,vrr_f_i,size_i) = stelacsf_mod_model.sensitivity(csf_pars_fundamental);
        results(19,vrr_f_i,size_i) = barten_mod_model.sensitivity(csf_pars_fundamental);

        csf_pars_fundamental_transient = struct('s_frequency', 1/((pi*area_value)^0.5), 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
        results(20,vrr_f_i,size_i) = stelacsf_transient_model.sensitivity(csf_pars_fundamental);
        results(21,vrr_f_i,size_i) = stelacsf_mod_transient_model.sensitivity(csf_pars_fundamental);
    end
end

% 拟合参数
optimized_k_values = zeros(length(suffixes), 1);
fvals = zeros(length(suffixes), 1);
loss_size_scale = [1,1,1,1];
for csf_model_i = 1:length(suffixes)
   current_result = squeeze(results(csf_model_i, :, :));
   current_initial_k_value = initial_k_values(csf_model_i);
   % loss = nansum(nansum((1./(current_initial_k_value.*current_result) - average_C_t_matrix).^2.*valids).*loss_size_val);
   objective_function = @(k_value) nansum(nansum((1./(k_value.*current_result) - average_C_t_matrix).^2.*valids).*loss_size_scale).*1e10;
   lb = 0;  % 下界
   ub = Inf; % 上界
   options = optimset('Display', 'iter'); % 显示优化过程
   [optimized_k_value, fval] = fmincon(@(k_value) objective_function(k_value), current_initial_k_value, [], [], [], [], lb, ub, [], options);
   optimized_k_values(csf_model_i) = optimized_k_value;
   fvals(csf_model_i) = fval./1e10;
end

disp(['Optimized k_values: ', num2str(optimized_k_values')]);
disp(['Objective function value at optimum: ', num2str(fvals')]);
C_t_s = 1./(optimized_k_values.*results);
validIndices = isfinite(C_t_s);

group_num = 8;
figure;
ha = tight_subplot(length(vrr_f_indices), group_num, [.04 .02],[.2 .03],[.05 .05]);
area_value_list = [0.5*0.5, 1*1, 16*16, 62.666 * 37.808];
set(ha,'YTick',[0.001,0.005, 0.01, 0.05]); 
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05]); 
set(ha,'XTick',area_value_list); 
set(ha,'XTickLabel',area_value_list);
x_axis = area_value_list;
y_lim_range = [0.0001, 0.07];
for vrr_f_i = 1:length(vrr_f_indices)-1
    error_upper = high_C_t_matrix(vrr_f_i,:) - average_C_t_matrix(vrr_f_i,:);
    error_lower = average_C_t_matrix(vrr_f_i,:) - low_C_t_matrix(vrr_f_i,:);

    axes(ha(((vrr_f_i)-1)*group_num+1));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    ylabel('C_t (Detection Threshold)','FontSize',12);
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(1, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(2, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(3, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+2));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(4, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(5, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+3));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(6, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'y', 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(7, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(8, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+4));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log');
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(9, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(10, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(11, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.3], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+5));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(12, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.4, 0.3, 0.6], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(13, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.5], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(14, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.1, 0.7], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+6));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(15, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.3, 0.6, 0.3], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(16, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.7, 0.1], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+7));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(17, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.6, 0.3], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(18, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.8, 0.1], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(19, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.4, 0.7, 0.5], 'MarkerSize', 3);
    grid on;

    axes(ha(((vrr_f_i)-1)*group_num+8));
    title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
    set(gca, 'XScale', 'log'); 
    ylim(y_lim_range);
    set(gca, 'YScale', 'log');
    hold on;
    scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0);
    errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    plot(x_axis, reshape(C_t_s(20, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.9], 'MarkerSize', 3);
    plot(x_axis, reshape(C_t_s(21, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.9, 0.1], 'MarkerSize', 3);
    grid on;
end

vrr_f_i = length(vrr_f_indices);
axes(ha(((vrr_f_i)-1)*group_num+1));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
ylabel('C_t (Detection Threshold)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(1, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (Energy) - k: %.4f, loss: %.4f', optimized_k_values(1), fvals(1)));
plot(x_axis, reshape(C_t_s(2, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (Energy) - k: %.4f, loss: %.4f', optimized_k_values(2), fvals(2)));
plot(x_axis, reshape(C_t_s(3, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (Energy) - k: %.4f, loss: %.4f', optimized_k_values(3), fvals(3)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+2));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(4, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'c', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF transient (Energy) - k: %.4f, loss : %.4f', optimized_k_values(4), fvals(4)));
plot(x_axis, reshape(C_t_s(5, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'm', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Energy) - k: %.4f, loss: %.4f', optimized_k_values(5), fvals(5)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+3));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(6, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'y', 'MarkerSize', 3,'DisplayName', sprintf('stelaCSF (*frequency Energy) - k: %.4f, loss: %.4f', optimized_k_values(6), fvals(6)));
plot(x_axis, reshape(C_t_s(7, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', 'k', 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (*frequency Energy) - k: %.4f, loss %.4f', optimized_k_values(7), fvals(7)));
plot(x_axis, reshape(C_t_s(8, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.5, 0.2, 0.8], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (*frequency Energy) - k: %.4f, loss: %.4f', optimized_k_values(8), fvals(8)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+4));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(9, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.4, 0.2], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(9), fvals(9)));
plot(x_axis, reshape(C_t_s(10, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.4], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(10), fvals(10)));
plot(x_axis, reshape(C_t_s(11, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.1, 0.9, 0.3], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (1 cpd) - k: %.4f, loss: %.4f', optimized_k_values(11), fvals(11)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+5));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(12, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.4, 0.3, 0.6], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (Peak) - k: %.4f, loss: %.4f', optimized_k_values(12), fvals(12)));
plot(x_axis, reshape(C_t_s(13, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.6, 0.2, 0.5], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (Peak) - k: %.4f, loss: %.4f', optimized_k_values(13), fvals(13)));
plot(x_axis, reshape(C_t_s(14, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.1, 0.7], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (Peak) - k: %.4f, loss: %.4f', optimized_k_values(14), fvals(14)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+6));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(15, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.3, 0.6, 0.3], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF transient (Peak) - k: %.4f, loss: %.4f', optimized_k_values(15), fvals(15)));
plot(x_axis, reshape(C_t_s(16, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.7, 0.1], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Peak) - k: %.4f, loss: %.4f', optimized_k_values(16), fvals(16)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+7));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(17, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.8, 0.6, 0.3], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF (fsf) - k: %.4f, loss: %.4f', optimized_k_values(17), fvals(17)));
plot(x_axis, reshape(C_t_s(18, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.8, 0.1], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} (fsf) - k: %.4f, loss: %.4f', optimized_k_values(18), fvals(18)));
plot(x_axis, reshape(C_t_s(19, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.4, 0.7, 0.5], 'MarkerSize', 3, 'DisplayName', sprintf('Barten_{mod} (fsf) - k: %.4f, loss: %.4f', optimized_k_values(19), fvals(19)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

axes(ha(((vrr_f_i)-1)*group_num+8));
title(['Frequency of RR Switch: ' num2str(vrr_f_indices(vrr_f_i)) ' Hz']);
hold on;
xlabel('Size_W * Size_H (degree^2)','FontSize',12);
set(gca, 'XScale', 'log');
ylim(y_lim_range);
set(gca, 'YScale', 'log');
scatter(x_axis, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
errorbar(x_axis, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
plot(x_axis, reshape(C_t_s(20, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.2, 0.6, 0.9], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF transient (fsf) - k: %.4f, loss: %.4f', optimized_k_values(20), fvals(20)));
plot(x_axis, reshape(C_t_s(21, vrr_f_i, :), 1, []), '-o', 'LineWidth', 1, 'Color', [0.9, 0.9, 0.1], 'MarkerSize', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (fsf) - k: %.4f, loss: %.4f', optimized_k_values(21), fvals(21)));
grid on;
hLegend = legend('show','FontSize',7);
set(hLegend, 'Location', 'southoutside', 'Orientation', 'vertical'); 
legendPos = get(hLegend, 'Position');
legendPos(2) = 0.1 - legendPos(4)/2;
set(hLegend, 'Position', legendPos);

hold off;

%相比5，6使用了continuous的prediction