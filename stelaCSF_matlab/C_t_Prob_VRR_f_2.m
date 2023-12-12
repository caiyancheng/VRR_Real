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

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
barten_mod_model = CSF_stmBartenVeridical();

% energy model
k_stelaCSF = 2;
k_stelaCSF_mod = 2;
k_barten_mod = 2;
% transient channel
k_stelaCSF_transient = 2;
k_stelaCSF_mod_transient = 2;
% multiply by the temporal Frequency
k_stelaCSF_cyc_1 = 2;
k_stelaCSF_mod_cyc_1 = 2;
k_barten_mod_cyc_1 = 2;
% original, spatial frequency fixed at 1 cpd
k_stelaCSF_1cpd = 2;
k_stelaCSF_mod_1cpd = 2;
k_barten_mod_1cpd = 2;


% N = length(luminance_indices) * length(size_indices) * length(vrr_f_indices) * num_obs / length(luminance_indices);

% 针对Luminance画全部
figure; % 创建主图
total_iterations = length(size_indices) * length(luminance_indices);
current_iteration = 0;
h = waitbar(0, 'Rendering Progress...');
for size_value = size_indices
    for luminance_value = luminance_indices
        current_iteration = current_iteration + 1;
        waitbar(current_iteration / total_iterations, h);
        vrr_f_list = [];
        average_C_t_list = [];
        for vrr_f_value = vrr_f_indices   
            filtered_data = data(data.Luminance == luminance_value & data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
            valid_data = filtered_data(~isnan(filtered_data.C_t), :);
            average_C_t = mean(valid_data.C_t);
            vrr_f_list = [vrr_f_list, vrr_f_value];
            average_C_t_list = [average_C_t_list, average_C_t];
        end

        vrr_f_CSF_list = linspace( 1, 10 )';

        result_stelaCSF = zeros(size(vrr_f_CSF_list));
        result_stelaCSF_mod = zeros(size(vrr_f_CSF_list));
        result_barten_mod = zeros(size(vrr_f_CSF_list));
        result_stelaCSF_transient = zeros(size(vrr_f_CSF_list));
        result_stelaCSF_mod_transient = zeros(size(vrr_f_CSF_list));
        result_stelaCSF_cyc_1 = zeros(size(vrr_f_CSF_list));
        result_stelaCSF_mod_cyc_1 = zeros(size(vrr_f_CSF_list));
        result_barten_mod_cyc_1 = zeros(size(vrr_f_CSF_list));

        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_CSF_list, 'orientation', 0, 'luminance', luminance_value, 'area', size_value^2, 'eccentricity', 0);
        for i = 1:length(vrr_f_CSF_list)
            [result_stelaCSF(i), result_stelaCSF_mod(i), result_barten_mod(i)] = multiple_contrast_energy_detectors(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
            [result_stelaCSF_transient(i), result_stelaCSF_mod_transient(i)] = multiple_contrast_energy_detectors_transient(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
            [result_stelaCSF_cyc_1(i), result_stelaCSF_mod_cyc_1(i), result_barten_mod_cyc_1(i)] = multiple_contrast_energy_detectors_cyc_1(luminance_value, c, beta, num_points, vrr_f_CSF_list(i), size_value^2);
        end
        result_stelaCSF_1cpd = stelacsf_model.sensitivity(csf_pars);
        result_stelaCSF_mod_1cpd = stelacsf_mod_model.sensitivity(csf_pars);
        result_barten_mod_1cpd = barten_mod_model.sensitivity(csf_pars);
        
        C_t_stelaCSF = 1./(k_stelaCSF * result_stelaCSF);
        C_t_stelaCSF_mod = 1./(k_stelaCSF_mod * result_stelaCSF_mod);
        C_t_barten_mod = 1./(k_barten_mod * result_barten_mod);
        C_t_stelaCSF_transient = 1./(k_stelaCSF_transient * result_stelaCSF_transient);
        C_t_stelaCSF_mod_transient = 1./(k_stelaCSF_mod_transient * result_stelaCSF_mod_transient);
        C_t_stelaCSF_cyc_1 = 1./(k_stelaCSF_cyc_1 * result_stelaCSF_cyc_1);
        C_t_stelaCSF_mod_cyc_1 = 1./(k_stelaCSF_mod_cyc_1 * result_stelaCSF_mod_cyc_1);
        C_t_barten_mod_cyc_1 = 1./(k_barten_mod_cyc_1 * result_barten_mod_cyc_1);
        C_t_stelaCSF_1cpd = 1./(k_stelaCSF_1cpd * result_stelaCSF_1cpd);
        C_t_stelaCSF_mod_1cpd = 1./(k_stelaCSF_mod_1cpd * result_stelaCSF_mod_1cpd);
        C_t_barten_mod_1cpd = 1./(k_barten_mod_1cpd * result_barten_mod_1cpd);

        
        subplot(length(size_indices), length(luminance_indices), (find(size_indices == size_value)-1)*length(luminance_indices) + find(luminance_indices == luminance_value));
        hold on;
        scatter(vrr_f_list, average_C_t_list, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
        plot(vrr_f_CSF_list, C_t_stelaCSF, 'r-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF (Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_mod, 'g-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF_{mod} (Energy)');
        plot(vrr_f_CSF_list, C_t_barten_mod, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Barten_{mod} (Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_transient, 'c-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF_{mod}_{transient} (Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_mod_transient, 'm-', 'LineWidth', 1.5, 'DisplayName', 'Barten_{mod} (Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_cyc_1, 'y-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF (*frequency Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_mod_cyc_1, 'k-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF_{mod} (*frequency Energy)');
        plot(vrr_f_CSF_list, C_t_barten_mod_cyc_1, 'Color', [0.5, 0.2, 0.8], 'LineWidth', 1.5, 'DisplayName', 'Barten_{mod} (*frequency Energy)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_1cpd, 'Color', [0.8, 0.4, 0.2], 'LineWidth', 1.5, 'DisplayName', 'stelaCSF (1 cpd)');
        plot(vrr_f_CSF_list, C_t_stelaCSF_mod_1cpd, 'Color', [0.2, 0.6, 0.4], 'LineWidth', 1.5, 'DisplayName', 'stelaCSF_{mod} (1 cpd)');
        plot(vrr_f_CSF_list, C_t_barten_mod_1cpd, 'Color', [0.1, 0.9, 0.3], 'LineWidth', 1.5, 'DisplayName', 'Barten_{mod} (1 cpd)');

        hold off;
        xlabel('Frequency of RR switch (Hz)');
        ylabel('C_t (Average across Observers)');
        title(['Size: ' num2str(size_value) '\times' num2str(size_value) ' degree, Luminance: ' num2str(luminance_value) ' nits']);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        xlim([1, 10]); % Specify the x-axis range
        % ylim([0, 0.03]); % Specify the y-axis range
        legend('show'); % 添加图例
        
    end
end