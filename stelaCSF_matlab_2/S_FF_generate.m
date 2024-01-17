function S_FF = S_FF_generate(csf_model, L_b, area_value, t_frequency)
    radius = (area_value/pi)^0.5;
    rho = 1 / (2*pi^0.5*radius);
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    S_FF = csf_model.sensitivity(csf_pars);
end