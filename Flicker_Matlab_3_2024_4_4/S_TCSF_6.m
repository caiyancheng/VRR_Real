function S = S_TCSF_6(params, omega)
% Weibull distribution
% [5, 1, 1];
k1 = params(1);
k2 = params(2);
k3 = params(3);
k4 = params(4);
k5 = params(5);
S = exp(k1 .* ((1+k2./omega) .^ (-k3)) .* (1-(1+k4./omega).^ (-k5)));
end