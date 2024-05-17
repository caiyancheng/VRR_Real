function S = S_TCSF_2(params, omega)
% [tcsf_omega_0, tcsf_beta, tcsf_sigma] =  deal(params);
tcsf_omega_0 = params(1);
tcsf_beta = params(2);
tcsf_sigma = params(3);
% tcsf_omega_0, tcsf_beta, tcsf_sigma =  [4, 0.1898, 0.12314];
S = exp(-((omega).^tcsf_beta-tcsf_omega_0.^tcsf_beta).^2./tcsf_sigma) .* 170;
end