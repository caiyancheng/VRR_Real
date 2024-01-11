function [L_thr_barten, C_t_barten] = final_ff_barten_mod(t_frequency, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub)
    initial_L_thr = 3;
    rho = 1/(2*(pi)^0.5*radius);
    options = optimset('Display', 'off');
    fun_barten = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / (k_scale*S_barten_mod(rho, L_thr, area_value, t_frequency)));
    [L_thr_barten, min_difference_barten] = fmincon(fun_barten, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_barten = get_contrast_from_Luminance(L_thr_barten, fit_poly_degree, radius);
end

function value = S_barten_mod(rho, L_b, area_value, t_frequency)
    barten_mod_model = CSF_stmBartenVeridical();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = barten_mod_model.sensitivity(csf_pars);
end
