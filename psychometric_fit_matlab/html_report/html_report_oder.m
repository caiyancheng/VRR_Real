D_ss = dataset_load('rating_single_stim.txt');
D_ds = dataset_load('rating_double_stim.txt');
D_pc = dataset_load('forced_choice.txt');
D_sj = dataset_load('similarity_judgements.txt');

load_single_stim_dataset;
D_ss2 = D;
load_double_stim_dataset;
D_ds2 = D;
load_forced_choice_dataset;
D_pc2 = D;
load_similarity_dataset;
D_sj2 = D;

IMGs = unique( D_ss.image );
IMGsMain = {'bikes','sailing2','parrots','womanhat'};
ss_nomain = zeros(length(IMGs),1);
for i=1:length(IMGsMain)
    ss = strcmp(IMGs, IMGsMain{i});
    ss_nomain = ss_nomain+ss;
end

IMGsNoMain = IMGs(~ss_nomain);
ALGRs = unique(D_ss.par_lab);

hth = html_open( 'report/html_subpages/quality_order_cmp.html', 'QualityCmp' );
html_table_beg(hth);
html_table_row_beg( hth )
fprintf( hth.fh, '<TH colspan="7" align="left">'); 
fprintf( hth.fh, '<HR/>\n' );
fprintf( hth.fh, '<b> Quality order comparison </b>');
fprintf( hth.fh, '<HR/>\n' );
fprintf( hth.fh, '</TH'); 
html_table_row_end(hth);

html_table_row_beg(hth);
fprintf( hth.fh, '<TH colspan="7" align="left">'); 
fprintf( hth.fh, '<B> selected representative images </B>');
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '</TH'); 
html_table_row_end(hth);

for k=1:length(IMGsMain)
    html_table_row_beg(hth);
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, sprintf('<B> scene: %s </B>',IMGsMain{k}));
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'rating - single stimulus');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_ss_img = dataset_subset(D_ss, strcmp( D_ss.image, IMGsMain{k} ) );       
    draw_images_order(hth, ALGRs, D_ss_img, 'rating - single stimulus', 'z-scores');
    report_plot_ranking_triangles(hth, D_ss2, IMGsMain{k}, 'rating - single stimulus');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'rating - double stimulus');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_ds_img = dataset_subset(D_ds, strcmp( D_ds.image, IMGsMain{k} ) );       
    draw_images_order(hth, ALGRs, D_ds_img, 'rating - double stimulus', 'z-scores');
    report_plot_ranking_triangles(hth, D_ds2, IMGsMain{k}, 'rating - double stimulus');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'forced choices');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_pc_img = dataset_subset(D_pc, strcmp( D_pc.image, IMGsMain{k} ) );       
    draw_images_order(hth, ALGRs, D_pc_img, 'forced choices', 'votes');
    report_plot_ranking_triangles(hth, D_pc2, IMGsMain{k}, 'forced choices');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'similarity judgements');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_sj_img = dataset_subset(D_sj, strcmp( D_sj.image, IMGsMain{k} ) );       
    draw_images_order(hth, ALGRs, D_sj_img, 'similarity judgements', 'scores');
    report_plot_ranking_triangles(hth, D_sj2, IMGsMain{k}, 'similarity judgements');
end

html_table_row_beg(hth);
fprintf( hth.fh, '<TH colspan="7" align="left">'); 
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '<HR/>\n' );
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '<B> other images </B>');
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '</BR>' );
fprintf( hth.fh, '</TH'); 
html_table_row_end(hth);

for k=1:length(IMGsNoMain)
    html_table_row_beg(hth);
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, sprintf('<B> scene: %s </B>',IMGsNoMain{k}));
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'rating - single stimulus');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_ss_img = dataset_subset(D_ss, strcmp( D_ss.image, IMGsNoMain{k} ) );       
    draw_images_order(hth, ALGRs, D_ss_img, 'rating - single stimulus', 'z-scores');
    report_plot_ranking_triangles(hth, D_ss2, IMGsNoMain{k}, 'rating - single stimulus');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'rating - double stimulus');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_ds_img = dataset_subset(D_ds, strcmp( D_ds.image, IMGsNoMain{k} ) );       
    draw_images_order(hth, ALGRs, D_ds_img, 'rating - double stimulus', 'z-scores');
    report_plot_ranking_triangles(hth, D_ds2, IMGsNoMain{k}, 'rating - double stimulus');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'forced choice');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_pc_img = dataset_subset(D_pc, strcmp( D_pc.image, IMGsNoMain{k} ) );       
    draw_images_order(hth, ALGRs, D_pc_img, 'forced choices', 'votes');
    report_plot_ranking_triangles(hth, D_pc2, IMGsNoMain{k}, 'forced choices');
    fprintf( hth.fh, '<TH colspan="7" align="left">'); 
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, 'similarity judgements');
    fprintf( hth.fh, '</BR>' );
    fprintf( hth.fh, '</TH'); 
    html_table_row_end(hth);
    fprintf( hth.fh, '<TR>\n' );
    D_sj_img = dataset_subset(D_sj, strcmp( D_sj.image, IMGsNoMain{k} ) );       
    draw_images_order(hth, ALGRs, D_sj_img, 'similarity judgements', 'scores');
    report_plot_ranking_triangles(hth, D_sj2, IMGsNoMain{k}, 'similarity judgements');
end

html_table_end( hth );
html_close( hth );
