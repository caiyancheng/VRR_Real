function D_thr = fit_psych_func( D, group_cols, intensity_col, response_col, beta, guess_p, options )
% Fitting of the psychometric function to the dataset of N-alternative
% responses
%
% D_thr = fit_psych_func( D, group_cols, intensity_col, response_col, beta, guess_p, options )
%
% The function estimates the thresholds and confidence intervals using
% the Wilks theorem on the ratio of likelihood functions.
%
% D - dataset with the individual force-choice responses
% group_col - a cell array with the names of columns used to group
%             responses into a single measured condition, usually per observer
% intensity_col - the name of the column containing the values for which
%             the threshold is measured (contrast, intensity, etc.)
% response_col - the name of the column comntaining observer responses. Teh
%             value must be 1 for correct answer and 0 for incorrect answer.
% beta - the slope of the psychophysical function
% guess_p - the probability of guessing correct answer, for example 0.5 for
%           2AFC, or 0.25 for 4AFC
% options - a cell array with the { name, value } pairs. Recognized
%           options:
%   'target_p' - find the threshold for the probability of detection equal
%           to target_p. Default: 0.75. Use 0.84 for 4AFC. 
%   'mist_p' - the probability of observer making a mistake (default is
%           0.02 -one mistake in 50 trails);
%   'psych_func' - the handle of the psychometric function. See description
%           below. Default is @pf_inc_exp;
%   'alpha' - the confidence level for estimation of confidence intervals.
%           Default 0.05
%   'debug' - after each fit show the plot of the psychometric function fit
%           and pause.
%   'bootstrap_samples' - how many samples generate to compute standard
%           error (standard deviation of the mean) of the thresholds with
%           bootstapping. Set to 0 to disable
%           bootstrapping. Use at least 100 samples. Default: 0
%   'report_file' - full path (with the directory) to the file with an HTML
%           report containing plots for all the fits. Default is '', which
%           disables the report.
%   'report_row' - the name of the column from "group_col" to use for
%           putting plots in separate rows. Default is the first column
%           name from group_col.
%   'intensity_label' - label to put on the x-axis in the plots genetated
%           when report_file is specified or debug==true
%   'intensity_range' - the range of the intensity values to plot given as
%           a [min_intesity max_intensity].
%   'intensity_scale' - either 'linear' or 'log'
%   'display' - either 'iter' to show progress for each stimulus (default)
%           or 'none' to display no progress
%   'prior' - a vector [mu sigma] with the Gaussian prior. Prior can
%           improve fitting if initial estimate is available (for example 
%           from the method-of-adjustment). Default: [] - no prior. 
%
% Psychometric function handle:
%
% The fuction handle passed as { 'psych_func', @my_psych_func } should
% point to the function that is invoked as follows:
%
% P = my_psych_func( intensity, mu, beta, target_p )
%
% "intensity" could be a vector, in which case P should also be a vector.
% The function should be equal to 0.5 when intensity=mu
% "beta" is the slope of the psychometric function (typically 3.5).
% target_p is the probability value for which the threshold should be
% estimated, typically between 0.75 and 0.84. 
%
% Interpretation of the plots
%
% When you specify a report file name, each set of trials is visualized with two plots
%
% 1. Psychometric function & likelihood plot
% - red continous line is the fitted psychometric function
% - blue circles represent measurements. Those are groupped by 'intensity'
%   so that an average probability of detection per intensity is shown
% - the black numbers in the format k/N at the y=0.25 deote that there were
%   N collected responses at the intensity, from which k of them were correct
%   If no numbers are shown, there was only one measurement. 
% - the black dashed line represents the threshold
% - the yellow histogram bars represent the distribution of the bootstrap
%   samples for estimating the confidence interval on the threshold
% - the black continous line represents the normal distribution fitted to
%   the bootstrap samples (distribution of the estimated threshold)
% - continous magenta line is the likelihood function for the threshold
%   parameter
%
% 2. Staircase plot 
% - the black dashed line represents the threshold
% - green circles - correct answers 
% - red crosses - incorrect answers

if ~exist( 'options', 'var' )
    options = {};
end

opt.mistake_p = 0.02; % one in 50 answers is a mistake
opt.debug = false;
opt.psych_func = @pf_inc_exp;
opt.bootstrap_samples = 0;
opt.report_file = '';
opt.report_row = group_cols{1};
opt.intensity_label = 'intensity';
opt.intensity_range = [];
opt.intensity_scale = 'linear';
opt.plot_staircase = true;
opt.display = 'iter';
opt.prior = [];
opt.target_p = 0.75;
opt.alpha = 0.05;  % confidence level for estimating confidence intervals
for kk=1:2:length(options)
    if ~isfield( opt, options{kk} )
        error( 'Unrecognized option "%s"', options{kk} );
    end
    opt.(options{kk}) = options{kk+1};
end

if isempty( opt.intensity_range )
    opt.intensity_range = [min(D.(intensity_col)) max(D.(intensity_col))];    
    if strcmp( opt.intensity_scale, 'linear' )
        marg = (opt.intensity_range(2)-opt.intensity_range(1))*0.2;
        opt.intensity_range = opt.intensity_range + [-marg marg];
    else
        opt.intensity_range = max( opt.intensity_range .* [0.8 1.2], 1e-5 );
    end
