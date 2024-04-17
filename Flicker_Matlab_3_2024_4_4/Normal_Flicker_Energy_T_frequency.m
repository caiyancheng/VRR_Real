clear all;
fit_config.csf_models = {CSF_elTCSF_3()};
luminance = 3;
radius_list = [1,4,8,16,32];
s_frequency = 0;
beta = 3;
% contrast = 0.03; %Search for the Contrast
Energy_threshold = [80];
t_frequency_list = linspace(1,20,100);

csf_models = cell( length(fit_config.csf_models), 1);
csf_model_names = cell( length(fit_config.csf_models), 1 );
N_models = length(fit_config.csf_models);
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\csf-cyc-2024-3-28-elTCSF3-all_flicker_dataset_1";
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

    for radius_index = 1:length(radius_list)
        radius = radius_list(radius_index);
        sensitivity_list = zeros(1,length(t_frequency_list));
        for t_frequency_index = 1:length(t_frequency_list)
            t_frequency = t_frequency_list(t_frequency_index);
            energy_func = @(contrast) energy_model_pure_spatial_eccentricity(csf_models{model_index, 1}, radius, s_frequency, t_frequency, luminance, 0, contrast, beta);
            contrast_result = binary_search_vec(energy_func, Energy_threshold(model_index), [0.001 1], 20);
            sensitivity_list(t_frequency_index) = 1./contrast_result;
        end
        hh(length(hh)+1) = plot(t_frequency_list, sensitivity_list, 'DisplayName', [csf_model_names{model_index}, 'radius = ', num2str(radius)]);
        hold on;
    end
end
legend(hh);
xlabel('Temporal Frequency (Hz)');
ylabel('Sensitivity (Not regulized)');
