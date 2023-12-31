size_indices = [1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
c = 1;
beta = 3.5;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_2\Observer_Yancheng_Cai_Test_10/reorder_result_no16_D_thr_result_C_t.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF', 'stelaCSF_mod', 'barten_mod', 'stelaCSF_transient', 'stelaCSF_mod_transient', ...
    'stelaCSF_cyc_1', 'stelaCSF_mod_cyc_1', 'barten_mod_cyc_1', 'stelaCSF_1cpd', 'stelaCSF_mod_1cpd', 'barten_mod_1cpd',...
    'stelaCSF_peak', 'stelaCSF_mod_peak', 'barten_mod_peak', 'stelaCSF_peak_transient', 'stelaCSF_mod_peak_transient'};

% Define other variables

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

initial_k_values = ones(size(suffixes))' * 2;
lb = zeros(size(initial_k_values));
ub = Inf(size(initial_k_values));

% 针对Luminance画全部
figure; % 创建主图
for vrr_f_value = vrr_f_indices
    area_value_list = [];
    luminance_list = [];
    average_C_t_list = [];
    for size_value = size_indices
        filtered_data = data(data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
        valid_data = filtered_data(~isnan(filtered_data.C_t), :);
        average_C_t = mean(valid_data.C_t);
        luminance = mean(valid_data.Luminance);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
        else
            area_value = size_value^2;
        end

        luminance_list = [luminance_list, luminance];
        area_value_list = [area_value_list, area_value];
        average_C_t_list = [average_C_t_list, average_C_t];
    end
    
    area_CSF_list = logspace(log10(1), log10(3000), 100)';
    results = zeros(length(suffixes), length(area_CSF_list));

    csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance_list, 'area', area_value_list, 'eccentricity', 0);
    for i = 1:length(area_CSF_list)
        [results(1,i), results(2,i), results(3,i)] = multiple_contrast_energy_detectors(luminance_list(i), c, beta, num_points, vrr_f_value, area_CSF_list(i));
        [results(4,i), results(5,i)] = multiple_contrast_energy_detectors_transient(luminance_list(i), c, beta, num_points, vrr_f_value, area_CSF_list(i));
        [results(6,i), results(7,i), results(8,i)] = multiple_contrast_energy_detectors_cyc_1(luminance_list(i), c, beta, num_points, vrr_f_value, area_CSF_list(i));
    end
    results(9,:) = stelacsf_model.sensitivity(csf_pars);
    results(10,:) = stelacsf_mod_model.sensitivity(csf_pars);
    results(11,:) = barten_mod_model.sensitivity(csf_pars);

    peak_spatial_frequency = linspace( 1, 10, 100)';
    for i = 1:length(area_CSF_list)
        csf_pars_peak = struct('s_frequency', peak_spatial_frequency, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance_list(i), 'area', area_value_list(i), 'eccentricity', 0);
        results(12,i) = max(stelacsf_model.sensitivity(csf_pars_peak));
        results(13,i) = max(stelacsf_mod_model.sensitivity(csf_pars_peak));
        results(14,i) = max(barten_mod_model.sensitivity(csf_pars_peak));
        results(15,i) = max(stelacsf_transient_model.sensitivity(csf_pars_peak));
        results(16,i) = max(stelacsf_mod_transient_model.sensitivity(csf_pars_peak));
    end
        
   distance_matrix = pdist2(area_value_list', area_CSF_list);
   [~, closest_indices] = min(distance_matrix, [], 2);
   closest_points_CSF = area_CSF_list(closest_indices);
   selected_results = results(:, closest_indices);
   optimized_k_values = zeros(size(selected_results, 1), 1);
   fvals = zeros(size(selected_results, 1), 1);

   for variable_index = 1:size(selected_results, 1)
        current_result = selected_results(variable_index, :);
        current_initial_k_value = initial_k_values(variable_index);
        loss = sum((1./(current_initial_k_value.*current_result) - average_C_t_list).^2);
        objective_function = @(k_value) sum((1./(k_value.*current_result) - average_C_t_list).^2)*1e8;
        lb = 0;  % 下界
        ub = 3000; % 上界
        options = optimset('Display', 'iter'); % 显示优化过程
        [optimized_k_value, fval] = fmincon(@(k_value) objective_function(k_value), current_initial_k_value, [], [], [], [], lb, ub, [], options);
        optimized_k_values(variable_index) = optimized_k_value;
        fvals(variable_index) = fval;
    end

    disp(['Optimized k_values: ', num2str(optimized_k_values')]);
    disp(['Objective function value at optimum: ', num2str(fvals')]);
    C_t_s = 1./(optimized_k_values.*results);
    subplot(length(size_indices), length(luminance_indices), (find(size_indices == size_value)-1)*length(luminance_indices) + find(luminance_indices == luminance_value));
    hold on;
    plot(area_CSF_list, C_t_s(1,:), 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(1), fvals(1)));
    plot(area_CSF_list, C_t_s(2,:), 'g-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(2), fvals(2)));
    plot(area_CSF_list, C_t_s(3,:), 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(3), fvals(3)));
    plot(area_CSF_list, C_t_s(4,:), 'c-', 'LineWidth', 3, 'DisplayName', sprintf('stelaCSF transient (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(4), fvals(4)));
    plot(area_CSF_list, C_t_s(5,:), 'm-', 'LineWidth', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(5), fvals(5)));
    plot(area_CSF_list, C_t_s(6,:), 'y-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(6), fvals(6)));
    plot(area_CSF_list, C_t_s(7,:), 'k-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(7), fvals(7)));
    plot(area_CSF_list, C_t_s(8,:), 'Color', [0.5, 0.2, 0.8], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(8), fvals(8)));
    plot(area_CSF_list, C_t_s(9,:), 'Color', [0.8, 0.4, 0.2], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(9), fvals(9)));
    plot(area_CSF_list, C_t_s(10,:), 'Color', [0.2, 0.6, 0.4], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(10), fvals(10)));
    plot(area_CSF_list, C_t_s(11,:), 'Color', [0.1, 0.9, 0.3], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(11), fvals(11)));
    plot(area_CSF_list, C_t_s(12,:), 'Color', [0.4, 0.3, 0.6], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(12), fvals(12)));
    plot(area_CSF_list, C_t_s(13,:), 'Color', [0.6, 0.2, 0.5], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(13), fvals(13)));
    plot(area_CSF_list, C_t_s(14,:), 'Color', [0.8, 0.1, 0.7], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(14), fvals(14)));
    plot(area_CSF_list, C_t_s(15,:), 'Color', [0.3, 0.6, 0.3], 'LineWidth', 3, 'DisplayName', sprintf('stelaCSF transient (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(15), fvals(15)));
    plot(area_CSF_list, C_t_s(16,:), 'Color', [0.9, 0.7, 0.1], 'LineWidth', 3, 'DisplayName', sprintf('stelaCSF_{mod} transient (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(16), fvals(16)));
    scatter(area_value_list, average_C_t_list, 200, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
    hold off;
    xlabel('Size (degree^2)');
    ylabel('C_t (Average across Observers)');
    title(['Size: ' num2str(size_value) '\times' num2str(size_value) ' degree, Luminance: ' num2str(luminance_value) ' nits']);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    % xlim([1, 10]);
    legend('show'); % 添加图例
end