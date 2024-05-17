function S = S_TCSF_1(params, omega)
% [TCSF_xi, TCSF_tau, TCSF_kappa, TCSF_zeta, TCSF_n1, TCSF_n2] = deal(params);
TCSF_xi = params(1);
TCSF_tau = params(2);
TCSF_kappa = params(3);
TCSF_zeta = params(4);
TCSF_n1 = params(5);
TCSF_n2 = params(6);
% TCSF_xi, TCSF_tau, TCSF_kappa, TCSF_zeta, TCSF_n1, TCSF_n2 = [148.7, 0.00267, 1.834, 0.882, 15, 16];
S = abs(TCSF_xi .* ((1 + 2 .* 1i .* pi .* omega .* TCSF_tau).^(-TCSF_n1) - TCSF_zeta .* (1 + 2 .* 1i .* pi .* omega .* TCSF_kappa .* TCSF_tau).^(-TCSF_n2)));
end