function [L_thr_stela_mod, C_t_stela_mod] = final_peak_stela_mod(t_frequency, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency)
    initial_L_thr = 3;
    options = optimset('Display', 'off');
    fun_stela_mod = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / (k_scale*max(S_stela_mod(peak_spatial_frequency, L_thr, area_value, t_frequency))));
    [L_thr_stela_mod, min_difference_stela_mod] = fmincon(fun_stela_mod, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela_mod = get_contrast_from_Luminance(L_thr_stela_mod, fit_poly_degree, radius);
end

function value = S_stela_mod(rho, L_b, area_value, t_frequency)
    stelacsf_mod_model = CSF_stelaCSF_mod();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_mod_model.sensitivity(csf_pars);
end