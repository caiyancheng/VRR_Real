clear all;
clc;

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

width = 64;
height = 38;

csf_pars_min = struct('s_frequency', 0, 't_frequency', 2, 'orientation', 0, ...
                'luminance', 10, 'area', pi*(height/2)^2, 'eccentricity', 10);
csf_pars_max = struct('s_frequency', 0, 't_frequency', 2, 'orientation', 0, ...
                'luminance', 10, 'area', pi*(width/2)^2, 'eccentricity', 10);
csf_pars_rect = struct('s_frequency', 0, 't_frequency', 2, 'orientation', 0, ...
                'luminance', 10, 'area', width * height, 'width', width, 'height', height, 'eccentricity', 10);

S_cycle_min = csf_elaTCSF_model.sensitivity(csf_pars_min);
S_cycle_max = csf_elaTCSF_model.sensitivity(csf_pars_max);
S_cycle_rect = csf_elaTCSF_model.sensitivity_rect(csf_pars_rect);

X = 1;
