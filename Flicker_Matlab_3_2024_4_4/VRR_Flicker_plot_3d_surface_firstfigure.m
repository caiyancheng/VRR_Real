clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

fit_config.csf_models = {CSF_elaTCSF_16()};
csf_models = cell( length(fit_config.csf_models), 1);
csf_model_names = cell( length(fit_config.csf_models), 1 );
N_models = length(fit_config.csf_models);
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-try-CSF_elaTCSF_16_new";

size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = linspace(0.4, 16, 100);

generate_surface = 0;
plot_surface = 1;
default_ecc = 0;
default_lum = 3;
default_area = 1;

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

Luminance_plot_list = logspace(log10(0.5), log10(100), 50);
Area_plot_list = logspace(log10(1),log10(1000), 50);
Ecc_plot_list = linspace(0, 60, 50);
Temporal_Frequency_list = logspace(log10(0.5), log10(32), 50);

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
            csf_pars = struct('s_frequency', 0, 't_frequency', tf_value, 'orientation', 0, ...
                        'luminance', Luminance_value, 'area', default_area, 'eccentricity', default_ecc);
            Sensitivity_luminance_temporal(Luminance_index, tf_index) = csf_models{1}.sensitivity(csf_pars);
        end
    end
    writematrix(Luminance_surface_matrix, 'fit_result/VRR_Flicker_elaTCSF/Luminance_surface_matrix');
    writematrix(TF_surface_matrix_1, 'fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_1');
    writematrix(Sensitivity_luminance_temporal, 'fit_result/VRR_Flicker_elaTCSF/Sensitivity_luminance_temporal');

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
            csf_pars = struct('s_frequency', 0, 't_frequency', tf_value, 'orientation', 0, ...
                        'luminance', default_lum, 'area', Area_value, 'eccentricity', default_ecc);
            Sensitivity_area_temporal(Area_index, tf_index) = csf_models{1}.sensitivity(csf_pars);
        end
    end

    writematrix(Area_surface_matrix, 'fit_result/VRR_Flicker_elaTCSF/Area_surface_matrix');
    writematrix(TF_surface_matrix_2, 'fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_2');
    writematrix(Sensitivity_area_temporal, 'fit_result/VRR_Flicker_elaTCSF/Sensitivity_area_temporal');

    Sensitivity_ecc_temporal = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    Ecc_surface_matrix = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    TF_surface_matrix_3 = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    for Ecc_index = 1:length(Ecc_plot_list)
        Ecc_value = Ecc_plot_list(Ecc_index);
        for tf_index = 1:length(Temporal_Frequency_list)
            tf_value = Temporal_Frequency_list(tf_index);
            Ecc_surface_matrix(Ecc_index, tf_index) = Ecc_value;
            TF_surface_matrix_3(Ecc_index, tf_index) = tf_value;
            csf_pars = struct('s_frequency', 0, 't_frequency', tf_value, 'orientation', 0, ...
                        'luminance', default_lum, 'area', default_area, 'eccentricity', Ecc_value);
            Sensitivity_ecc_temporal(Ecc_index, tf_index) = csf_models{1}.sensitivity(csf_pars);
        end
    end

    writematrix(Ecc_surface_matrix, 'fit_result/VRR_Flicker_elaTCSF/Ecc_surface_matrix');
    writematrix(TF_surface_matrix_3, 'fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_3');
    writematrix(Sensitivity_ecc_temporal, 'fit_result/VRR_Flicker_elaTCSF/Sensitivity_ecc_temporal');
