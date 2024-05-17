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

optimize_need = 0;
csv_generate_FRR = 0;
plot_FRR = 0;
generate_surface = 0;
plot_surface = 1;

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
        loss_func_fit = @(param) VRR_Energy_loss_func(csf_model_use, size_indices, FRR_indices, average_S_matrix, 10.^param(1), 10.^param(2), VRR_Luminance_transform);
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
                VRR_Luminance = VRR_Luminance_transform.AT2L_FRR(FRR_range_value, size_value);
                % csf_pars = struct('s_frequency', 0, 't_frequency', FRR_range_value, 'orientation', 0, ...
                %     'luminance', VRR_Luminance, 'area', area_value, 'eccentricity', 0);
                % S_ecc = @(r,theta) S_CSF(csf_model_use, 0, FRR_range_value, VRR_Luminance, 1, (r.^2).^0.5).^optimized_beta(model_index).*r;
                % intergration_value = integral2(S_ecc, 0, radius, 0, 2*pi);
                % contrast = (optimized_E_thr_s(model_index) ./ intergration_value).^(1/optimized_beta(model_index));
                % S_thr_csf = 1 ./ contrast;
                S_thr_csf = Energy_S(csf_model_use, FRR_range_value, VRR_Luminance, radius, optimized_E_thr_s(model_index), optimized_beta(model_index));
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
            display_name_predict = 'elTCSF11 Prediction - Size: 62.7^{\circ}*37.8^{\circ}';
        else
            area_value = pi*size_value^2;
            radius = size_value;
            display_name_gt = ['Subjective Result - Size: disk radius ' num2str(size_value/2) '^{\circ}'];
            display_name_predict = ['elTCSF11 Prediction - Size: disk radius ' num2str(size_value/2) '^{\circ}'];
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

Luminance_plot_list = logspace(log10(0.5), log10(100), 100);
Area_plot_list = logspace(log10(1),log10(1000),100);
Ecc_plot_list = linspace(0, 60, 60);
Temporal_Frequency_list = logspace(log10(0.5), log10(32), 100);

if (generate_surface == 1)
    Sensitivity_luminance_temporal = zeros(length(Luminance_plot_list), length(Temporal_Frequency_list));
    Luminance_surface_matrix = zeros(length(Luminance_plot_list), length(Temporal_Frequency_list));
    TF_surface_matrix_1 = zeros(length(Luminance_plot_list), length(Temporal_Frequency_list));
    for Luminance_index = 1:length(Luminance_plot_list)
        Luminance_value = Luminance_plot_list(Luminance_index);
        for tf_index = 1:length(Temporal_Frequency_list)
            tf_value = Temporal_Frequency_list(tf_index);
            Luminance_surface_matrix(Luminance_index, tf_index) = Luminance_value;
            TF_surface_matrix_1(Luminance_index, tf_index) = tf_value;
            Sensitivity_luminance_temporal(Luminance_index, tf_index) = Energy_S(csf_models{1}, tf_value, Luminance_value, 1, optimized_E_thr_s(1), optimized_beta(1));
        end
    end
    writematrix(Luminance_surface_matrix, 'fit_result/VRR_Flicker_elTCSF_Energy/Luminance_surface_matrix');
    writematrix(TF_surface_matrix_1, 'fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_1');
    writematrix(Sensitivity_luminance_temporal, 'fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_luminance_temporal');

    Sensitivity_area_temporal = zeros(length(Area_plot_list), length(Temporal_Frequency_list));
    Area_surface_matrix = zeros(length(Area_plot_list), length(Temporal_Frequency_list));
    TF_surface_matrix_2 = zeros(length(Area_plot_list), length(Temporal_Frequency_list));
    for Area_index = 1:length(Area_plot_list)
        Area_value = Area_plot_list(Area_index);
        radius_value = (Area_value / pi) ^ 0.5;
        for tf_index = 1:length(Temporal_Frequency_list)
            tf_value = Temporal_Frequency_list(tf_index);
            Area_surface_matrix(Area_index, tf_index) = Area_value;
            TF_surface_matrix_2(Area_index, tf_index) = tf_value;
            Sensitivity_area_temporal(Area_index, tf_index) = Energy_S(csf_models{1}, tf_value, 3, radius_value, optimized_E_thr_s(1), optimized_beta(1));
        end
    end

    writematrix(Area_surface_matrix, 'fit_result/VRR_Flicker_elTCSF_Energy/Area_surface_matrix');
    writematrix(TF_surface_matrix_2, 'fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_2');
    writematrix(Sensitivity_area_temporal, 'fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_area_temporal');

    Sensitivity_ecc_temporal = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    Ecc_surface_matrix = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    TF_surface_matrix_3 = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    for Ecc_index = 1:length(Ecc_plot_list)
        Ecc_value = Ecc_plot_list(Ecc_index);
        for tf_index = 1:length(Temporal_Frequency_list)
            tf_value = Temporal_Frequency_list(tf_index);
            Ecc_surface_matrix(Ecc_index, tf_index) = Ecc_value;
            TF_surface_matrix_3(Ecc_index, tf_index) = tf_value;
            Sensitivity_ecc_temporal(Ecc_index, tf_index) = Energy_S_ecc(csf_models{1}, tf_value, 3, radius_value, optimized_E_thr_s(1), optimized_beta(1), Ecc_value);
        end
    end

    writematrix(Ecc_surface_matrix, 'fit_result/VRR_Flicker_elTCSF_Energy/Ecc_surface_matrix');
    writematrix(TF_surface_matrix_3, 'fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_3');
    writematrix(Sensitivity_ecc_temporal, 'fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_ecc_temporal');
