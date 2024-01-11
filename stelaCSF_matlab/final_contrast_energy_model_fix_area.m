function [L_thr_stela, L_thr_stela_mod, L_thr_barten_mod, C_t_stela, C_t_stela_mod, C_t_barten_mod] = ...
    final_contrast_energy_model_fix_area(t_frequency, radius, E_thr, fit_poly_degree, fix_area, Luminance_lb, Luminance_ub) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    initial_L_thr = 1;
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    integrand_stela_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    integrand_barten_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_barten_mod(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    E_stela_mod = @(L_thr) delta_rho * sum(integrand_stela_mod(rho_sum, L_thr));
    E_barten_mod = @(L_thr) delta_rho * sum(integrand_barten_mod(rho_sum, L_thr));

    lb = 0.04; %估算Luminance
    ub = 10;
    options = optimset('Display', 'off');  % 关闭输出优化过程
    fun_stela = @(L_thr) abs(E_stela(L_thr) - E_thr(1));
    fun_stela_mod = @(L_thr) abs(E_stela_mod(L_thr) - E_thr(2));
    fun_barten_mod = @(L_thr) abs(E_barten_mod(L_thr) - E_thr(3));
    [L_thr_stela, min_difference_stela] = fmincon(fun_stela, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    [L_thr_stela_mod, min_difference_stela_mod] = fmincon(fun_stela_mod, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    [L_thr_barten_mod, min_difference_barten_mod] = fmincon(fun_barten_mod, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela = get_contrast_from_Luminance(L_thr_stela, fit_poly_degree, radius);
    C_t_stela_mod = get_contrast_from_Luminance(L_thr_stela_mod, fit_poly_degree, radius);
    C_t_barten_mod = get_contrast_from_Luminance(L_thr_barten_mod, fit_poly_degree, radius);
end

function [L_thr_stela, C_t_stela] = final_contrast_energy_model_stela_fix_area(t_frequency, radius, E_thr, fit_poly_degree, fix_area) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    lb = 0.04;
    ub = 10;
    options = optimset('Display', 'off');
    fun_stela = @(L_thr) abs(E_stela(L_thr) - E_thr);
    [L_thr_stela, min_difference_stela] = fmincon(fun_stela, initial_L_thr, [], [], [], [], lb, ub, [], options);
    C_t_stela = get_contrast_from_Luminance(L_thr_stela, fit_poly_degree, radius);
end

function [L_thr_stela_mod, C_t_stela_mod] = final_contrast_energy_model_stela_mod_fix_area(t_frequency, radius, E_thr, fit_poly_degree, fix_area) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_stela_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    E_stela_mod = @(L_thr) delta_rho * sum(integrand_stela_mod(rho_sum, L_thr));
    lb = 0.04;
    ub = 10;
    options = optimset('Display', 'off');
    fun_stela_mod = @(L_thr) abs(E_stela_mod(L_thr) - E_thr);
    [L_thr_stela_mod, min_difference_stela_mod] = fmincon(fun_stela_mod, initial_L_thr, [], [], [], [], lb, ub, [], options);
    C_t_stela_mod = get_contrast_from_Luminance(L_thr_stela_mod, fit_poly_degree, radius);
end

function [L_thr_barten_mod, C_t_barten_mod] = final_contrast_energy_model_barten_mod_fix_area(t_frequency, radius, E_thr, fit_poly_degree, fix_area) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_barten_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_barten_mod(rho, L_thr, fix_area, t_frequency)).^2) .* rho;
    E_barten_mod = @(L_thr) delta_rho * sum(integrand_barten_mod(rho_sum, L_thr));
    lb = 0.04;
    ub = 10;
    options = optimset('Display', 'off');
    fun_barten_mod = @(L_thr) abs(E_barten_mod(L_thr) - E_thr(3));
    [L_thr_barten_mod, min_difference_barten_mod] = fmincon(fun_barten_mod, initial_L_thr, [], [], [], [], lb, ub, [], options);
    C_t_barten_mod = get_contrast_from_Luminance(L_thr_barten_mod, fit_poly_degree, radius);
end


function value = S_stela(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function value = S_stela_mod(rho, L_b, area_value, t_frequency)
    stelacsf_mod_model = CSF_stelaCSF_mod();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_mod_model.sensitivity(csf_pars);
end

function value = S_barten_mod(rho, L_b, area_value, t_frequency)
    barten_mod_model = CSF_stmBartenVeridical();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = barten_mod_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end