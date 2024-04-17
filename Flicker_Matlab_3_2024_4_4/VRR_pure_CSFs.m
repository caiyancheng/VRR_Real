clear all;
clc;
size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 2, 4, 8, 10, 12, 14, 16];
vrr_f_range = logspace(log10(0.3), log10(20), 100);
%需要估计Luminance
fit_config.csf_models = {CSF_elTCSF()};
csf_models = cell( length(fit_config.csf_models), 1);
csf_model_names = cell( length(fit_config.csf_models), 1 );
N_models = length(fit_config.csf_models);
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\csf-cyc-2024-3-28-elTCSF-all_flicker_dataset-2";
hh = [];

for model_index=1:N_models
    fname = fullfile( fitpars_dir, strcat( fit_config.csf_models{model_index}.short_name(), '_all_*.mat' ) );
    fl = dir( fname );
    if isempty(fl)
        error( 'Fitted parameters missing for %s', fit_config.csf_models{model_index}.short_name() );
    end
    ind_latest = find( [fl(:).datenum]==max([fl(:).datenum]) );
    fitted_pars_file = fullfile( fl(ind_latest).folder, fl(ind_latest).name );
    fit_data = load( fitted_pars_file );
    fprintf( 1, "Loaded: %s\n", fitted_pars_file )
    fit_config.csf_models{model_index}.par = CSF_base.update_struct( fit_data.fitted_struct, fit_config.csf_models{model_index}.par );
    csf_models{model_index, 1} = fit_config.csf_models{model_index}.set_pars(fit_config.csf_models{model_index}.get_pars());
    csf_model_names{model_index} = csf_models{model_index}.full_name();
end

initial_ks = zeros(1, length(N_models));

average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果
high_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果上界
low_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(vrr_f_indices), length(size_indices)); %这些主观实验是否有效
Ct_results_IDMS_fit = zeros(length(vrr_f_indices), length(size_indices));
Ct_results_IDMS_plot = zeros(length(vrr_f_range), length(size_indices));
c_t_subjective_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_all/D_thr_C_t_gather.csv';
data = readtable(c_t_subjective_path);
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
    else
        area_value = pi*(size_value/2)^2;
        radius = size_value/2;
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
        average_C_t = nanmean(valid_data.C_t);
        high_C_t = nanmean(valid_data.C_t_high);
        low_C_t = nanmean(valid_data.C_t_low);
        average_C_t_matrix(vrr_f_i, size_i) = average_C_t;
        high_C_t_matrix(vrr_f_i, size_i) = high_C_t;
        low_C_t_matrix(vrr_f_i, size_i) = low_C_t;

        Ct_results_IDMS_fit(vrr_f_i,size_i) = 1/S_IDMS(vrr_f_value);
    end
end

%拟合阶段
options = optimset('Display', 'iter');
loss_function_IDMS = @(k_IDMS) loss_IDMS(k_IDMS, size_indices, vrr_f_indices, average_C_t_matrix, Ct_results_IDMS_fit);
lb = 1e-5;
ub = Inf;
[optimized_k_IDMS, fval] = fmincon(loss_function_IDMS, initial_k, [], [], [], [], lb, ub, [], options);

% optimized_k_IDMS = 1;
%正式运算阶段
for size_i = 1:length(size_indices)
    for vrr_f_i = 1:length(vrr_f_range)
        vrr_f_value = vrr_f_range(vrr_f_i);
        Ct_results_IDMS_plot(vrr_f_i,size_i) = 1/(optimized_k_IDMS*S_IDMS(vrr_f_value));
    end
end
%绘图阶段

