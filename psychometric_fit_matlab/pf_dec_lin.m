function P = pf_dec_lin( intensity, mu, beta, target_p )
% Exponential psychometric function, increases with intensity

P = exp( log(1-target_p) * (10.^(intensity-mu)).^beta );

end
