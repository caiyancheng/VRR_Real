function E = energy_model_fixarea_beta(csf_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value)
    fix_area_value = 1;
    beta = 3.5;
    delta_rho = 0.01;
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';
    integrand_CSF = @(rho, L_thr) 2 * pi * (2 * pi * radius)^(1/beta) * get_contrast_from_Luminance(L_thr, ...
        fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_CSF(csf_model, rho, L_thr, fix_area_value, vrr_f_value)).^2) .* rho;
    E = delta_rho * sum(integrand_CSF(rho_sum, luminance_value));
end

function value = S_CSF(csf_model, rho, L_b, area_value, t_frequency)
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);% 'ge_sigma',1);
    value = csf_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end