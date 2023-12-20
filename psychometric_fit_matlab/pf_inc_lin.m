function P = pf_inc_lin( intensity, mu, beta, target_p )
% Exponential psychometric function, increases with intensity

P = 1 - exp( log(1-target_p) * (10.^(intensity-mu)).^beta );

end
