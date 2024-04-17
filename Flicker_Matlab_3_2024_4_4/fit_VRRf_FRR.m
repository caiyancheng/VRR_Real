%Actually The Real FRR is not same as the VRR_f
clear all;
clc;
jsonFilePath = 'E:\Datasets\RD-80SA/2024-4-14_gather_result_2.json';
jsonData = jsondecode(fileread(jsonFilePath));

VRR_f_List = jsonData.vrr_f_list;
FRR_list = jsonData.real_fundamental_frequency_list;
coefficients = polyfit(VRR_f_List, FRR_list, 3);
VRR_f_Fit = linspace(min(VRR_f_List), max(VRR_f_List), 100);
FRR_fit_result = polyval(coefficients, VRR_f_Fit);

scatter(VRR_f_List, FRR_list, 'o');
hold on;
plot(VRR_f_Fit, FRR_fit_result);
plot(VRR_f_Fit, VRR_f_Fit, '--');
xlabel('VRR_f (In the code)');
ylabel('FRR (Real)');
