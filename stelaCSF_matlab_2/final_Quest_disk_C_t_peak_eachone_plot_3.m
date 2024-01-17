%这段代码只画那些比baseline好或者有潜力比baseline好的模型
clear;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 2, 4, 8];
num_obs = 1;
num_points = 1000;
continuous_vrr_f_range = logspace(log10(0.25), log10(10), 40)';
continuous_area_range = logspace(log10(pi*0.25^2*0.8), log10(62.666 * 37.808 * 1.2), 40)';
fit_poly_degree = 4;
area_fix = 1;
Luminance_lb = 0.05;
Luminance_ub = 8;
beta = 3.5;

c_t_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
suffixes = {'stelaCSF (Peak)', 'stelaCSF_{HF} (Peak)', 'BartenCSF (Peak)', 'BartenCSF_{HF} (Peak)', ...
            'castleCSF (Peak)', 'stelaCSF transient (Peak)', 'stelaCSF_{HF} transient (Peak)'};

stelaCSF_model = CSF_stelaCSF();
stelaCSF_HF_model = CSF_stelaCSF_HF();
Barten_Original_model = CSF_Barten_Original();
Barten_HF_model = CSF_Barten_HF();
castleCSF_model = CSF_castleCSF();
stelaCSF_transient_model = CSF_stelaCSF_transient();
stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();
CSF_Model_cell = {stelaCSF_model, stelaCSF_HF_model, Barten_Original_model, Barten_HF_model, castleCSF_model, stelaCSF_transient_model, stelaCSF_HF_transient_model};

C_thr_results_x_vrr_f_range = zeros(length(suffixes), length(continuous_vrr_f_range), length(size_indices));
C_thr_results_x_area_range = zeros(length(suffixes), length(vrr_f_indices), length(continuous_area_range));
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices));
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices));
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices));
valids = zeros(length(vrr_f_indices), length(size_indices));
peak_spatial_frequency = logspace(log10(0.1), log10(100), 100)';
initial_k_scale_values = zeros(1,length(suffixes));

optimize_need = 1;
csv_generate_vrr_f = 1;
csv_generate_area = 1;
plot_vrr_f = 1;
plot_area = 1;

for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
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

if optimize_need == 1
    initial_setting_vrr_f_index = 2;
    initial_setting_vrr_f_value = vrr_f_indices(initial_setting_vrr_f_index);
    initial_setting_radius_index = 2;
    initial_setting_radius_value = size_indices(initial_setting_radius_index)/2;
    initial_setting_area_value = pi * (initial_setting_radius_value)^2;
    initial_setting_luminance_value = 2;
    for csf_model_index = 1:length(CSF_Model_cell)
        csf_model_use = CSF_Model_cell{csf_model_index};
        S_peak = S_peak_generate(csf_model_use, peak_spatial_frequency, initial_setting_luminance_value, initial_setting_area_value, initial_setting_vrr_f_value);
        C_thr_sub = average_C_t_matrix(initial_setting_vrr_f_index, initial_setting_radius_index);
        initial_k_scale_values(csf_model_index) = 1 /  (S_peak * C_thr_sub);
    end
end

loss_multiple_factor = 1; %e10;

optimized_k_scale_values = zeros(length(suffixes), 1);
fvals = zeros(length(suffixes), 1);
lb = 0;  % 下界
ub = Inf; % 上界
luminance_fixed = 4;

