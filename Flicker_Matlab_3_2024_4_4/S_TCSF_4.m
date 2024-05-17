function S = S_TCSF_4(params, omega)
% Weibull distribution
% [5, 1, 1];
k = params(1);
lamda = params(2);
b = params(3);
m = params(4);
S = m .* exp((k ./ lamda) .* (omega ./ lamda).^(k-1) .* exp((-omega ./ lamda).^k)-b) ;
end