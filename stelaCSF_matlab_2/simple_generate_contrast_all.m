function [L_thr, C_thr] = simple_generate_contrast_all(csf_model_use, area_value, vrr_f_value, k_scale_value, s_frequency_value, fit_poly_degree, Luminance_lb, Luminance_ub)
initial_L_thr = Luminance_lb;
options = optimset('Display', 'off');
radius = area_value^0.5;
C_thr_simple = @(L_thr) 1 / (k_scale_value * get_S_simple(csf_model_use, s_frequency_value, vrr_f_value, L_thr, area_value, 0));
fun = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - C_thr_simple(L_thr));
[L_thr, min_difference] = fmincon(fun, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
C_thr = get_contrast_from_Luminance(L_thr, fit_poly_degree, radius);
end

function S_simple = get_S_simple(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
S_simple = csf_model.sensitivity(csf_pars);
end