luminance_indices = [1, 2, 3, 4, 5, 10, 100];
size_indices = [4, 16];
vrr_f_indices = [2, 5, 10];
num_obs = 4;

c_t_subjective_path = 'E:\Py_codes\VRR_Real\Computational_Model/mu_results.csv';
data = readtable(c_t_subjective_path);

csf_model = CSF_stelaCSF();
k_CSF = 6;

% N = length(luminance_indices) * length(size_indices) * length(vrr_f_indices) * num_obs / length(luminance_indices);

% 针对Luminance画全部
figure; % 创建主图
for size_value = size_indices
    for luminance_value = luminance_indices
        vrr_f_list = [];
        average_C_t_list = [];
        % bino_error_bar_list_down = [];
        % bino_error_bar_list_up = [];
        for vrr_f_value = vrr_f_indices   
            filtered_data = data(data.Luminance == luminance_value & data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
            valid_data = filtered_data(~isnan(filtered_data.C_t), :);
            average_C_t = mean(valid_data.C_t);
            vrr_f_list = [vrr_f_list, vrr_f_value];
            average_C_t_list = [average_C_t_list, average_C_t];
            % erro_bar_down_up = binoinv([0.025, 0.975], N, average_C_t) / N;
            % bino_error_bar_list_down = [bino_error_bar_list_down, erro_bar_down_up(1)];
            % bino_error_bar_list_up = [bino_error_bar_list_up, erro_bar_down_up(2)];
        end

        vrr_f_CSF_list = linspace( 0, 10 )';
        csf_pars = struct('s_frequency', 1, 't_frequency', vrr_f_CSF_list, 'orientation', 0, 'luminance', luminance_value, 'area', size_value, 'eccentricity', 0);
        S = csf_model.sensitivity(csf_pars);
        C_t_CSF = 1./(k_CSF *S);
        
        
        subplot(length(size_indices), length(luminance_indices), (find(size_indices == size_value)-1)*length(luminance_indices) + find(luminance_indices == luminance_value));
        hold on;
        scatter(vrr_f_list, average_C_t_list, 'Marker', 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
        % bar(log10(luminance_list), average_C_t_list, 'FaceColor', 'b', 'EdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', 'Subjective Result');
        % errorbar(log10(luminance_list), average_C_t_list, average_C_t_list - bino_error_bar_list_down, bino_error_bar_list_up - average_C_t_list, 'Color', 'blue', 'CapSize', 3, 'DisplayName', '95% Binomial Confidence Interval');
        plot(vrr_f_CSF_list, C_t_CSF, 'r-', 'LineWidth', 1.5, 'DisplayName', 'stelaCSF (1 cpd)');
        hold off;
        xlabel('Frequency of RR switch (Hz)');
        ylabel('C_t (Average across Observers)');
        title(['Size: ' num2str(size_value) '\times' num2str(size_value) ' degree, Luminance: ' num2str(luminance_value) ' nits']);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        xlim([0, 10]); % Specify the x-axis range
        ylim([0, 0.03]); % Specify the y-axis range
        % legend('show'); % 添加图例
        
    end
end