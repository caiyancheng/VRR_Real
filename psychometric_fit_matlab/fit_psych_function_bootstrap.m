D = dataset( 'file', 'vid_results.csv', 'delimiter', ',' );

D.response = strcmp( D.picked, 'reference' );

D.bd1(D.bd1==9) = 8;
D.bd2(D.bd2==9) = 8;
D.bd2(D.bd2==9) = 8;

% Group conditions together so that we can iterate them
% Note that we group responses from all observers - this could or could not
% be a good idea
Dcond = grpstats( D, { 'observer', 'vid_name', 'ct_name', 'controlled_mask' }, @numel, 'DataVar', 'response' );

fh = fopen( 'vid_thresholds.csv', 'w' );

fprintf( fh, 'observer, vid_name, ct_name, controlled_mask, threshold, threshold_std\n' );

debug = false;

for kk=1:length(Dcond)
    
    ss = strcmp( D.observer, Dcond.observer{kk} ) & strcmp( D.vid_name, Dcond.vid_name{kk} ) & strcmp( D.ct_name, Dcond.ct_name{kk} ) & D.controlled_mask == Dcond.controlled_mask(kk);
    Ds = D(ss,:);
    
    % select the column for which bit-depth varied
    for cc=1:3
        if bitand( Dcond.controlled_mask(kk), 2^(cc-1) )
            bd_column = sprintf( 'bd%d', cc );
            break;
        end
    end

    fprintf( 1, 'Processing %d out of %d (%s/%s/%s/%d)\n', kk, length(Dcond), Dcond.observer{kk}, Dcond.vid_name{kk}, Dcond.ct_name{kk}, Dcond.controlled_mask(kk) );

    if( length(Ds) <= 5 )
        warning( 'Too few responses to fit a psychometric function' );
        continue;
    end
    
    beta = 10;
    [mu, mu_std] = bootstrp_threshold( Ds.(bd_column), Ds.response );
    thr = mu;
            
    condition_descr = sprintf( '(%s/%s/%s/%d) = %g\n', Dcond.observer{kk}, Dcond.vid_name{kk}, Dcond.ct_name{kk}, Dcond.controlled_mask(kk), mu );
        
    
    if( thr <= 3 || thr > 8 ) % reject measurement
        warning( 'Could not fit plausible psychometric function for: %s', condition_descr );
    else
        fprintf( fh, '%s, %s, %s, %d, %g, %g\n', Dcond.observer{kk}, Dcond.vid_name{kk}, Dcond.ct_name{kk}, Dcond.controlled_mask(kk), mu, mu_std );
    end
    
    if( debug )
        % Get the number of correct & total answers for each bit-depth
        Dg = grpstats( Ds, bd_column, { @mean, @sum }, 'DataVar', 'response' );
        
        clf;
        bd = linspace( 2, 8 );
        scatter( Dg.(bd_column), Dg.mean_response );
        
        for tt=1:length(Dg)
            text( Dg.(bd_column)(tt), 0.25, sprintf( '%d', Dg.GroupCount(tt) ) );
        end
        
        hold on
        plot( bd, psych_func( bd, thr, beta ) );
        
        plot( [thr thr], [0 1], '--k' );
        text( thr, 0.1, sprintf( 'std=%g', mu_std ) );
        hold off
        
        ylim( [0 1] );
        xlabel( 'Bit-depth' );
        ylabel( 'Probability of detection' );
        title( condition_descr );
        waitforbuttonpress;
    end
    
end

fclose( fh );




