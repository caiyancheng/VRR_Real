function P = pf_dec_exp( intensity, mu, beta, target_p )
% Exponential psychometric function, decreases with intensity

P = exp( log(1-target_p) * (intensity/mu).^beta );

end
