function l = fitpf_loglikelihood( mu, psych_func, beta, intensity, N, k, mistake_p, prior )

P = psych_func( intensity, mu, beta );

% compute the probability of a mistake for each bin
mistake_p_k = 1 - (1-mistake_p).^N;

Lk = mistake_p_k + (1-mistake_p_k).*binopdf( k, N, P );

l = -sum( log(Lk+1e-50) );

if ~isempty( prior )
    l = l + (prior(1)-mu).^2/(2*prior(2)^2);
end

end

