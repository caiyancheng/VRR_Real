function [L_thr_stela, C_t_stela] = final_ff_stela(t_frequency, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub)
    initial_L_thr = 3;
    rho = 1/(2*(pi)^0.5*radius);
    options = optimset('Display', 'off');
    fun_stela = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / (k_scale*S_stela(rho, L_thr, area_value, t_frequency)));
    [L_thr_stela, min_difference_stela] = fmincon(fun_stela, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela = get_contrast_from_Luminance(L_thr_stela, fit_poly_degree, radius);
end

function value = S_stela(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end