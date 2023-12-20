function P = pf_inc_exp( intensity, mu, beta, target_p )
% Exponential psychometric function, increases with intensity

P = 1 - exp( log(1-target_p) * (intensity/mu).^beta );

end
