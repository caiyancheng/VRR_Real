clear all;
clc;

size_indices = [0.5, 1, 16, -1]; %-1 means full
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
FRR_range = linspace(0.4, 16, 100);

generate_surface = 0;
plot_surface = 1;
default_ecc = 0;
default_lum = 10;
default_area = 1;

% 左图是sensitivity与eccentricity, t_frequency的关系
% 右图是cff与eccentricity, luminance的关系
% 加载训练的参数
% csf_elaTCSF_model = CSF_elaTCSF_16();
% fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-try-CSF_elaTCSF_16_new";
csf_elaTCSF_model = CSF_elaTCSF_16_TCSF_free();
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\SIGGRAPH2025_final_revision_CSF_elaTCSF_16_TCSF_free_1";
fname = fullfile( fitpars_dir, strcat(csf_elaTCSF_model.short_name(), '_all_*.mat' ) );
fl = dir( fname );
if isempty(fl)
    error( 'Fitted parameters missing for %s', fit_config.csf_models{model_index}.short_name() );
end
ind_latest = find( [fl(:).datenum]==max([fl(:).datenum]) );
fitted_pars_file = fullfile( fl(ind_latest).folder, fl(ind_latest).name );
fit_data = load( fitted_pars_file );
fprintf( 1, "Loaded: %s\n", fitted_pars_file )
csf_elaTCSF_model.par = CSF_base.update_struct( fit_data.fitted_struct, csf_elaTCSF_model.par );
csf_elaTCSF_model = csf_elaTCSF_model.set_pars(csf_elaTCSF_model.get_pars());

Luminance_plot_list = logspace(log10(1), log10(100), 20);
Area_plot_list = logspace(log10(1),log10(1000), 20);
Ecc_plot_list = linspace(0, 60, 20);
Temporal_Frequency_list = logspace(log10(0.5), log10(32), 20);

