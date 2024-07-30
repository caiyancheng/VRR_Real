clear all;
clc;

default_area = 100;
default_ecc = 0;
default_lum = 10;
Luminance_range = logspace(log10(1),log10(1000),20);
Area_range = logspace(log10(1),log10(1000),20);
% Ecc_range = linspace(0,60,20);

search_refresh_rate_range = linspace(0,20,100);

csf_elaTCSF_model = CSF_elaTCSF_16();
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-try-CSF_elaTCSF_16_new";

% Sensitivity Peak with varying Luminance
peak_t_f_matrix_lum = zeros(1,length(Luminance_range));
for lum_index = 1:length(Luminance_range)
    lum_value = Luminance_range(lum_index);
    peak_t_f_search_matrix = zeros(1,length(search_refresh_rate_range));
    for t_f_index = 1:length(search_refresh_rate_range)
        t_f_value = search_refresh_rate_range(t_f_index);
        csf_pars = struct('s_frequency', 0, 't_frequency', t_f_value, 'orientation', 0, ...
                'luminance', lum_value, 'area', default_area, 'eccentricity', default_ecc);
        sensitivity = csf_elaTCSF_model.sensitivity(csf_pars);
        peak_t_f_search_matrix(t_f_index) = sensitivity;
    end
    [max_s_value, max_s_index] = max(peak_t_f_search_matrix);
    peak_t_f_value = search_refresh_rate_range(max_s_index);
    peak_t_f_matrix_lum(lum_index) = peak_t_f_value;
end

% Sensitivity Peak with varying Eccentricity
peak_t_f_matrix_area = zeros(1,length(Luminance_range));
for area_index = 1:length(Area_range)
    area_value = Area_range(area_index);
    peak_t_f_search_matrix = zeros(1,length(search_refresh_rate_range));
    for t_f_index = 1:length(search_refresh_rate_range)
        t_f_value = search_refresh_rate_range(t_f_index);
        csf_pars = struct('s_frequency', 0, 't_frequency', t_f_value, 'orientation', 0, ...
                'luminance', default_lum, 'area', area_value, 'eccentricity', default_ecc);
        sensitivity = csf_elaTCSF_model.sensitivity(csf_pars);
        peak_t_f_search_matrix(t_f_index) = sensitivity;
    end
    [max_s_value, max_s_index] = max(peak_t_f_search_matrix);
    peak_t_f_value = search_refresh_rate_range(max_s_index);
    peak_t_f_matrix_area(area_index) = peak_t_f_value;
end

X = 1;