function E = energy_model_pure_spatial_eccentricity(csf_model, radius, s_frequency, t_frequency, luminance_value, eccentricity, contrast, beta)
fix_area_value = 1;
S_ecc = @(r,theta) S_CSF(csf_model, s_frequency, t_frequency, luminance_value, fix_area_value, (r.^2+eccentricity.^2+2.*eccentricity.*r.*cos(theta)).^0.5).^beta.*r;
E = contrast.^beta .* integral2(S_ecc, 0, radius, 0, 2*pi);
end

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end