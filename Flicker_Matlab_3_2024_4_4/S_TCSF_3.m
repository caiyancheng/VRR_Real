function S = S_TCSF_3(params, omega)
% [tcsf_omega_0, tcsf_beta, tcsf_sigma] =  deal(params);
% beta_sust = 1.3314;
% sigma_sust = 12.2643;
% beta_trans = 0.1898;
% sigma_trans = 0.12314;
% omega_0 = 4;
% [1.3314, 12.2643, 0.1898, 0.12314, 4]
beta_sust = params(1);
sigma_sust = params(2);
beta_trans = params(3);
sigma_trans = params(4);
omega_0 = params(5);
R_sust = exp( -omega.^beta_sust ./ sigma_sust);
R_trans = exp( -(omega.^beta_trans-omega_0.^beta_trans).^2 ./ sigma_trans);
S = R_trans.* 170 + R_sust.* 70;
end