% 相对于2，这里添加了对k值的优化方案，但是因此可能运行速度会比较慢
% luminance_indices = [1, 2, 3, 4, 5, 10, 100];
% size_indices = [4, 16];
luminance_indices = [10,];
size_indices = [4,];
vrr_f_indices = [2, 5, 10];
num_obs = 4;
num_points = 1000;
c = 1;
beta = 3.5;

c_t_subjective_path = '../Computational_Model/mu_results.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF', 'stelaCSF_mod', 'barten_mod', 'stelaCSF_transient', 'stelaCSF_mod_transient', ...
    'stelaCSF_cyc_1', 'stelaCSF_mod_cyc_1', 'barten_mod_cyc_1', 'stelaCSF_1cpd', 'stelaCSF_mod_1cpd', 'barten_mod_1cpd',...
    'stelaCSF_peak', 'stelaCSF_mod_peak', 'barten_mod_peak'};

% Define other variables

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
barten_mod_model = CSF_stmBartenVeridical();

% initial_k_values = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]';
initial_k_values = [2, 2, 2, 1000, 1000, 2, 2, 2, 2, 2, 2, 2, 2, 2]';
lb = zeros(size(initial_k_values));
ub = Inf(size(initial_k_values));

% 针对Luminance画全部
figure; % 创建主图
% total_iterations = length(size_indices) * length(luminance_indices);
% current_iteration = 0;
% h = waitbar(0, 'Rendering Progress...');
for size_value = size_indices
    for luminance_value = luminance_indices
        % current_iteration = current_iteration + 1;
        % waitbar(current_iteration / total_iterations, h);
        vrr_f_list = [];
        average_C_t_list = [];
        for vrr_f_value = vrr_f_indices   
            filtered_data = data(data.Luminance == luminance_value & data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
            valid_data = filtered_data(~isnan(filtered_data.C_t), :);
            average_C_t = mean(valid_data.C_t);
            vrr_f_list = [vrr_f_list, vrr_f_value];
            average_C_t_list = [average_C_t_list, average_C_t];
        end

        vrr_f_CSF_list = linspace( 1, 10, 100)';
        results = zeros(length(suffixes), length(vrr_f_CSF_list));

        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_CSF_list, 'orientation', 0, 'luminance', luminance_value, 'area', size_value^2, 'eccentricity', 0);
        for i = 1:length(vrr_f_CSF_list)
            [results(1,i), results(2,i), results(3,i)] = multiple_contrast_energy_detectors(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
            [results(4,i), results(5,i)] = multiple_contrast_energy_detectors_transient(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
            [results(6,i), results(7,i), results(8,i)] = multiple_contrast_energy_detectors_cyc_1(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
        end
        results(9,:) = stelacsf_model.sensitivity(csf_pars);
        results(10,:) = stelacsf_mod_model.sensitivity(csf_pars);
        results(11,:) = barten_mod_model.sensitivity(csf_pars);

        peak_spatial_frequency = linspace( 1, 10, 100)';
        for i = 1:length(vrr_f_CSF_list)
            csf_pars_peak = struct('s_frequency', peak_spatial_frequency, 't_frequency', vrr_f_CSF_list(i), 'orientation', 0, 'luminance', luminance_value, 'area', size_value^2, 'eccentricity', 0);
            results(12,i) = max(stelacsf_model.sensitivity(csf_pars_peak));
            results(13,i) = max(stelacsf_mod_model.sensitivity(csf_pars_peak));
            results(14,i) = max(barten_mod_model.sensitivity(csf_pars_peak));
        end
        
        distance_matrix = pdist2(vrr_f_list', vrr_f_CSF_list);
        [~, closest_indices] = min(distance_matrix, [], 2);
        closest_points_CSF = vrr_f_CSF_list(closest_indices);
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
        plot(vrr_f_CSF_list, C_t_s(1,:), 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(1), fvals(1)));
        plot(vrr_f_CSF_list, C_t_s(2,:), 'g-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(2), fvals(2)));
        plot(vrr_f_CSF_list, C_t_s(3,:), 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(3), fvals(3)));
        plot(vrr_f_CSF_list, C_t_s(4,:), 'c-', 'LineWidth', 5, 'DisplayName', sprintf('stelaCSF transient (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(4), fvals(4)));
        plot(vrr_f_CSF_list, C_t_s(5,:), 'm-', 'LineWidth', 5, 'DisplayName', sprintf('stelaCSF_{mod} transient (Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(5), fvals(5)));
        plot(vrr_f_CSF_list, C_t_s(6,:), 'y-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(6), fvals(6)));
        plot(vrr_f_CSF_list, C_t_s(7,:), 'k-', 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(7), fvals(7)));
        plot(vrr_f_CSF_list, C_t_s(8,:), 'Color', [0.5, 0.2, 0.8], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (*frequency Energy) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(8), fvals(8)));
        plot(vrr_f_CSF_list, C_t_s(9,:), 'Color', [0.8, 0.4, 0.2], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(9), fvals(9)));
        plot(vrr_f_CSF_list, C_t_s(10,:), 'Color', [0.2, 0.6, 0.4], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(10), fvals(10)));
        plot(vrr_f_CSF_list, C_t_s(11,:), 'Color', [0.1, 0.9, 0.3], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (1 cpd) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(11), fvals(11)));
        plot(vrr_f_CSF_list, C_t_s(12,:), 'Color', [0.4, 0.3, 0.6], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(12), fvals(12)));
        plot(vrr_f_CSF_list, C_t_s(13,:), 'Color', [0.6, 0.2, 0.5], 'LineWidth', 1.5, 'DisplayName', sprintf('stelaCSF_{mod} (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(13), fvals(13)));
        plot(vrr_f_CSF_list, C_t_s(14,:), 'Color', [0.8, 0.1, 0.7], 'LineWidth', 1.5, 'DisplayName', sprintf('Barten_{mod} (Peak) - k: %.4f, loss (*1e8): %.4f', optimized_k_values(14), fvals(14)));
        scatter(vrr_f_list, average_C_t_list, 200, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');

        hold off;
        xlabel('Frequency of RR switch (Hz)');
        ylabel('C_t (Average across Observers)');
        title(['Size: ' num2str(size_value) '\times' num2str(size_value) ' degree, Luminance: ' num2str(luminance_value) ' nits']);
        % set(gca, 'XScale', 'log');
        % set(gca, 'YScale', 'log');
        xlim([1, 10]); % Specify the x-axis range
        % ylim([0, 0.03]); % Specify the y-axis range
        legend('show'); % 添加图例
        
    end
end