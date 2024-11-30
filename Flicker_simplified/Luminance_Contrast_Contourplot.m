clear all;
clc;

calculate_need = 0;
plot_need = 1;


Luminance_range = logspace(log10(0.1), log10(1000), 20);
T_frequency_range = logspace(log10(1), log10(16),100);
width_list = [2*atan(1920/1080/6.4)/pi*180, ...
    2*atan(3840/2160/3.2)/pi*180, ...
    2*atan(7680/4320/1.6)/pi*180]; %三种不同类型分别针对1920*1080, 3840*2160, 7680*4320
height_list = [2*atan(1/6.4)/pi*180, ...
    2*atan(1/3.2)/pi*180, ...
    2*atan(1/1.6)/pi*180];

if calculate_need == 1
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

    Peak_sensitivity_matrix = zeros(length(width_list), length(Luminance_range));
    for Luminance_index = 1:length(Luminance_range)
        Luminance_value = Luminance_range(Luminance_index);
        for display_pattern_index = 1:length(width_list)
            width_value = width_list(display_pattern_index);
            height_value = height_list(display_pattern_index);
            area_value = width_value * height_value;
            sensitivity_list = [];
            for t_frequency_index = 1:length(T_frequency_range)
                t_frequency_value = T_frequency_range(t_frequency_index);
                csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency_value, 'orientation', 0, ...
                    'luminance', Luminance_value, 'area', area_value, ...
                    'width', width_value, 'height', height_value, 'eccentricity', 0);
                S = csf_elaTCSF_model.sensitivity_rect(csf_pars);
                sensitivity_list(end+1) = S;
            end
            peak_sensitivity = max(sensitivity_list);
            Peak_sensitivity_matrix(display_pattern_index, Luminance_index) = peak_sensitivity;
        end
    end
    writematrix(Peak_sensitivity_matrix, 'compute_results/Peak_sensitivity_matrix');
else
    Peak_sensitivity_matrix_flat = readmatrix('compute_results/Peak_sensitivity_matrix');
    Peak_sensitivity_matrix = reshape(Peak_sensitivity_matrix_flat, [length(width_list), length(Luminance_range)]);
end

if plot_need == 1
    Font_size = 12;
    Contrast_range = logspace(log10(0.001), log10(1), 50);
    % Contrast_range = linspace(0, 1, 50);
    X_Luminance_plot = zeros([length(Luminance_range), length(Contrast_range)]);
    Y_Contrast_plot = zeros([length(Luminance_range), length(Contrast_range)]);
    Z_JND_plot_log10 = zeros([length(width_list), length(Luminance_range), length(Contrast_range)]);
    for luminance_index = 1:length(Luminance_range)
        luminance_value = Luminance_range(luminance_index);
        for contrast_index = 1:length(Contrast_range)
            contrast_value = Contrast_range(contrast_index);
            X_Luminance_plot(luminance_index, contrast_index) = luminance_value;
            Y_Contrast_plot(luminance_index, contrast_index) = contrast_value;
            for display_pattern_index = 1:length(width_list)
                Z_JND_plot_log10(display_pattern_index, luminance_index, contrast_index) = log10(Peak_sensitivity_matrix(display_pattern_index, luminance_index) * contrast_value);
            end
        end
    end
    ha = tight_subplot(1, length(width_list), [.06 .06],[.12 .05],[.06 .02]); %三种不同类型的显示器分辨率
    set(gcf, 'Position', [100, 100, 1100, 450]);
    Title_Dict = {'Display 1: 1920*1080', 'Display 2: 3840*2160', 'Display 3: 7680*4320'};
    for display_pattern_index = 1:length(width_list)
        axes(ha(display_pattern_index));
        contour_values = [1, 2, 5, 10];
        [C, h] = contour(X_Luminance_plot, Y_Contrast_plot, squeeze(10.^Z_JND_plot_log10(display_pattern_index,:,:)), contour_values);
        clabel(C, h);
        % c = colorbar;
        % c.Ticks = [-1,0,1,2];
        % c.TickLabels = [0.1,1,10,100];
        title(Title_Dict{display_pattern_index}, FontSize=Font_size);
        xlabel('Luminance (cd/m^2)', FontSize=Font_size);
        ylabel('Contrast', FontSize=Font_size);
        set(gca, 'XScale', 'log');
        set(gca, 'YScale', 'log');
        xticks([0.1, 1, 10, 100, 1000]);
        xticklabels([0.1, 1, 10, 100, 1000]);
        yticks([0.001, 0.01, 0.1, 1]);
        yticklabels([0.001, 0.01, 0.1, 1]);
        % yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);
        % yticklabels([0, 0.2, 0.4, 0.6, 0.8, 1.0]);
    end
end

