%%

clear all
all_vars = {'observer', 'age', 'session_id', 'luminance', 'frequency', 'color_direction', 'size_ge', 'log_dkl_contrast', 'log_dkl_contrast_ci_low', 'log_dkl_contrast_ci_high', 'log_cone_contrast', 'log_cone_contrast_ci_low', 'log_cone_contrast_ci_high'  };


%% Cambridge color_csf

ds = dataset('File','../experiments/experiment_csf/color_csf_quest_trials-cambridge.csv','Delimiter',',');
ds = remove_odd_measurement( ds );

recompute_all = false;
if ~recompute_all
    
    dres = dataset('File','color_csf_cambridge.csv','Delimiter',',');
    computed_sessions = unique( dres.session_id );
    ds = ds(~ismember(ds.session_id,computed_sessions),:);
    
end

if ~isempty(ds)
    % To avoid crashing on Linux
    set(0, 'defaultFigureRenderer', 'painters')

    %ds = ds( ds.param_size_ge == -0.5 & ~strcmp( ds.observer, 'rafal'), : );

    %ds = ds( strcmp( ds.observer, 'rafal'), : );

    %ds = ds( strcmp( ds.observer, 'keith') & ds.luminance==20 & ds.frequency == 4, : );

    % observer=Wilson/luminance=200/frequency=6/color_direction=3) 
    %ds = ds( strcmp( ds.observer, 'Cheryn') & ds.luminance==1000 & ds.frequency == 6 & ds.color_direction==3, : );

    options = { 'psych_func', @pf_inc_lin, ...
        'intensity_label', 'log10 DKL contrast', 'intensity_scale', 'linear', 'bootstrap_samples', 0, 'target_p', 0.84, ...
        'alpha', 0.1 };

    %options = { 'psych_func', @pf_inc_lin, 'report_file', 'color_csf_fits/index.html', ...
    %    'intensity_label', 'log10 DKL contrast', 'intensity_scale', 'linear', 'bootstrap_samples', 0, 'target_p', 0.84, ...
    %    'alpha', 0.1 };

    %do_cone_contrast = true;

    ds.log_dkl_contrast = log10( ds.contrast );

    D_thr = fit_psych_func( ds, { 'observer', 'age', 'session_id', 'luminance', 'frequency', 'color_direction', 'size_ge'}, 'log_dkl_contrast', 'response', 3.5, 0.25, options );

    D_thr.log_cone_contrast = log10( dkl2cone_contrast( 10.^D_thr.threshold, D_thr.luminance, D_thr.color_direction ) );
    D_thr.log_cone_contrast_ci_low = log10( dkl2cone_contrast( 10.^D_thr.threshold_ci_low, D_thr.luminance, D_thr.color_direction ) );
    D_thr.log_cone_contrast_ci_high = log10( dkl2cone_contrast( 10.^D_thr.threshold_ci_high, D_thr.luminance, D_thr.color_direction ) );

    D_thr.log_dkl_contrast = D_thr.threshold;
    D_thr.log_dkl_contrast_ci_low = D_thr.threshold_ci_low;
    D_thr.log_dkl_contrast_ci_high = D_thr.threshold_ci_high;

   
    D_clean_cam = D_thr(:, all_vars );

end

if ~recompute_all
    if ~exist('D_clean_cam', 'var')
       D_clean_cam = []; 
    end
    D_clean_cam = vertcat( dres(:,all_vars), D_clean_cam );
end
D_clean_cam.Properties.ObsNames = [];
export( D_clean_cam, 'file', 'color_csf_cambridge.csv', 'delimiter', ',' );
%
%clf;

%D_thr.S = 1./D_thr.threshold;

%exp_plot_color_lines( D_thr, 'frequency', 'S', 'luminance' );

%set( gca, 'YScale', 'log' );

%% Liverpool color_csf

ds = dataset('File','../experiments/experiment_csf/color_csf_quest_trials-liverpool.csv','Delimiter',',');
ds = remove_odd_measurement( ds );

recompute_all = false;
if ~recompute_all
    
    dres = dataset('File','color_csf_liverpool.csv','Delimiter',',');
    computed_sessions = unique( dres.session_id );
    ds = ds(~ismember(ds.session_id,computed_sessions),:);
    
end

if ~isempty(ds)
    % To avoid crashing on Linux
    set(0, 'defaultFigureRenderer', 'painters')

    %ds = ds( ds.param_size_ge == -0.5 & ~strcmp( ds.observer, 'rafal'), : );

    %ds = ds( strcmp( ds.observer, 'rafal'), : );

    %ds = ds( strcmp( ds.observer, 'keith') & ds.luminance==20 & ds.frequency == 4, : );

    % observer=Wilson/luminance=200/frequency=6/color_direction=3) 
    %ds = ds( strcmp( ds.observer, 'Cheryn') & ds.luminance==1000 & ds.frequency == 6 & ds.color_direction==3, : );

    options = { 'psych_func', @pf_inc_lin, ...
        'intensity_label', 'log10 DKL contrast', 'intensity_scale', 'linear', 'bootstrap_samples', 0, 'target_p', 0.84, ...
        'alpha', 0.1 };

    %options = { 'psych_func', @pf_inc_lin, 'report_file', 'color_csf_fits/index.html', ...
    %    'intensity_label', 'log10 DKL contrast', 'intensity_scale', 'linear', 'bootstrap_samples', 0, 'target_p', 0.84, ...
    %    'alpha', 0.1 };

    %do_cone_contrast = true;

    ds.log_dkl_contrast = log10( ds.contrast );

    D_thr = fit_psych_func( ds, { 'observer', 'age', 'session_id', 'luminance', 'frequency', 'color_direction', 'size_ge'}, 'log_dkl_contrast', 'response', 3.5, 0.25, options );

    D_thr.log_cone_contrast = log10( dkl2cone_contrast( 10.^D_thr.threshold, D_thr.luminance, D_thr.color_direction ) );
    D_thr.log_cone_contrast_ci_low = log10( dkl2cone_contrast( 10.^D_thr.threshold_ci_low, D_thr.luminance, D_thr.color_direction ) );
    D_thr.log_cone_contrast_ci_high = log10( dkl2cone_contrast( 10.^D_thr.threshold_ci_high, D_thr.luminance, D_thr.color_direction ) );

    D_thr.log_dkl_contrast = D_thr.threshold;
    D_thr.log_dkl_contrast_ci_low = D_thr.threshold_ci_low;
    D_thr.log_dkl_contrast_ci_high = D_thr.threshold_ci_high;

    D_clean_liv = D_thr(:, all_vars );
end

if ~recompute_all
    if ~exist('D_clean_liv', 'var')
       D_clean_liv = []; 
    end
    D_clean_liv = vertcat( dres(:,all_vars), D_clean_liv );
end
D_clean_liv.Properties.ObsNames = [];
export( D_clean_liv, 'file', 'color_csf_liverpool.csv', 'delimiter', ',' );

%% Concatenated color_csf

D_clean = vertcat( D_clean_cam, D_clean_liv );
export( D_clean, 'file', 'color_csf.csv', 'delimiter', ',' );

