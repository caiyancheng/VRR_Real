clear all;
clc;
csf_model = CSF_castleCSF_CFF();
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\csf-castle-cff-opt";
% t_frequency = linspace(0,100,100);

% eccentricity_list = [20,30,40,50,60];
% for ecc_index = 1:length(eccentricity_list)
%     sensitivity_list = zeros(1,length(t_frequency));
%     for t_f_index = 1:length(t_frequency)
%         csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency(t_f_index), 'orientation', 0, ...
%             'luminance', 2, 'area', 2, 'eccentricity', eccentricity_list(ecc_index));
%         sensitivity_list(t_f_index) = csf_model.sensitivity_edge(csf_pars);
%     end
%     plot(t_frequency, sensitivity_list, 'DisplayName', ['ecc=', num2str(eccentricity_list(ecc_index))]);
%     hold on;
% end
% 
% set(gca, 'YScale', 'log');

ecc_s = linspace(0,60,60)';