% 参数设置
L_b = 10;
c = 1;
beta = 3.5;
num_points = 1000;
size_value = 4;
t_frequency = linspace(0, 100, 1000);

% 初始化结果数组
result_stela = zeros(size(t_frequency));
result_stela_mod = zeros(size(t_frequency));
result_barten_mod = zeros(size(t_frequency));

% 遍历每个 t_frequency
for i = 1:length(t_frequency)
    % 计算结果
    [result_stela(i), result_stela_mod(i), result_barten_mod(i)] = multiple_contrast_energy_detectors_cyc(L_b, c, beta, num_points, t_frequency(i), size_value);
end

% 绘制图形
figure;

subplot(3, 1, 1);
plot(t_frequency, result_stela.^0.5, '-o');
title('S_{stela} for temporal (Yancheng 2)');

subplot(3, 1, 2);
plot(t_frequency, result_stela_mod.^0.5, '-o');
title('S_{stela_{mod}} for temporal (Yancheng 2)');

subplot(3, 1, 3);
plot(t_frequency, result_barten_mod.^0.5, '-o');
title('S_{barten_{mod}} for temporal (Yancheng 2)');

xlabel('t\_frequency');
ylabel('Contrast Sensitivity for temporal');
