clear all;
clc;
omega = logspace(log10(0.5),log10(64),100)';

S_1 = S_TCSF_1(omega);

plot(omega, S_1, '-', 'LineWidth', 2);
xlabel('Temporal Frequency (Hz)','FontSize',14);
ylabel('Sensitivity = 1 / Contrast (threshold)','FontSize',14);
set(gca, 'YScale', 'log');
set(gca, 'XScale', 'log');
ylim([0.1,1000]);
xlim([0.5, 64]);
set(gca, 'YTick', [1, 10, 100, 1000], 'YTickLabel', {'1', '10', '100', '1000'});
set(gca, 'XTick', [0.5, 1, 2, 4, 8, 16, 32, 64], 'XTickLabel', {'0.5', '1', '2', '4', '8', '16', '32', '64'});


function S = S_TCSF_1(omega)
% [TCSF_xi, TCSF_tau, TCSF_kappa, TCSF_zeta, TCSF_n1, TCSF_n2] = deal(params);
params = [148.7, 0.00267, 1.834, 0.882, 15, 16];
TCSF_xi = params(1);
TCSF_tau = params(2);
TCSF_kappa = params(3);
TCSF_zeta = params(4);
TCSF_n1 = params(5);
TCSF_n2 = params(6);
% TCSF_xi, TCSF_tau, TCSF_kappa, TCSF_zeta, TCSF_n1, TCSF_n2 = [148.7, 0.00267, 1.834, 0.882, 15, 16];
S = abs(TCSF_xi .* ((1 + 2 .* 1i .* pi .* omega .* TCSF_tau).^(-TCSF_n1) - TCSF_zeta .* (1 + 2 .* 1i .* pi .* omega .* TCSF_kappa .* TCSF_tau).^(-TCSF_n2)));
end