function E = energy_model_pure_spatial(csf_model, radius, s_frequency, t_frequency, luminance_value, contrast, beta)
num_r_points = 100;
r_all = linspace(0, radius, num_r_points)';
fix_area_value = 1; %Fix or not fix? Who knows
S = S_CSF(csf_model, s_frequency, t_frequency, luminance_value, fix_area_value, r_all);
E = contrast.^beta .* sum(S.^beta) .* radius./num_r_points;
end

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end