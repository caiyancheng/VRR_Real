function S_peak = S_peak_generate(csf_model, peak_spatial_frequency, L_b, area_value, t_frequency)
    csf_pars = struct('s_frequency', peak_spatial_frequency, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    S_peak = max(csf_model.sensitivity(csf_pars));
end