else
    Luminance_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Luminance_surface_matrix');
    Luminance_surface_matrix = reshape(Luminance_surface_matrix_flat, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_1 = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_1');
    TF_surface_matrix_1 = reshape(TF_surface_matrix_flat_1, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_luminance_temporal_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_luminance_temporal');
    Sensitivity_luminance_temporal = reshape(Sensitivity_luminance_temporal_flat, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);

    Area_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Area_surface_matrix');
    Area_surface_matrix = reshape(Area_surface_matrix_flat, [length(Area_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_2 = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_2');
    TF_surface_matrix_2 = reshape(TF_surface_matrix_flat_2, [length(Area_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_area_temporal_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_area_temporal');
    Sensitivity_area_temporal = reshape(Sensitivity_area_temporal_flat, [length(Area_plot_list), length(Temporal_Frequency_list)]);

    Ecc_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Ecc_surface_matrix');
    Ecc_surface_matrix = reshape(Ecc_surface_matrix_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_3 = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/TF_surface_matrix_3');
    TF_surface_matrix_3 = reshape(TF_surface_matrix_flat_3, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_ecc_temporal_flat = readmatrix('fit_result/VRR_Flicker_elTCSF_Energy/Sensitivity_ecc_temporal');
    Sensitivity_ecc_temporal = reshape(Sensitivity_ecc_temporal_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
end

if (plot_surface==1) %画三个曲面，水平面分别为Luminance, Radis, Temporal Frequency的组合
    ha = tight_subplot(1, 3, [.13 .05],[.16 .02],[.05 .02]);

    axes(ha(1));
    surf(Ecc_surface_matrix, TF_surface_matrix_3, log10(Sensitivity_ecc_temporal), 'EdgeColor','none');
    hold on;
    colormap(flipud(hsv));
    xlabel('Eccentricity (degree)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity');
    set(gca, 'YScale', 'log');
    xticks([0,10,20,30,40,50,60]);
    xticklabels([0,10,20,30,40,50,60]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks([1,2,3]);
    zticklabels([10,100,1000]);
    zlim([1,3]);
    view(55, 15);
    
    axes(ha(2));
    surf(Luminance_surface_matrix, TF_surface_matrix_1, log10(Sensitivity_luminance_temporal), 'EdgeColor','none');
    colormap(flipud(hsv));
    xlabel('Luminance (cd/m^2)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    xticks([1,10,100]);
    xticklabels([1,10,100]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks([1,2,3]);
    zticklabels([10,100,1000]);
    zlim([1,3]);
    view(55, 15);
    
    axes(ha(3));
    surf(Area_surface_matrix, TF_surface_matrix_2, log10(Sensitivity_area_temporal), 'EdgeColor','none');
    colormap(flipud(hsv));
    xlabel('Area (degree^2)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks([1,2,3]);
    zticklabels([10,100,1000]);
    zlim([1,3]);
    view(55, 15);

end

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end

function energy_s = Energy_S(csf_model, t_frequency, luminance, radius, E_thr, beta)
S_ecc = @(r,theta) S_CSF(csf_model, 0, t_frequency, luminance, 1, (r.^2).^0.5).^beta.*r;
intergration_value = integral2(S_ecc, 0, radius, 0, 2*pi);
contrast = (E_thr ./ intergration_value).^(1/beta);
energy_s = 1 ./ contrast;
end

function energy_s = Energy_S_ecc(csf_model, t_frequency, luminance, radius, E_thr, beta, eccentricity)
S_ecc = @(r,theta) S_CSF(csf_model, 0, t_frequency, luminance, 1, (r.^2 + eccentricity.^2 + 2.*eccentricity.*r.*cos(theta)).^0.5).^beta.*r;
intergration_value = integral2(S_ecc, 0, radius, 0, 2*pi);
contrast = (E_thr ./ intergration_value).^(1/beta);
energy_s = 1 ./ contrast;
end
