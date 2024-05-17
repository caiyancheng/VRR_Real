function S = S_TCSF_5(params, omega)
k_1 = params(1);
k_2 = params(2);
peak_f = params(3);
beta = params(4);
f_0 = params(5);
m = params(6);

b_1 = - k_1 * peak_f;
b_2 = k_1 * peak_f + k_2 * (peak_f / f_0) ^ beta + b_1;
S = zeros(length(omega), 1);
ind_before_peak = omega < peak_f;
S(ind_before_peak) = m.*exp(k_1 .* omega(ind_before_peak) + b_1);
S(~ind_before_peak) = m.*exp(- k_2 .* (omega(~ind_before_peak)./f_0).^beta + b_2);
end