if (optimize_need == 1)
    options = optimset('Display', 'iter');
    for csf_model_index = 1:length(CSF_Model_cell)
        csf_model_use = CSF_Model_cell{csf_model_index};
        objective_function = @(k_scale_value) peak_fit_loss_all_2(csf_model_use, size_indices, vrr_f_indices, average_C_t_matrix, ...
            k_scale_value, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed).*loss_multiple_factor;
        loss_initial = objective_function(initial_k_scale_values(csf_model_index));
        [optimized_k_scale_value, fval] = fmincon(@(k_scale_value) objective_function(k_scale_value),  initial_k_scale_values(csf_model_index), [], [], [], [], lb, ub, [], options);
        optimized_k_scale_values(csf_model_index) = optimized_k_scale_value;
        fvals(csf_model_index) = fval./loss_multiple_factor;
    end
    writematrix(optimized_k_scale_values, 'optimized_k_scale_values_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
    writematrix(fvals, 'fvals_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
else
    optimized_k_scale_values = readmatrix('optimized_k_scale_values_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
end

if (csv_generate_vrr_f == 1)
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi)^0.5;
        else
            radius = size_value/2;
            area_value = pi*radius^2;
        end
        for vrr_f_range_i = 1:length(continuous_vrr_f_range)
            vrr_f_range_value = continuous_vrr_f_range(vrr_f_range_i);
            for csf_model_index = 1:length(CSF_Model_cell)
                csf_model_use = CSF_Model_cell{csf_model_index};
                [~,C_thr_results_x_vrr_f_range(csf_model_index,vrr_f_range_i,size_i)] = ...
                    peak_generate_contrast_all_2(csf_model_use, vrr_f_range_value, area_value, radius, ...
                    optimized_k_scale_values(csf_model_index), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed);
            end
        end
    end
    writematrix(C_thr_results_x_vrr_f_range, 'C_thr_results_range_x_vrr_f_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
else
    C_thr_results_x_vrr_f_range_flat = readmatrix('C_thr_results_range_x_vrr_f_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
    C_thr_results_x_vrr_f_range = reshape(C_thr_results_x_vrr_f_range_flat, [length(suffixes), length(continuous_vrr_f_range), length(size_indices)]);
end

if (csv_generate_area == 1)
    for vrr_f_i = 1:length(vrr_f_indices)
        vrr_f_value = vrr_f_indices(vrr_f_i);
        for area_range_i = 1:length(continuous_area_range)
            area_range_value = continuous_area_range(area_range_i);
            radius_range_value = (area_range_value/pi)^0.5;
            for csf_model_index = 1:length(CSF_Model_cell)
                csf_model_use = CSF_Model_cell{csf_model_index};
                [~,C_thr_results_x_area_range(csf_model_index,vrr_f_i,area_range_i)] = ...
                    peak_generate_contrast_all_2(csf_model_use, vrr_f_value, area_range_value, radius, ...
                    optimized_k_scale_values(csf_model_index), fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed);
            end
        end
    end
    writematrix(C_thr_results_x_area_range, 'C_thr_results_range_x_area_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
else
    C_thr_results_x_area_range_flat = readmatrix('C_thr_results_range_x_area_final_Quest_disk_C_t_peak_eachone_plot_3.csv');
    C_thr_results_x_area_range = reshape(C_thr_results_x_area_range_flat, [length(suffixes), length(vrr_f_indices), length(continuous_area_range)]);
end

%VRR-F
if plot_vrr_f == 1
    figure;
    ha = tight_subplot(2, 4, [.07 .02],[.23 .05],[.035 .01]);
    set(ha,'YTick',[0.005, 0.01, 0.05, 0.1]); 
    set(ha,'YTickLabel',[0.005, 0.01, 0.05, 0.1]); 
    set(ha,'XTick',[0.5, 1, 2, 4, 8]); 
    set(ha,'XTickLabel',[0.5, 1, 2, 4, 8]);
    for plot_i = 1:length(suffixes)
        axes(ha(plot_i));
        xlim([0.25, 8.5]);
        ylim([0.005, 0.1]);
        if (plot_i == 1)
            ylabel('C_{thr} (Flicker Detection Contrast Threshold)','FontSize',18);
        end
        if (plot_i == 3)
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
                radius = (area_value/pi)^0.5;
                display_name_exp = 'Subjective Psychophysical Result - Size: full screen 62.7^{\circ}*37.8^{\circ}';
                display_name_model = 'Model Predicition - Size: full screen 62.7^{\circ}*37.8^{\circ}';
            else
                radius = size_value/2;
                area_value = pi*radius^2;
                display_name_exp = ['Subjective Psychophysical Result - Size: disk diameter ' num2str(size_value) '^{\circ}'];
                display_name_model = ['Model Predicition - Size: disk diameter ' num2str(size_value) '^{\circ}'];
            end
            hold on;
            set(gca, 'XScale', 'log');
            set(gca, 'YScale', 'log');
            legend_exp_plots{end+1} = scatter(vrr_f_indices, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name_exp);
            legend_exp_labels{end+1} = display_name_exp;
            if (size_i == 1)
                legend_errorbar_plots{end+1} = errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
                legend_errorbar_labels{end+1} = 'Psychometric function fitting error bar';
            else
                errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
            end
            legend_model_plots{end+1} = plot(continuous_vrr_f_range, C_thr_results_x_vrr_f_range(plot_i,:,size_i), '-', 'LineWidth', 1, 'Color', color(size_i), 'DisplayName', display_name_model);
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
    legendPos(2) = 0.06 - legendPos(4)/2;
    set(hLegend_2, 'Position', legendPos);
end

%AREA
if plot_area == 1
    figure;
    ha = tight_subplot(2, 4, [.07 .02],[.23 .05],[.035 .01]);
    area_indices = [pi*0.25^2, pi*0.5^2, pi*8^2, 62.666 * 37.808];
    set(ha,'YTick',[0.005, 0.01, 0.05, 0.1]); 
    set(ha,'YTickLabel',[0.005, 0.01, 0.05, 0.1]); 
    set(ha,'XTick',area_indices); 
    set(ha,'XTickLabel',area_indices);
    for plot_i = 1:length(suffixes)
        axes(ha(plot_i));
        xlim([pi*0.25^2*0.8, 62.666 * 37.808*1.2]);
        ylim([0.005, 0.1]);
        if (plot_i == 1)
            ylabel('C_{thr} (Flicker Detection Contrast Threshold)','FontSize',18);
        end
        if (plot_i == 3)
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
            error_upper = high_C_t_matrix(vrr_f_i,:) - average_C_t_matrix(vrr_f_i,:);
            error_lower = average_C_t_matrix(vrr_f_i,:) - low_C_t_matrix(vrr_f_i,:);
            vrr_f_value = vrr_f_indices(vrr_f_i);
            display_name_exp = ['Subjective Result - Frequency of RR Switch: ' num2str(vrr_f_value) ' Hz'];
            display_name_model = ['Model Predicition  - Frequency of RR Switch: ' num2str(vrr_f_value) ' Hz'];
            hold on;
            set(gca, 'XScale', 'log');
            set(gca, 'YScale', 'log');
            legend_exp_plots{end+1} = scatter(area_indices, average_C_t_matrix(vrr_f_i,:), 50, 'Marker', 'o', 'MarkerFaceColor', color(vrr_f_i), 'LineWidth', 1.0, 'DisplayName', display_name_exp);
            legend_exp_labels{end+1} = display_name_exp;
            if (vrr_f_i == 1)
                legend_errorbar_plots{end+1} = errorbar(area_indices, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
                legend_errorbar_labels{end+1} = 'Psychometric function fitting error bar';
            else
                errorbar(area_indices, average_C_t_matrix(vrr_f_i,:), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
            end
            legend_model_plots{end+1} = plot(continuous_area_range, reshape(C_thr_results_x_area_range(plot_i,vrr_f_i,:), 1, []), '-', 'LineWidth', 1, 'Color', color(vrr_f_i), 'DisplayName', display_name_model);
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
    legendPos(2) = 0.06 - legendPos(4)/2;
    set(hLegend_2, 'Position', legendPos);
end