else
    Luminance_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Luminance_surface_matrix');
    Luminance_surface_matrix = reshape(Luminance_surface_matrix_flat, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_1 = readmatrix('fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_1');
    TF_surface_matrix_1 = reshape(TF_surface_matrix_flat_1, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_luminance_temporal_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Sensitivity_luminance_temporal');
    Sensitivity_luminance_temporal = reshape(Sensitivity_luminance_temporal_flat, [length(Luminance_plot_list), length(Temporal_Frequency_list)]);

    Area_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Area_surface_matrix');
    Area_surface_matrix = reshape(Area_surface_matrix_flat, [length(Area_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_2 = readmatrix('fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_2');
    TF_surface_matrix_2 = reshape(TF_surface_matrix_flat_2, [length(Area_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_area_temporal_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Sensitivity_area_temporal');
    Sensitivity_area_temporal = reshape(Sensitivity_area_temporal_flat, [length(Area_plot_list), length(Temporal_Frequency_list)]);

    Ecc_surface_matrix_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Ecc_surface_matrix');
    Ecc_surface_matrix = reshape(Ecc_surface_matrix_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_flat_3 = readmatrix('fit_result/VRR_Flicker_elaTCSF/TF_surface_matrix_3');
    TF_surface_matrix_3 = reshape(TF_surface_matrix_flat_3, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    Sensitivity_ecc_temporal_flat = readmatrix('fit_result/VRR_Flicker_elaTCSF/Sensitivity_ecc_temporal');
    Sensitivity_ecc_temporal = reshape(Sensitivity_ecc_temporal_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
end

sensitivity_ticks = [0,1,2,3];
sensitivity_ticks_labels = [1,10,100,1000];

if (plot_surface==1) %画三个曲面，水平面分别为Luminance, Radis, Temporal Frequency的组合
    ha = tight_subplot(1, 3, [.13 .05],[.16 .02],[.05 .02]);

    axes(ha(1));
    hh = surf(Ecc_surface_matrix, TF_surface_matrix_3, log10(Sensitivity_ecc_temporal), 'EdgeColor','none', 'FaceAlpha', 0.8, ...
        'DisplayName', ['Luminance = ' num2str(default_lum) ' cd/m^2; Area = ' num2str(default_area) ' degree^2']);
    hold on;
    colormap(flipud(hsv));
    xlabel('Eccentricity (degree)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity', FontSize=12);
    % title(['Luminance = ' default_lum ' cd/m^2; Area = ' default_area ' degree^2'])
    set(gca, 'YScale', 'log');
    xticks([0,10,20,30,40,50,60]);
    xticklabels([0,10,20,30,40,50,60]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks(sensitivity_ticks);
    zticklabels(sensitivity_ticks_labels);
    zlim([min(sensitivity_ticks),max(sensitivity_ticks)]);
    % legend (hh, 'Location', 'best', 'Orientation', 'horizontal');
    view(55, 15);
    
    axes(ha(2));
    hh = surf(Luminance_surface_matrix, TF_surface_matrix_1, log10(Sensitivity_luminance_temporal), 'EdgeColor','none', 'FaceAlpha', 0.8, ...
        'DisplayName', ['Eccentricity = ' num2str(default_ecc) ' degree; Area = ' num2str(default_area) ' degree^2']);
    colormap(flipud(hsv));
    xlabel('Luminance (cd/m^2)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity');
    % title(['Eccentricity = ' default_ecc ' degree; Area = ' default_area ' degree^2'])
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    xticks([1,10,100]);
    xticklabels([1,10,100]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks(sensitivity_ticks);
    zticklabels(sensitivity_ticks_labels);
    zlim([min(sensitivity_ticks),max(sensitivity_ticks)]);
    % legend (hh, 'Location', 'best', 'Orientation', 'horizontal');
    view(55, 15);
    
    axes(ha(3));
    hh = surf(Area_surface_matrix, TF_surface_matrix_2, log10(Sensitivity_area_temporal), 'EdgeColor','none', 'FaceAlpha', 0.8, ...
        'DisplayName', ['Eccentricity = ' num2str(default_ecc) ' degree; Luminance = ' num2str(default_lum) ' cd/m^2']);
    colormap(flipud(hsv));
    xlabel('Area (degree^2)');
    ylabel('Temporal Frequency (Hz)');
    zlabel('Sensitivity');
    % title(['Eccentricity = ' default_ecc ' degree; Luminance = ' default_lum ' cd/m^2'])
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks(sensitivity_ticks);
    zticklabels(sensitivity_ticks_labels);
    zlim([min(sensitivity_ticks),max(sensitivity_ticks)]);
    % legend (hh, 'Location', 'best', 'Orientation', 'horizontal');
    view(55, 15);

end