end

%if strcmp( opt.intensity_scale, 'log' )
%    opt.intensity_range(1) = max( opt.intensity_range(1), 1e-4 );
%end

if opt.target_p <= guess_p
    error( 'target_p must be greater than guess_p' );
end

target_p_adjusted = (opt.target_p-guess_p)/(1-guess_p);
% Adjust the psychophysical function by the guess rate
adjusted_psych_func = @(intensity,mu,beta) (guess_p + (1-guess_p)*opt.psych_func(intensity,mu,beta,target_p_adjusted));


% Group conditions together so that we can iterate them
Dcond = grpstats( D, group_cols, @numel, 'DataVar', response_col );
Dcond = sortrows( Dcond, opt.report_row );

N_cond = height(Dcond); % 一种多少组setting
N_d = height(D); %数据总量
Dthr = zeros(N_cond,1);
Dthr_ci = zeros(N_cond,2);
Dthr_se = zeros(N_cond,1);

if ~isempty(opt.report_file)
    hth = html_open( opt.report_file, 'Estimated threshold' , [], [] );
    html_table_beg( hth );
end

new_row = true;

fig_name_id = 1;

% For each condition
for kk=1:N_cond
    
    % Select all responses for the given condition
    ss = true(N_d,1);
    label = '';
    for cc=1:length(group_cols)
        if ~isempty(label)
            label = strcat( label, '/' );
        end
        label = strcat( label, group_cols{cc}, '=' );
        if isnumeric( Dcond.(group_cols{cc})(kk) )
            ss = ss & ( D.(group_cols{cc}) == Dcond.(group_cols{cc})(kk) );
            label = strcat( label, num2str( Dcond.(group_cols{cc})(kk) ) );
        else
            ss = ss & strcmp( D.(group_cols{cc}), Dcond.(group_cols{cc}){kk} );
            label = strcat( label, Dcond.(group_cols{cc}){kk} );
        end
    end
    Ds = D(ss,:);
    
    if strcmp( opt.display, 'iter' )
        fprintf( 1, 'Processing %s - %s\n', progress_str_etl( kk, N_cond ), label );
    end
    skip_plot = false;
    
    [mu, mu_samples, mu_ci, skip_measurement, skip_plot] = fitpf_find_threshold( Ds.(intensity_col), Ds.(response_col), ...
        adjusted_psych_func, beta, opt.mistake_p, opt.prior, opt.alpha, opt.bootstrap_samples, opt.intensity_scale );

    if strcmp( opt.intensity_scale, 'log' )
        mu_se = exp( log(mu)+std(log(mu_samples)) ) - mu; %estimate in linear domain
    else
        mu_se = std(mu_samples);
    end
    thr = mu;
    Dthr(kk) = mu;
    Dthr_se(kk) = mu_se;
    Dthr_ci(kk,:) = mu_ci;
    
    condition_descr = sprintf( '(%s) = %g\n', label, mu );
    
    if skip_measurement
        Dthr(kk) = nan;
        Dthr_se(kk) = nan;
        Dthr_ci(kk,:) = [nan nan];
    end
    
    
    if( opt.debug || ~isempty(opt.report_file) )
        
        if skip_plot
            html_table_cell_beg( hth );
            fprintf( hth.fh, 'Too few datapoints to fit.\n' );
            html_table_cell_beg( hth );
        else
            
            if strcmp( opt.intensity_scale, 'log' )
                intens_cont = logspace( log10(opt.intensity_range(1)), log10(opt.intensity_range(2)) );
                intens_bins = logspace( log10(opt.intensity_range(1)), log10(opt.intensity_range(2)), 20 );
            else
                intens_cont = linspace( opt.intensity_range(1), opt.intensity_range(2) );
                intens_bins = linspace( opt.intensity_range(1), opt.intensity_range(2), 20 );
            end
            
            [gn, k, N] = grpstats( Ds.(response_col), Ds.(intensity_col), { 'gname', @sum, @numel } );
            int_val = zeros(length(k),1);
            for ll=1:length(gn)
                int_val(ll) = str2double( gn{ll} );
            end
            
            lhood = zeros( length(intens_cont), 1 );
            for ll=1:length(intens_cont)
                lhood(ll) = fitpf_loglikelihood( intens_cont(ll), adjusted_psych_func, beta, int_val, N, k, opt.mistake_p, opt.prior );
            end
            
            
            % Get the number of correct & total answers for each bit-depth
            Dg = grpstats( Ds, intensity_col, { @mean, @sum }, 'DataVar', response_col );
            
            clf;
            intens_hist = hist( mu_samples, intens_bins );
            intens_hist = intens_hist/sum(intens_hist);
            
            bar_width = 1;
            if strcmp( opt.intensity_scale, 'log' )
                bar_width = 100; %a hack: otherwise bars are invisible
            end
            bar( intens_bins, intens_hist, bar_width, 'FaceColor', [1 1 0.8] );
            hold on;
            
            % Plot likelihood function
            max_lhood = max( exp(-lhood) );
            plot( intens_cont, exp(-lhood) / max_lhood*0.9, '-m' );
            
            % Plot confidence intervals
