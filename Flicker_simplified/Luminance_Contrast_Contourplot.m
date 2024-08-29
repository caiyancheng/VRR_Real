clear all;
clc;

Luminance_range = logspace(log10(0.1), log10(1000), 20);
T_frequency_range = logspace(log10(1), log10(16),100);
width_list = [2*atan(1920/1080/6.4)/pi*180, ...
    2*atan(3840/2160/3.2)/pi*180, ...
    2*atan(7680/4320/1.6)/pi*180]; %三种不同类型分别针对1920*1080, 3840*2160, 7680*4320
height_list = [2*atan(1/6.4)/pi*180, ...
    2*atan(1/3.2)/pi*180, ...
    2*atan(1/1.6)/pi*180];

csf_elaTCSF_model = CSF_elaTCSF_16();
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-try-CSF_elaTCSF_16_new";
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

ha = tight_subplot(1, 3, [.13 .09],[.15 .02],[.1 .03]); %三种不同类型的显示器分辨率
