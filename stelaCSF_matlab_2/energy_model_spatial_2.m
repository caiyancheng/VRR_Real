function E = energy_model_spatial_2(csf_model, fit_poly_degree, radius, area_value, vrr_f_value, luminance_value)
    delta_rho = 0.01;
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';
    I_fourier = get_contrast_from_Luminance(luminance_value, fit_poly_degree, radius).*D(rho_sum, radius).*S_CSF(csf_model, rho_sum, luminance_value, area_value, vrr_f_value);
    I_spatial = fftshift(abs(fft( cat( 1, I_fourier, flipud(I_fourier(2:end,:)) ), [], 1 )), 1);
    ppd = rho_sum(end)*2;
    size_deg = size(I_spatial,1)/ppd;
    yy = linspace( -size_deg/2, size_deg/2, size(I_spatial,1) )';
    E = pi*trapz( yy, (I_spatial).^2 .* abs(yy) );
end

function value = S_CSF(csf_model, rho, L_b, area_value, t_frequency)
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);% 'ge_sigma',1);
    value = csf_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end