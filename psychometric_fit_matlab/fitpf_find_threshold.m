function [mu, mu_samples, mu_ci, skip_measurement, skip_plot] = fitpf_find_threshold( intensity, response, psych_func, beta, mistake_p, prior, alpha, bootstrap_samples, intensity_scale )

skip_measurement = false;
skip_plot = false;

if( length(response) <= 5 )
    warning( 'Too few responses to fit a psychometric function' );
    skip_measurement = true;
    skip_plot = true;
    mu = nan;
    mu_samples = [];
    mu_ci = [nan nan];
    return;
end

% sample likelihood for the analysis and good starting point
[k, N, int_val] = group_responses( response, intensity );
int_min = min(intensity);
int_max = max(intensity);
if strcmp( intensity_scale, 'log' )
    intens_cont = logspace( log10(int_min*0.5), log10(int_max*1.5) );
else
    rng = int_max-int_min;
    intens_cont = linspace( int_min-rng*0.5, int_max+rng*0.5 );
end
lhood = zeros( length(intens_cont), 1 );
for ll=1:length(intens_cont)
    lhood(ll) = -fitpf_loglikelihood( intens_cont(ll), psych_func, beta, int_val, N, k, mistake_p, prior );
end
max_lhood = max(lhood);
if( nnz(abs(max_lhood-lhood)<1e-6)>1 || ...  % platou
        lhood(end)>=max_lhood || lhood(1)>=max_lhood ... %max at the beg or end of the range
        )
    warning( 'Cannot fit psych function: non-convex likelihood function or platou. Skipping the measurement' );
    skip_measurement = true;
end
start_intensity = intens_cont(find(lhood==max_lhood,1));

hchi2 = 0.5*chi2inv( 1-alpha, 1 );

mu = bs_func( intensity, response );

ci_rng = ((max_lhood-lhood)<hchi2);
ind_low = find(ci_rng,1, 'first' );
ind_high = find(ci_rng,1, 'last' );

mu_ci_est = intens_cont( [ind_low ind_high] );
mu_ci = [find_confidence_intervals( mu_ci_est(1), mu, k, N, int_val ) ...
         find_confidence_intervals( mu_ci_est(2), mu, k, N, int_val ) ];

% In case no confidence interval is found, set the value to nan
if mu_ci(1)>mu
    mu_ci(1) = nan;
end
if mu_ci(2)<mu
    mu_ci(2) = nan;
end

if( bootstrap_samples > 0 )
    options = statset( 'UseParallel', true );
    mu_samples = bootstrp( bootstrap_samples, @bs_func, intensity, response, 'Options', options );
else
    mu_samples = [];
end

    function mu_ci = find_confidence_intervals( start_ci, mu, k, N, int_val )
        
        max_loglikelihood = -fitpf_loglikelihood( mu, psych_func, beta, int_val, N, k, mistake_p, [] );        
        lratio = @(intensity) ( max_loglikelihood + fitpf_loglikelihood( intensity, psych_func, beta, int_val, N, k, mistake_p, [] ) - hchi2 );

        mu_ci  = fzero(lratio, start_ci);
        
    end


    function mu = bs_func( intensity, response )
        
        if( 0 )
            n2 = floor(length( intensity )/2);
            intensity = intensity(n2:end);
            response = response(n2:end);
        end
        
        [k, N, int_val] = group_responses( response, intensity ); 
        
        loss = @(pars) ( fitpf_loglikelihood( pars(1), psych_func, beta, int_val, N, k, mistake_p, prior ) );
        
        options = optimset( 'display', 'off' );
        
        % The optimization may fail to converge if beta is high and starting
        % point is far from the minimum
        % If stair-case procedure was used, weighted mean should a good
        % starting point
        %mu_0 = sum( int_val .* N ) / sum(N);  % starting point
        
        mu_0 = start_intensity;
        
        mu = fminunc( loss, mu_0, options );
        
        
        if( 0 ) % For debugging purposes only
            clf
            subplot( 2, 1, 1 );
            ll = linspace( 7, 12 );
            lf = zeros(size(ll));
            for kk=1:length(ll)
                lf(kk) = loss(ll(kk));
            end
            h = 20;
            plot( ll, lf );
            hold on
            plot( int_val, (k./N)*h, 'o' );
            plot( [mu mu], [0 h], '--k' );
            xlabel( 'Intensity' );
            hold off
            
            subplot( 2, 1, 2 );
            stairs( intensity );
            hold on
            plot( response*max(intensity), 'or' );
            hold off
            xlabel( 'Trial #' );
            
            1;
        end
        
    end

end

function [k, N, int_val] = group_responses( response, intensity )

[gn, k, N] = grpstats( response, intensity, { 'gname', @sum, @numel } );

int_val = zeros(length(k),1);
for kk=1:length(gn)
    int_val(kk) = str2double( gn{kk} );
end

end


