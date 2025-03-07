observer_name = 'Chuyao';
base_path = '..\VRR_subjective_Quest\Result_Quest_disk_4_pro';
ds = dataset('File', [base_path '\Observer_' observer_name '_2/reorder_result.csv'],'Delimiter',',');
% ds = dataset('File',['..\VRR_subjective_Quest\Result_Quest_gabor_1\Observer_' observer_name '_2/reorder_result.csv'],'Delimiter',',');
options = { 'psych_func', @pf_dec_lin, 'intensity_label', 'Color Value', 'intensity_scale', 'linear', ...
            'intensity_range', [0.,0.2,], 'bootstrap_samples', 0, 'target_p', 0.75, ...
            'report_file',  [base_path '\Observer_' observer_name '_2/report/reorder_result_D_thr.html']};
% D_thr = fit_psych_func( ds, { 'Duration','VRR_Frequency'}, 'Threshold_Color_Value', 'Response', 260, 0.5, options ); %260
D_thr = fit_psych_func( ds, { 'VRR_Frequency', 'Size_Degree'}, 'Threshold_Color_Value', 'Response', 260, 0.5, options );
% D_thr = fit_psych_func( ds, { 'VRR_Frequency', 'Size_Degree', 'Gabor_Frequency'}, 'Threshold_Color_Value', 'Response', 260, 0.5, options );
D_thr_table = dataset2table(D_thr);
writetable(D_thr_table, [base_path '\Observer_' observer_name '_2/reorder_result_D_thr.csv'], 'Delimiter', ',');
% writetable(D_thr_table, ['..\VRR_subjective_Quest\Result_Quest_gabor_1\Observer_' observer_name '_2/reorder_result_D_thr.csv'], 'Delimiter', ',');