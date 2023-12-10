luminance_indices = [1, 2, 3, 4, 5, 10, 100];
size_indices = [4, 16];
vrr_f_indices = [2, 5, 10];
num_obs = 4;

c_t_subjective_path = '../Computational_Model/mu_results.csv';
data = readtable(c_t_subjective_path);

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
barten_mod_model = CSF_stmBartenVeridical();
k_stelaCSF = 2;
k_stelaCSF_mod = 2;
k_barten_mod = 2;

% N = length(luminance_indices) * length(size_indices) * length(vrr_f_indices) * num_obs / length(luminance_indices);

% 针对Luminance画全部
figure; % 创建主图
% xlabel('Size (Degree)');
% ylabel('C_t (Average across Observers)');
% suplabel('Size (Degree)', 'x');
% suplabel('C_t (Average across Observers)', 'y');
for luminance_value = luminance_indices 
    for vrr_f_value = vrr_f_indices
        size_list = [];
        average_C_t_list = [];
        % bino_error_bar_list_down = [];
        % bino_error_bar_list_up = [];
        for size_value = size_indices  
            filtered_data = data(data.Luminance == luminance_value & data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
            valid_data = filtered_data(~isnan(filtered_data.C_t), :);
            average_C_t = mean(valid_data.C_t);
            size_list = [size_list, size_value];
            average_C_t_list = [average_C_t_list, average_C_t];
            % erro_bar_down_up = binoinv([0.025, 0.975], N, average_C_t) / N;
            % bino_error_bar_list_down = [bino_error_bar_list_down, erro_bar_down_up(1)];
            % bino_error_bar_list_up = [bino_error_bar_list_up, erro_bar_down_up(2)];
        end

        size_CSF_list = linspace( 4, 20 )';
        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_value, 'orientation', 0, 'luminance', luminance_value, 'area', size_CSF_list.^2, 'eccentricity', 0);
        stelaCSF_S = stelacsf_model.sensitivity(csf_pars);
        stelaCSF_mod_S = stelacsf_mod_model.sensitivity(csf_pars);
        barten_mod_S = barten_mod_model.sensitivity(csf_pars);
        C_t_stelaCSF = 1./(k_stelaCSF * stelaCSF_S);
        C_t_stelaCSF_mod = 1./(k_stelaCSF_mod * stelaCSF_mod_S);
        C_t_barten_mod = 1./(k_barten_mod * barten_mod_S);
        
        
        subplot(length(luminance_indices), length(vrr_f_indices), (find(luminance_indices == luminance_value)-1)*length(vrr_f_indices) + find(vrr_f_indices == vrr_f_value));
        hold on;
        scatter(size_list, average_C_t_list, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
        % bar(log10(luminance_list), average_C_t_list, 'FaceColor', 'b', 'EdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
        % errorbar(log10(luminance_list), average_C_t_list, average_C_t_list - bino_error_bar_list_down, bino_error_bar_list_up - average_C_t_list, 'Color', 'blue', 'CapSize', 3, 'DisplayName', '95% Binomial Confidence Interval');
        plot(size_CSF_list, C_t_stelaCSF, 'r-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF (1 cpd)');
        plot(size_CSF_list, C_t_stelaCSF_mod, 'g-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF_{mod} (1 cpd)');
        plot(size_CSF_list, C_t_barten_mod, 'c-', 'LineWidth', 1.5, 'DisplayName', 'Barten_{mod} (1 cpd)');
        hold off;
        % xlabel('Size (Degree)');
        % ylabel('C_t (Average across Observers)');
        title(['Luminance: ' num2str(luminance_value) ' nits, Frequency of RR switch: ' num2str(vrr_f_value) ' Hz']);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        xlim([4, 20]); % Specify the x-axis range
        ylim([0, 0.03]); % Specify the y-axis range
        legend('show'); % 添加图例
        
    end
end

