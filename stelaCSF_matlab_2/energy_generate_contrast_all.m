function [L_thr, C_thr] = energy_generate_contrast_all(csf_model, energy_model, vrr_f_value, area_value, radius, E_thr, fit_poly_degree, Luminance_lb, Luminance_ub) 
    E = @(L_thr) energy_model(csf_model, fit_poly_degree, radius, area_value, vrr_f_value, L_thr);
    options = optimset('Display', 'off');
    fun = @(L_thr) abs(E(L_thr) - E_thr);
    initial_L_thr = 3;
    [L_thr, min_difference] = fmincon(fun, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_thr = get_contrast_from_Luminance(L_thr, fit_poly_degree, radius);
end