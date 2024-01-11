function [L_thr_stela_transient, L_thr_stela_mod_transient, C_t_stela_transient, C_t_stela_mod_transient] = final_contrast_energy_model_transient(t_frequency, area_value, radius, E_thr, fit_poly_degree, Luminance_lb, Luminance_ub) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    initial_L_thr = 1;
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_transient(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    integrand_stela_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod_transient(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    E_stela_mod = @(L_thr) delta_rho * sum(integrand_stela_mod(rho_sum, L_thr));

    options = optimset('Display', 'off');  % 关闭输出优化过程
    fun_stela_transient = @(L_thr) abs(E_stela(L_thr) - E_thr(1));
    fun_stela_mod_transient = @(L_thr) abs(E_stela_mod(L_thr) - E_thr(2));
    [L_thr_stela_transient, min_difference_stela_transient] = fmincon(fun_stela_transient, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    [L_thr_stela_mod_transient, min_difference_stela_mod_transient] = fmincon(fun_stela_mod_transient, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela_transient = get_contrast_from_Luminance(L_thr_stela_transient, fit_poly_degree, radius);
    C_t_stela_mod_transient = get_contrast_from_Luminance(L_thr_stela_mod_transient, fit_poly_degree, radius);
end

function [L_thr_stela_transient, C_t_stela_transient] = final_contrast_energy_model_stela_transient(t_frequency, area_value, radius, E_thr, fit_poly_degree) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_transient(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    lb = 0.04;
    ub = 10;
    options = optimset('Display', 'off');
    fun_stela = @(L_thr) abs(E_stela(L_thr) - E_thr);
    [L_thr_stela_transient, min_difference_stela_transient] = fmincon(fun_stela, initial_L_thr, [], [], [], [], lb, ub, [], options);
    C_t_stela_transient = get_contrast_from_Luminance(L_thr_stela_transient, fit_poly_degree, radius);
end

function [L_thr_stela_mod_transient, C_t_stela_mod_transient] = final_contrast_energy_model_stela_mod_transient(t_frequency, area_value, radius, E_thr, fit_poly_degree) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_stela_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod_transient(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_stela_mod = @(L_thr) delta_rho * sum(integrand_stela_mod(rho_sum, L_thr));
    lb = 0.04;
    ub = 10;
    options = optimset('Display', 'off');
    fun_stela_mod = @(L_thr) abs(E_stela_mod(L_thr) - E_thr);
    [L_thr_stela_mod_transient, min_difference_stela_mod_transient] = fmincon(fun_stela_mod, initial_L_thr, [], [], [], [], lb, ub, [], options);
    C_t_stela_mod_transient = get_contrast_from_Luminance(L_thr_stela_mod_transient, fit_poly_degree, radius);
end

function value = S_stela_transient(rho, L_b, area_value, t_frequency)
    stelacsf_model_transient = CSF_stelaCSF_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model_transient.sensitivity(csf_pars);
end

function value = S_stela_mod_transient(rho, L_b, area_value, t_frequency)
    stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_mod_transient_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end