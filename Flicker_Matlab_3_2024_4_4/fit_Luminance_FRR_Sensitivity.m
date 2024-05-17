clear all;
clc;
jsonFilePath = 'E:\Datasets\RD-80SA/2024-4-14_gather_result_2.json';
jsonData = jsondecode(fileread(jsonFilePath));

Log_Luminance_List = log10(jsonData.L_list);
FRR_list = jsonData.real_fundamental_frequency_list;
contrast_List = jsonData.dL_list ./ jsonData.L_list;
log10_sensitivity_list = log10(1 ./ contrast_List);
% scatter(Log_Luminance_List, contrast_List);
X = [Log_Luminance_List, FRR_list];
coefficients = polyfitn(X, log10_sensitivity_list, 1);

[Log_Luminance_Fit, FRR_Fit] = meshgrid(linspace(min(Log_Luminance_List), max(Log_Luminance_List), 100), linspace(min(FRR_list), max(FRR_list), 100));
log10_sensitivity_Fit = polyvaln(coefficients, [Log_Luminance_Fit(:), FRR_Fit(:)]);
log10_Sensitivity_Fit = reshape(log10_sensitivity_Fit, size(Log_Luminance_Fit));


scatter3(10.^Log_Luminance_List, FRR_list, log10_sensitivity_list, 'o', 'r', 'filled');
hold on;
surf(10.^Log_Luminance_Fit, FRR_Fit, log10_Sensitivity_Fit, 'EdgeColor','none');
% colormap(hsv);
xlabel('Luminance (cd/m^2)');
xticks([0.1,0.2,0.5,1,2,5,10]);
xticklabels([0.1,0.2,0.5,1,2,5,10]);
xlim([min(10.^Log_Luminance_List),max(10.^Log_Luminance_List)])
ylabel('Frequency of Refresh Rate Switch - F_{rrs} (Hz)');
% zlim([0, 0.11]);
zlabel('Sensitivity');
Z_S = [1,2,3,4];
zticks(Z_S);
zticklabels(10.^Z_S);
zlim([1,4]);
set(gca, 'XScale', 'log');
% set(gca, 'ZScale', 'log');

% save_json_file_path = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/Luminance_FRR_to_Sensitivity.json';
% coefficients_1d = polyfitn(X, log10_sensitivity_list, 1);
% coefficients_2d = polyfitn(X, log10_sensitivity_list, 2);
% coefficients_3d = polyfitn(X, log10_sensitivity_list, 3);
% coefficients_4d = polyfitn(X, log10_sensitivity_list, 4);
% coefficients_5d = polyfitn(X, log10_sensitivity_list, 5);
% coefficients_6d = polyfitn(X, log10_sensitivity_list, 6);
% coefficients_7d = polyfitn(X, log10_sensitivity_list, 7);
% coeff_struct = struct('coefficients_1d', coefficients_1d, 'coefficients_2d', coefficients_2d, ...
%     'coefficients_3d', coefficients_3d, 'coefficients_4d', coefficients_4d, 'coefficients_5d', ...
%     coefficients_5d, 'coefficients_6d', coefficients_6d, 'coefficients_7d', coefficients_7d);
% fid = fopen(save_json_file_path, 'w');
% fwrite(fid, jsonencode(coeff_struct));
% fclose(fid);