function [L_thr, C_thr] = peak_generate_contrast_all_2(csf_model, t_frequency, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed)
    initial_L_thr = 3;
    options = optimset('Display', 'off');
    % S_peak = @(L_thr) k_scale * S_peak_generate(csf_model, peak_spatial_frequency, L_thr, area_value, t_frequency);
    % fun = @(L_thr) abs(get_contrast_from_Luminance(L_thr, fit_poly_degree, radius) - 1 / S_peak(L_thr));
    % [L_thr, min_difference] = fmincon(fun, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    L_thr = luminance_fixed;
    C_thr = get_contrast_from_Luminance(L_thr, fit_poly_degree, radius);
end