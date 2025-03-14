clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

fit_config.csf_models = {CSF_elTCSF_energy_new(), CSF_stelaCSF_HF()};
csf_models = cell( length(fit_config.csf_models), 1);
csf_model_names = cell( length(fit_config.csf_models), 1 );
N_models = length(fit_config.csf_models);
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-2024-5-7-elaTCSF12_yancheng_comparisions_CSF_ours_stelaCSF_HF";
initial_k_scale_s = ones(N_models,1)*0.1740; %S_new = S / k


size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = linspace(0.4, 16, 100);

optimize_need = 1;
csv_generate_FRR = 1;
plot_FRR = 1;

% 加载训练的参数
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

% 阅读主观实验数据
average_S_matrix = NaN(length(FRR_indices), length(size_indices)); %主观实验的结果
high_S_matrix = NaN(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_S_matrix = NaN(length(FRR_indices), length(size_indices)); %主观实验的结果下界
S_subjective_path = 'E:\Matlab_codes\csf_datasets\raw_data\yancheng2024/yancheng2024_sensitivity_average.csv';
S_predictions_all_models = NaN(N_models, length(FRR_indices), length(size_indices));
data = readtable(S_subjective_path);
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value/pi)^0.5;
    else
        area_value = pi*(size_value/2)^2;
        radius = size_value/2;
    end
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        filtered_data = data(((data.Radius - radius).^2 < 0.1) & data.FRR == FRR_value, :);
        if (height(filtered_data) >= 1)
            valids(FRR_i, size_i) = 1;
        else
            continue
        end
        average_S_matrix(FRR_i, size_i) = filtered_data.Sensitivity;
        high_S_matrix(FRR_i, size_i) = filtered_data.low_Sensitivity;
        low_S_matrix(FRR_i, size_i) = filtered_data.high_Sensitivity;
        [lms_bkg, lms_delta] = luminance_2_lms(filtered_data.Luminance);

        for model_index = 1:N_models
            csf_pars = struct('t_frequency', FRR_value, 'luminance', filtered_data.Luminance, 'lms_bkg', lms_bkg, ...
                'lms_delta', lms_delta, 'area', area_value, 'ge_sigma', radius,'eccentricity', 0);
            sensitivity = csf_models{model_index}.sensitivity_edge(csf_pars);
            S_predictions_all_models(model_index, FRR_i, size_i) = sensitivity;
        end
    end
end

% 是否需要fit k_values参数
optimized_k_scale_s = ones(N_models,1); %S_new = S / k
fvals = ones(N_models,1); %S_new = S / k

if (optimize_need == 1)
    options = optimset('Display', 'iter');
    for model_index=1:N_models
        csf_model_use = csf_models{model_index};
        loss_func_fit = @(k_scale) VRR_CSF_loss_func_2(csf_model_use, size_indices, FRR_indices, average_S_matrix, k_scale, VRR_Luminance_transform);
        loss_initial = loss_func_fit(initial_k_scale_s(model_index));
        lb = 0.001;
        ub = 1000;
        [optimized_k_scale, fval] = fmincon(@(k_scale) loss_func_fit(k_scale), initial_k_scale_s(model_index), [], [], [], [], lb, ub, [], options);
        optimized_k_scale_s(model_index) = optimized_k_scale;
        fvals(model_index) = fval;
    end
    writematrix(optimized_k_scale_s, 'fit_result/VRR_Flicker_elTCSF/optimized_k_scale_s_VRR_elTCSF9.csv');
    writematrix(fvals, 'fit_result/VRR_Flicker_elTCSF/fvals_VRR_elTCSF9.csv');
else
    optimized_k_scale_s = readmatrix('fit_result/VRR_Flicker_elTCSF/optimized_k_scale_s_VRR_elTCSF9.csv');
end

% optimized_k_scale_s = 0.12;

% 生成X轴是时间频率的csv文件
S_results_x_FRR_range = zeros(N_models, length(FRR_range), length(size_indices));
if (csv_generate_FRR == 1)
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi)^0.5;
        else
            radius = size_value/2;
            area_value = pi*radius^2;
        end
        for FRR_range_i = 1:length(FRR_range)
            FRR_range_value = FRR_range(FRR_range_i);
            for model_index = 1:N_models
                csf_model_use = csf_models{model_index};
                VRR_Luminance = VRR_Luminance_transform.AT2L_FRR(FRR_range_value, size_value);
                csf_pars = struct('s_frequency', 0, 't_frequency', FRR_range_value, 'orientation', 0, ...
                    'luminance', VRR_Luminance, 'area', area_value, 'eccentricity', 0);
                S_thr_csf = csf_model_use.sensitivity(csf_pars) ./ optimized_k_scale_s(model_index);
                S_results_x_FRR_range(model_index, FRR_range_i, size_i) = S_thr_csf;
            end
        end
    end
    writematrix(S_results_x_FRR_range, 'fit_result/VRR_Flicker_elTCSF/S_elTCSF9_results_x_FRR_range');
else
    S_results_x_FRR_range_flat = readmatrix('fit_result/VRR_Flicker_elTCSF/S_elTCSF9_results_x_FRR_range');
    S_results_x_FRR_range = reshape(S_results_x_FRR_range_flat, [N_models, length(FRR_range), length(size_indices)]);
end

% 是否绘图
if plot_FRR == 1
    figure;
    Y_labels = [10,20,50,100,200,500];
    ha = tight_subplot(1, 1, [.04 .02],[.12 .01],[.09 .00]);
    set(ha,'YTick',Y_labels);
    set(ha,'YTickLabel',Y_labels);
    set(ha,'XTick',FRR_indices);
    set(ha,'XTickLabel',FRR_indices);
    xlim([0.4, 16]);
    ylim([min(Y_labels),max(Y_labels)]);
    xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
    ylabel('Sensitivity','FontSize',14);
    color = ['r', 'g', 'b', 'm'];
    hh = [];
    for size_i = 1:length(size_indices)
        error_upper = high_S_matrix(:, size_i) - average_S_matrix(:, size_i);
        error_lower = average_S_matrix(:, size_i) - low_S_matrix(:, size_i);
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi)^0.5;
            display_name_gt = 'Subjective Result - Size: 62.7^{\circ}*37.8^{\circ}';
            display_name_predict = 'elTCSF9 Prediction - Size: 62.7^{\circ}*37.8^{\circ}';
        else
            area_value = pi*size_value^2;
            radius = size_value;
            display_name_gt = ['Subjective Result - Size: disk radius ' num2str(size_value/2) '^{\circ}'];
            display_name_predict = ['elTCSF9 Prediction - Size: disk radius ' num2str(size_value/2) '^{\circ}'];
        end
        hold on;
        % set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        hh(end+1) = plot(FRR_indices, average_S_matrix(:, size_i), 'o-', 'Color', color(size_i), 'MarkerFaceColor', color(size_i), 'LineWidth', 1.0, 'DisplayName', display_name_gt);
        hh(end+1) = plot(FRR_range, S_results_x_FRR_range(1,:,size_i), '-', 'LineWidth', 3, 'Color', color(size_i), 'DisplayName', display_name_predict);
        if (size_i == 1)
            hh(end+1) = errorbar(FRR_indices, average_S_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0, 'DisplayName', 'Psychometric function fitting error bar');
        else
            errorbar(FRR_indices, average_S_matrix(:, size_i), error_lower, error_upper, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.0);
        end
        grid on;
    end
    hLegend = legend(hh,'FontSize',9);
end
