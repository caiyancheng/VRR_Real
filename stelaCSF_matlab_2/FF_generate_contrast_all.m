function [L_thr, C_thr] = FF_generate_contrast_all(csf_model, t_frequency, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub)
    initial_L_thr = Luminance_lb;
    options = optimset('Display', 'off');
    S_FF = @(L_thr) k_scale * S_FF_generate(csf_model, L_thr, area_value, t_frequency);
    fun = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / S_FF(L_thr));
    [L_thr, min_difference] = fmincon(fun, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_thr = get_contrast_from_Luminance(L_thr, fit_poly_degree, radius);
end