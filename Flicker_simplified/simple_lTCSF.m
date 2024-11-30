function S = simple_lTCSF(luminance, t_frequency, lum_k1, lum_k2, lum_k3, tcsf_lum_k1, tcsf_lum_b1, area_k1, area_k2)
Area_factor = 1 - 1 ./ (area_k1 + area_k2 .* t_frequency);
S_lum = lum_k1 .* ((1 + lum_k2./luminance) .^ (-lum_k3));
S_TCSF = TCSF(t_frequency, luminance, tcsf_lum_k1, tcsf_lum_b1);
S = S_lum .* S_TCSF.* Area_factor;
end

function S = TCSF(t_frequency, luminance, tcsf_lum_k1, tcsf_lum_b1)
TCSF_n1 = 15;
TCSF_n2 = 16;
TCSF_xi = 154.133;
TCSF_tau = 0.00292069;
TCSF_kappa = 2.12547;
TCSF_zeta = 0.721095;

lum_peak_f = 0;
t_frequency = (t_frequency - lum_peak_f) ./ (tcsf_lum_b1+tcsf_lum_k1 * log10(luminance)) + lum_peak_f;
S = abs(TCSF_xi * ((1 + 2 * 1i * pi * t_frequency * TCSF_tau).^(-TCSF_n1) - TCSF_zeta * (1 + 2 * 1i * pi * t_frequency * TCSF_kappa * TCSF_tau).^(-TCSF_n2)));
end