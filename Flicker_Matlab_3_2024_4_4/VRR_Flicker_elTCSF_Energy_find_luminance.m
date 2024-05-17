clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

fit_config.csf_models = {CSF_elTCSF_11()};
csf_models = cell( length(fit_config.csf_models), 1);
csf_model_names = cell( length(fit_config.csf_models), 1 );
N_models = length(fit_config.csf_models);
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\csf-cyc-2024-4-29-elTCSF11-yancheng_1";
initial_E_thr_s = ones(N_models,1)*7.2051;
initial_beta = ones(N_models,1)*4.4061;
% beta = 6;

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
average_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果
high_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果上界
low_S_matrix = zeros(length(FRR_indices), length(size_indices)); %主观实验的结果下界
valids = zeros(length(FRR_indices), length(size_indices)); %这些主观实验是否有效
S_subjective_path = 'E:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_disk_4_all/Matlab_D_thr_S_gather.csv';
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
        filtered_data = data(data.Size_Degree == size_value & data.FRR == FRR_value, :);
        if (height(filtered_data) >= 1)
            valids(FRR_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.Sensitivity), :);
        average_S = 10.^nanmean(log10(valid_data.Sensitivity));
        high_S = 10.^nanmean(log10(valid_data.Sensitivity_high));
        low_S = 10.^nanmean(log10(valid_data.Sensitivity_low));
        average_S_matrix(FRR_i, size_i) = average_S;
        high_S_matrix(FRR_i, size_i) = high_S;
        low_S_matrix(FRR_i, size_i) = low_S;
    end
end

% 是否需要fit Energy_threshold 参数
optimized_E_thr_s = ones(N_models,1); %S_new = S / k
optimized_beta = ones(N_models,1); %S_new = S / k
fvals = ones(N_models,1); %S_new = S / k

if (optimize_need == 1)
    options = optimset('Display', 'iter');
    for model_index=1:N_models
        csf_model_use = csf_models{model_index};
        loss_func_fit = @(param) VRR_Energy_loss_func_find_luminance(csf_model_use, size_indices, FRR_indices, average_S_matrix, 10.^param(1), 10.^param(2), Sensitivity_transform);
        loss_initial = loss_func_fit([log10(initial_E_thr_s(model_index)), log10(initial_beta(model_index))]);
        [optimized_param, fval] = fminunc(@(param) loss_func_fit(param), [log10(initial_E_thr_s(model_index)), log10(initial_beta(model_index))], options);
        optimized_E_thr_s(model_index) = 10.^optimized_param(1);
        optimized_beta(model_index) = 10.^optimized_param(2);
        fvals(model_index) = fval;
    end
    writematrix(optimized_E_thr_s, 'fit_result/VRR_Flicker_elTCSF_Energy/optimized_E_thr_s.csv');
    writematrix(optimized_beta, 'fit_result/VRR_Flicker_elTCSF_Energy/optimized_beta.csv');
    writematrix(fvals, 'fit_result/VRR_Flicker_elTCSF_Energy/fvals.csv');
else
    optimized_E_thr_s = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/optimized_E_thr_s.csv');
    optimized_beta = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/optimized_beta.csv');
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
                [L_thr, S_thr_csf, S_thr_transform] = VRR_find_aim_Luminance_flicker(csf_model_use, FRR_range_value, ...
                    radius, optimized_E_thr_s(model_index), optimized_beta(model_index), Sensitivity_transform);
                S_results_x_FRR_range(model_index, FRR_range_i, size_i) = S_thr_csf;
            end
        end
    end
    writematrix(S_results_x_FRR_range, 'fit_result/VRR_Flicker_elTCSF_Energy/S_elTCSF11_results_x_FRR_range');
else
    S_results_x_FRR_range_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/S_elTCSF11_results_x_FRR_range');
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
    % ylim([min(Y_labels),max(Y_labels)]);
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

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end
