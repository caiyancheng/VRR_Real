function [L_thr_stela, C_t_stela] = final_contrast_energy_model_stela(t_frequency, area_value, radius, E_thr, fit_poly_degree, Luminance_lb, Luminance_ub) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    initial_L_thr = 3;
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    options = optimset('Display', 'off');
    fun_stela = @(L_thr) abs(E_stela(L_thr) - E_thr);
    [L_thr_stela, min_difference_stela] = fmincon(fun_stela, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela = get_contrast_from_Luminance(L_thr_stela, fit_poly_degree, radius);
end