%            alpha = 0.05;
%            hchi2 = 0.5*chi2inv( 1-opt.alpha, 1 );
%            phood = -lhood;
%            cint = ((max(phood) - phood)<=hchi2);
%            low_ci = find(cint,1);
%            high_ci = find(cint,1,'last');
%            if low_ci == 1
%                low_ci = [];
%            end
%            if high_ci == length(cint)
%                high_ci = [];
%            end
              
%            plot( [1 1]*intens_cont(low_ci), [0 1], '--r' );
%            plot( [1 1]*intens_cont(high_ci), [0 1], '--r' );

            plot( [1 1]*mu_ci(1), [0 1], ':k' );
            plot( [1 1]*mu_ci(2), [0 1], ':k' );
            
            mean_response_col = strcat( 'mean_', response_col );
            sum_response_col = strcat( 'sum_', response_col );
            scatter( Dg.(intensity_col), Dg.(mean_response_col) );
            
            for tt=1:length(Dg)
                if Dg.GroupCount(tt)>1
                    p = Dg.(sum_response_col)(tt)/Dg.GroupCount(tt);
                    text( Dg.(intensity_col)(tt), p, sprintf( '%d/%d', Dg.(sum_response_col)(tt), Dg.GroupCount(tt) ), 'FontSize', 8 );
                end
            end
            
            hold on
            plot( intens_cont, adjusted_psych_func( intens_cont, thr, beta ) );
            
            plot( [thr thr], [0 1], '--k' );
            
            % Plot the distribution of the threshold function
            thr_distr = 1/sqrt(2*pi*mu_se^2) * exp( -(intens_cont-mu).^2/(2*mu_se^2) );
            plot( intens_cont, thr_distr, '-k' );
            if ~isnan( mu_se )
                text( thr, 0.1, sprintf( 'std=%g', mu_se ) );
            end
            
            hold off
            
            ylim( [0 1] );
            xlim( opt.intensity_range );
            xlabel( opt.intensity_label );
            set( gca, 'XScale', opt.intensity_scale );
            ylabel( 'Probability of detection' );
            
            if ~isempty(opt.report_file)
                
                if kk>1 && ~isequal( Dcond.(opt.report_row)(kk), Dcond.(opt.report_row)(kk-1) )
                    html_table_row_end( hth );
                    new_row = true;
                end
                
                if new_row
                    html_table_row_beg( hth );
                end
                %fig_name = replace( label, {'/','='}, '_' );
                fig_name = sprintf( 'fit_%05d', fig_name_id );
                html_table_cell_beg( hth );
                html_insert_figure( hth, gcf, fig_name, 120, 15, 10 );
                
                if opt.plot_staircase
                    clf;
                    stairs( [Ds.(intensity_col);Ds.(intensity_col)(end)] );
                    hold on
                    rr = 2:(length(Ds)+1);
                    ss = (Ds.(response_col)==1);
                    plot( rr(ss), Ds.(intensity_col)(ss), 'og' );
                    plot( rr(~ss), Ds.(intensity_col)(~ss), 'xr' );
                    plot( [1 length(Ds)+1], [thr thr], '--k' );
                    hold off
                    xlabel( 'trial' );
                    ylabel( opt.intensity_label );
                    set( gca, 'YScale', opt.intensity_scale );
                    %fig_name = strcat( replace( label, {'/','='}, '_' ), '_stairs' );
                    fig_name = sprintf( 'fit_%05d_stairs', fig_name_id );                    
                    html_insert_figure( hth, gcf, fig_name, 120, 10, 10 );                 
                end
                fig_name_id = fig_name_id + 1;

                fprintf( hth.fh, '<br/>\n%s\n', condition_descr );
                if skip_measurement
                    fprintf( hth.fh, '<br/>\n<b>Skipped measurement</b>\n' );
                end
                html_table_cell_beg( hth );
                
                new_row = false;
            end
            
            
            if opt.debug
                title( condition_descr );
                waitforbuttonpress;
            end
        end
    end
    
end

if ~isempty(opt.report_file)
    html_table_end( hth );
    html_close( hth );
end


%D_thr = horzcat( Dcond, dataset( { Dthr, 'threshold' }, { Dthr_ci(:,1), 'threshold_ci_low' }, { Dthr_ci(:,2), 'threshold_ci_high' }, { Dthr_se, 'threshold_se' } ) );
D_thr = Dcond;
D_thr.threshold = Dthr; %阈值
D_thr.threshold_ci_low = Dthr_ci(:,1); %标准误差低
D_thr.threshold_ci_high = Dthr_ci(:,2); %标准误差高
D_thr.threshold_se = Dthr_se; %置信区间


end

function same = fitpf_issame( a, b )

if isnumeric( a )
    same = (a==b);
elseif ischar( a )
    same = strcmp( a, b );
else
    error( 'Unsupported column type' );
end

end