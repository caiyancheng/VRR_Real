clear all;
clc;
omega = linspace(0.5,100,100)';
% omega = linspace(0.5,15,100)';
params_1 = [148.7, 0.00267, 1.834, 0.882, 15, 16];
S_1 = S_TCSF_1(params_1, omega);
[maxValue, maxIndex] = max(S_1);
peak_f = omega(maxIndex);
params_2_1 = [4, 0.1898, 0.12314];
% params_2_2 = [7.612559044788514,1.063191842134452,34.195198652487434];`
params_2_2 = [8, 0.1898, 0.12314];
params_2_3 = [8, 0.1898, 0.12314/2];
S_2_1 = S_TCSF_2(params_2_1, omega);
S_2_2 = S_TCSF_2(params_2_2, omega);
S_2_3 = S_TCSF_2(params_2_3, omega);
% params_3 = [1.3314, 12.2643, 0.1898, 0.12314, 10];
% S_3 = S_TCSF_3(params_3, omega);
% params_4 = [5, 10, 1, 10];
% S_4 = S_TCSF_4(params_4, omega);
% params_5 = [0.272424424113982,0.5,8.822961917833661,0.315574134920240,6.590314091958587e+02];%[0.1, 0.2, 8, 100];
% S_5 = S_TCSF_5(params_5, omega);
% params_6 = [10, 2, 10, 10, 4];%[0.1, 0.2, 8, 100]; %第一个增加，函数上移；第二三个增加，函数右下移动
% S_6 = S_TCSF_6(params_6, omega);
params_7 = [3.361158848453080,6.114907707458653,7.732748484632348,1,5.383401082882644,7.057270867386469];%[0.1, 0.2, 8, 100]; %第一个增加，函数上移；第二三个增加，函数右下移动
S_7 = S_TCSF_7(params_7, omega);

hh = [];
hh(end+1) = plot(omega, S_1, 'DisplayName', 'Watson TCSF');
hold on;
hh(end+1) = plot(omega, S_2_1, 'DisplayName', 'Transient Chanel TCSF - peak at 4 Hz');
hh(end+1) = plot(omega, S_2_2, 'DisplayName', 'Transient Chanel TCSF - peak at 8 Hz');
hh(end+1) = plot(omega, S_2_3, 'DisplayName', 'Transient Chanel TCSF - peak at 8 Hz - bandwidth / 2');
% hh(end+1) = plot(omega, S_4, 'DisplayName', 'Weibull TCSF');
% hh(end+1) = plot(omega, S_5, 'DisplayName', 'Two line TCSF');
hh(end+1) = plot(omega, S_7, 'DisplayName', 'Two Guassian');
hold off;
xlabel('Frequency of Refresh Rate Switch (Hz)','FontSize',14);
ylabel('Sensitivity','FontSize',14);
set(gca, 'YScale', 'log');
% set(gca, 'XScale', 'log');
ylim([0.1,1000]);
legend(hh);