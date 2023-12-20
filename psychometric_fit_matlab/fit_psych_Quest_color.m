% ds = readtable('B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_2\Observer_Yancheng_Cai_Test_10/result.csv');
ds = dataset('File','B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_2\Observer_Yancheng_Cai_Test_10/reorder_result_no16.csv','Delimiter',',');
options = { 'psych_func', @pf_dec_exp, 'intensity_label', 'Color Value', 'intensity_scale', 'linear', ...
            'intensity_range', [0.,0.3,], 'bootstrap_samples', 0, 'target_p', 0.75, 'alpha', 0.1, ...
            'report_file',  'B:/Py_codes/VRR_Real/psychometric_fit_matlab/Result_Quest_2_reorder_result_no16.html'};
D_thr = fit_psych_func( ds, { 'VRR_Frequency', 'Size_Degree'}, 'Threshold_Color_Value', 'Response', 3.5, 0.5, options );
D_thr_table = dataset2table(D_thr);
writetable(D_thr_table, 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_2\Observer_Yancheng_Cai_Test_10\reorder_result_no16_D_thr_result.csv', 'Delimiter', ',');