if (generate_surface == 1)
    Sensitivity_ecc_temporal_1 = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    Ecc_surface_matrix_1 = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    TF_surface_matrix_1 = zeros(length(Ecc_plot_list), length(Temporal_Frequency_list));
    for Ecc_index = 1:length(Ecc_plot_list)
        Ecc_value = Ecc_plot_list(Ecc_index);
        for tf_index = 1:length(Temporal_Frequency_list)
            tf_value = Temporal_Frequency_list(tf_index);
            Ecc_surface_matrix_1(Ecc_index, tf_index) = Ecc_value;
            TF_surface_matrix_1(Ecc_index, tf_index) = tf_value;
            csf_pars = struct('s_frequency', 0, 't_frequency', tf_value, 'orientation', 0, ...
                'luminance', default_lum, 'area', default_area, 'eccentricity', Ecc_value);
            Sensitivity_ecc_temporal_1(Ecc_index, tf_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(Sensitivity_ecc_temporal_1, 'first_figure/Sensitivity_ecc_temporal_1');
    writematrix(Ecc_surface_matrix_1, 'first_figure/Ecc_surface_matrix_1');
    writematrix(TF_surface_matrix_1, 'first_figure/TF_surface_matrix_1');


    CFF_luminance_ecc_2 = zeros(length(Luminance_plot_list), length(Ecc_plot_list));
    Luminance_surface_matrix_2 = zeros(length(Luminance_plot_list), length(Ecc_plot_list));
    Ecc_surface_matrix_2 = zeros(length(Luminance_plot_list), length(Ecc_plot_list));
    for Luminance_index = 1:length(Luminance_plot_list)
        Luminance_value = Luminance_plot_list(Luminance_index);
        for Ecc_index = 1:length(Ecc_plot_list)
            Ecc_value = Ecc_plot_list(Ecc_index);
            Luminance_surface_matrix_2(Luminance_index, Ecc_index) = Luminance_value;
            Ecc_surface_matrix_2(Luminance_index, Ecc_index) = Ecc_value;
            bs_func = @(omega) - csf_elaTCSF_model.sensitivity(struct('s_frequency', 0, 't_frequency', omega, 'orientation', 0, ...
                'luminance', Luminance_value, 'area', default_area, 'eccentricity', Ecc_value));
            cff = binary_search_vec(bs_func, -1, [8 400], 20);
            CFF_luminance_ecc_2(Luminance_index, Ecc_index) = cff;
        end
    end
    writematrix(CFF_luminance_ecc_2, 'first_figure/CFF_luminance_ecc_2');
    writematrix(Luminance_surface_matrix_2, 'first_figure/Luminance_surface_matrix_2');
    writematrix(Ecc_surface_matrix_2, 'first_figure/Ecc_surface_matrix_2');

else
    Sensitivity_ecc_temporal_1_flat = readmatrix('first_figure/Sensitivity_ecc_temporal_1');
    Sensitivity_ecc_temporal_1 = reshape(Sensitivity_ecc_temporal_1_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    Ecc_surface_matrix_1_flat = readmatrix('first_figure/Ecc_surface_matrix_1');
    Ecc_surface_matrix_1 = reshape(Ecc_surface_matrix_1_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);
    TF_surface_matrix_1_flat = readmatrix('first_figure/TF_surface_matrix_1');
    TF_surface_matrix_1 = reshape(TF_surface_matrix_1_flat, [length(Ecc_plot_list), length(Temporal_Frequency_list)]);

    CFF_luminance_ecc_2_flat = readmatrix('first_figure/CFF_luminance_ecc_2');
    CFF_luminance_ecc_2 = reshape(CFF_luminance_ecc_2_flat, [length(Luminance_plot_list), length(Ecc_plot_list)]);
    Luminance_surface_matrix_2_flat = readmatrix('first_figure/Luminance_surface_matrix_2');
    Luminance_surface_matrix_2 = reshape(Luminance_surface_matrix_2_flat, [length(Luminance_plot_list), length(Ecc_plot_list)]);
    Ecc_surface_matrix_2_flat = readmatrix('first_figure/Ecc_surface_matrix_2');
    Ecc_surface_matrix_2 = reshape(Ecc_surface_matrix_2_flat, [length(Luminance_plot_list), length(Ecc_plot_list)]);

end

sensitivity_ticks = [0,1,2,3];
sensitivity_ticks_labels = [1,10,100,1000];
CFF_ticks = [10,20,30,40,50,60,70,80,90,100];

if (plot_surface==1)
    ha = tight_subplot(1, 2, [.13 .09],[.16 .02],[.07 .04]);
    set(gcf, 'Position', [100, 100, 1050, 400]);

    axes(ha(1));
    surf(Ecc_surface_matrix_1, TF_surface_matrix_1, log10(Sensitivity_ecc_temporal_1), 'EdgeColor','none', 'FaceAlpha', 1);
    hold on;
    colormap(flipud(hsv));
    xlabel('Eccentricity (degree)', FontSize=14);
    ylabel('Temporal Frequency (Hz)', FontSize=14);
    zlabel('Sensitivity', FontSize=14);
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
    surf(Luminance_surface_matrix_2, Ecc_surface_matrix_2, CFF_luminance_ecc_2, 'EdgeColor','none', 'FaceAlpha', 1);
    hold on;
    colormap(flipud(hsv));
    xlabel('Luminance (cd/m^2)', FontSize=14);
    ylabel('Eccentricity (degree)', FontSize=14);
    zlabel('Critical Flicker Frequency (Hz)', FontSize=14);
    % title(['Luminance = ' default_lum ' cd/m^2; Area = ' default_area ' degree^2'])
    set(gca, 'XScale', 'log');
    xticks([1,10,100]);
    xticklabels([1,10,100]);
    yticks([0,10,20,30,40,50,60]);
    yticklabels([0,10,20,30,40,50,60]);
    zticks(CFF_ticks);
    zticklabels(CFF_ticks);
    zlim([min(CFF_ticks),max(CFF_ticks)]);
    % legend (hh, 'Location', 'best', 'Orientation', 'horizontal');
    view(55, 15);
end
