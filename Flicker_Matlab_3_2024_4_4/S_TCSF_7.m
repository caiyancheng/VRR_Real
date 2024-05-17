function S = S_TCSF_7(params, omega) %左右两个带偏置的高斯函数拼接[6, 5.5, 8, 0.005, 10, 10]
k_1 = params(1);
k_2 = params(2);
peak_f = params(3);
b_2 = params(4);
b_1 = k_2 - k_1 - b_2;
sigma_1 = params(5);
sigma_2 = params(6);

S = zeros(length(omega), 1);
ind_before_peak = omega < peak_f;
S(ind_before_peak) = exp(k_1.*exp(-((omega(ind_before_peak)-peak_f).^2)./(2.*sigma_1.^2)) + b_1);
S(~ind_before_peak) = exp(k_2.*exp(-((omega(~ind_before_peak)-peak_f).^2)./(2.*sigma_2.^2)) - b_2);
end