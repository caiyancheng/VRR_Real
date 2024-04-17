% jsonFilePath = 'E:\Py_codes\VRR_Real\Flicker_Matlab_3_2024_4_4/Luminance_FRR_to_Contrast.json';
% jsonData = jsondecode(fileread(jsonFilePath));
% coefficients = jsonData.coefficients_4d;
clear all;
clc;
jsonFilePath = 'E:\Datasets\RD-80SA/2024-4-14_gather_result_2.json';
jsonData = jsondecode(fileread(jsonFilePath));
Log_Luminance_List = log10(jsonData.L_list);
FRR_list = jsonData.real_fundamental_frequency_list;

Contrast_transformation = Luminance_VRR_2_Contrast();
[Log_Luminance_Fit, FRR_Fit] = meshgrid(linspace(min(Log_Luminance_List), max(Log_Luminance_List), 100), linspace(min(FRR_list), max(FRR_list), 100));
contrast_Fit = Contrast_transformation.LT2C(Log_Luminance_Fit(:), FRR_Fit(:));
Contrast_Fit = reshape(contrast_Fit, size(Log_Luminance_Fit));
surf(Log_Luminance_Fit, FRR_Fit, Contrast_Fit, 'EdgeColor','none');
colormap(hsv);
xlabel('Log10 Luminance (cd/m^2)');
ylabel('Frequency of RR Switch (Hz)');
zlim([0,0.11]);
zlabel('Contrast');