figure;
ha = tight_subplot(1, 1, [.04 .02],[.12 .01],[.09 .00]);
set(ha,'YTick',[0.001,0.005, 0.01, 0.05, 0.1]);
set(ha,'YTickLabel',[0.001,0.005, 0.01, 0.05, 0.1]);
set(ha,'XTick',[0.5, 1, 2, 4, 8, 10, 12, 14, 16]);
set(ha,'XTickLabel',[0.5, 1, 2, 4, 8, 10, 12, 14, 16]);
xlim([0.3, 20]);
ylim([0.005, 0.1]);
xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
ylabel('C_{thr} (Flicker Detection Contrast Threshold)','FontSize',14);
color = ['r', 'g', 'b', 'm'];
legend_plots = {};
legend_labels = {};
for size_i = 1:length(size_indices)
    error_upper = high_C_t_matrix(:, size_i) - average_C_t_matrix(:, size_i);
    error_lower = average_C_t_matrix(:, size_i) - low_C_t_matrix(:, size_i);
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
        display_name = 'Subjective Psychophysical Result - Size: 62.7^{\circ}*37.8^{\circ}';
    else
        area_value = pi*size_value^2;
        radius = size_value;
        display_name = ['Subjective Psychophysical Result - Size: disk radius ' num2str(size_value) '^{\circ}'];
    end
    hold on;
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    legend_plots{end+1} = plot(vrr_f_indices, average_C_t_matrix(:, size_i), 'o-', 'Color', color(size_i), 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name);
    legend_labels{end+1} = display_name;
    if (size_i == 1)
        legend_plots{end+1} = errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
        legend_labels{end+1} = 'Psychometric function fitting error bar';
    else
        errorbar(vrr_f_indices, average_C_t_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
    end
    grid on;
end
legend_plots{end+1} = plot(vrr_f_range, Ct_results_IDMS_plot(:,1)/optimized_k_IDMS, '--', 'LineWidth', 1, 'Color', 'c', 'DisplayName', 'IDMS 1.1a TCSF C_{thr} Prediciton');
legend_labels{end+1} = 'IDMS 1.1a TCSF C_{thr} Prediciton';
hLegend = legend([legend_plots{1} legend_plots{3} legend_plots{4} legend_plots{5} legend_plots{2} legend_plots{6}], ...
    {legend_labels{1},legend_labels{3},legend_labels{4},legend_labels{5},legend_labels{2},legend_labels{6}},'FontSize',9);

function [loss_sum] = loss_CSFs(csf_model, k_scale, size_indices, vrr_f_indices, average_C_t_matrix)
C_thr_predict_results = zeros(length(vrr_f_indices), length(size_indices));
L_thr_predict_results = zeros(length(vrr_f_indices), length(size_indices));
loss_all = zeros(length(vrr_f_indices), length(size_indices));
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
    else
        area_value = pi*(size_value/2)^2;
        radius = size_value/2;
    end
    for vrr_f_i = 1:length(vrr_f_indices)
        vrr_f_value = vrr_f_indices(vrr_f_i);
        [L_thr_predict_results(vrr_f_i, size_i), C_thr_predict_results(vrr_f_i, size_i)] = csf_generate_contrast(csf_model, vrr_f_value, area_value, radius, k_scale);
        loss = (log10(average_C_t_matrix(vrr_f_i,size_i))-log10(C_thr_predict_results(vrr_f_i,size_i)))^2;
        % if (isnan(loss))
        %     loss_all(vrr_f_i,size_i) = 10;
        % else
        %     loss_all(vrr_f_i,size_i) = loss;
        % end
        loss_all(vrr_f_i,size_i) = loss;
    end
end
loss_sum = nansum(loss_all(:));
end

function [L_thr, C_thr] = csf_generate_contrast(csf_model, t_frequency, area_value, radius, k_scale)
fit_poly_degree = 4;
Luminance_lb = 0.5;
Luminance_ub = 8;
initial_L_thr = 3;
options = optimset('Display', 'off');
S_value = @(L_thr) k_scale * S_CSF(csf_model, t_frequency, area_value, L_thr);
fun = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / S_value(L_thr));
[L_thr, min_difference] = fmincon(fun, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
C_thr = get_contrast_from_Luminance(L_thr, fit_poly_degree, radius);
end

function S = S_CSF(csf_model, t_frequency, area_value, luminance)
csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, 'luminance', luminance, 'area', area_value, 'eccentricity', 0);
S = csf_model.sensitivity(csf_pars);
end