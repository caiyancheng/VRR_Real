function [result_stela, result_stela_mod, result_barten_mod] = multiple_contrast_energy_detectors_cyc_1_no_multiply(L_b, c, beta, num_points, t_frequency, size_value) 
    delta_rho = 0.01;  % Width of each small interval
    rho = linspace(0, num_points * delta_rho, num_points)';  % Transpose to make it a column vector
    % Function to be integrated
    r = size_value/2;
    integrand_stela = @(rho) (c^2 .* (D(rho, r) .* S_stela(rho, L_b, size_value, t_frequency)).^2) .* rho;
    integrand_stela_mod = @(rho) (c^2 .* (D(rho, r) .* S_stela_mod(rho, L_b, size_value, t_frequency)).^2) .* rho;
    integrand_barten_mod = @(rho) (c^2 .* (D(rho, r) .* S_barten_mod(rho, L_b, size_value, t_frequency)).^2) .* rho;
    
    % Numerical integration using the trapezoidal rule
    result_stela = trapz(rho, integrand_stela(rho));
    result_stela_mod = trapz(rho, integrand_stela_mod(rho));
    result_barten_mod = trapz(rho, integrand_barten_mod(rho));
    
    % Multiply by delta_rho to account for the width of each interval
    result_stela = (result_stela * delta_rho * t_frequency.^2).^0.5;
    result_stela_mod = (result_stela_mod * delta_rho * t_frequency.^2).^0.5;
    result_barten_mod = (result_barten_mod * delta_rho * t_frequency.^2).^0.5;
end

function value = S_stela(rho, L_b, size_value, t_frequency)
    stelacsf_model = CSF_stelaCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', size_value/2, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function value = S_stela_mod(rho, L_b, size_value, t_frequency)
    stelacsf_mod_model = CSF_stelaCSF_mod();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', size_value/2, 'eccentricity', 0);
    value = stelacsf_mod_model.sensitivity(csf_pars);
end

function value = S_barten_mod(rho, L_b, size_value, t_frequency)
    barten_mod_model = CSF_stmBartenVeridical();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', size_value/2, 'eccentricity', 0);
    value = barten_mod_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end