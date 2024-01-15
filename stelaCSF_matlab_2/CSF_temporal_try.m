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
result_stela_transient = zeros(size(t_frequency));
result_stela_mod_transient = zeros(size(t_frequency));
result_barten_mod = zeros(size(t_frequency));
result_stela_cyc_1 = zeros(size(t_frequency));
result_stela_mod_cyc_1 = zeros(size(t_frequency));
result_barten_mod_cyc_1 = zeros(size(t_frequency));


% 遍历每个 t_frequency
for i = 1:length(t_frequency)
    % 计算结果
    [result_stela(i), result_stela_mod(i), result_barten_mod(i)] = multiple_contrast_energy_detectors(L_b, c, beta, num_points, t_frequency(i), size_value);
end

for i = 1:length(t_frequency)
    % 计算结果
    [result_stela_cyc_1(i), result_stela_mod_cyc_1(i), result_barten_mod_cyc_1(i)] = multiple_contrast_energy_detectors_cyc_1(L_b, c, beta, num_points, t_frequency(i), size_value);
end

for i = 1:length(t_frequency)
    % 计算结果
    [result_stela_transient(i), result_stela_mod_transient(i)] = multiple_contrast_energy_detectors_transient(L_b, c, beta, num_points, t_frequency(i), size_value);
end

result_stela = result_stela.^0.5;
result_stela_mod = result_stela_mod.^0.5;
result_stela_transient = result_stela_transient.^0.5;
result_stela_mod_transient = result_stela_mod_transient.^0.5;
result_barten_mod = result_barten_mod.^0.5;
result_stela_cyc_1 = result_stela_cyc_1.^0.5;
result_stela_mod_cyc_1 = result_stela_mod_cyc_1.^0.5;
result_barten_mod_cyc_1 = result_barten_mod_cyc_1.^0.5;

dt_frequency = mean(diff(t_frequency));
derivative_stela = gradient(result_stela) / dt_frequency;
derivative_stela_mod = gradient(result_stela_mod) / dt_frequency;
derivative_barten_mod = gradient(result_barten_mod) / dt_frequency;

data = struct('t_frequency', t_frequency, ...
              'result_stela', result_stela, ...
              'result_stela_mod', result_stela_mod, ...
              'result_stela_transient', result_stela_transient, ...
              'result_stela_mod_transient', result_stela_mod_transient, ...
              'result_barten_mod', result_barten_mod, ...
              'result_stela_cyc_1', result_stela_cyc_1, ...
              'result_stela_mod_cyc_1', result_stela_mod_cyc_1, ...
              'result_barten_mod_cyc_1', result_barten_mod_cyc_1, ...
              'derivative_stela', derivative_stela, ...
              'derivative_stela_mod', derivative_stela_mod, ...
              'derivative_barten_mod', derivative_barten_mod);

% 将数据保存为JSON文件
json_str = jsonencode(data);
fid = fopen('sensitivity_all_temporal.json', 'w');
fprintf(fid, '%s', json_str);
fclose(fid);

% 绘制图形
figure;

subplot(3, 3, 1);
hold on;
plot(t_frequency, result_stela, '-o','DisplayName', 'Transient & Sustain');
plot(t_frequency, result_stela_transient, '-o','DisplayName', 'Transient Channel');
hold off;
legend('show');
title('S_{stela} for temporal');
subplot(3, 3, 2);
plot(t_frequency, result_stela_cyc_1, '-o');
title('S_{stela} for temporal ( * temporal frequency)');
subplot(3, 3, 3);
plot(t_frequency, abs(derivative_stela), '-o');
title('Derivative of S_{stela} for temporal');

subplot(3, 3, 4);
hold on;
plot(t_frequency, result_stela_mod, '-o','DisplayName', 'Transient & Sustain');
plot(t_frequency, result_stela_mod_transient, '-o','DisplayName', 'Transient Channel');
hold off;
legend('show');
title('S_{stela_{mod}} for temporal');
subplot(3, 3, 5);
plot(t_frequency, result_stela_mod_cyc_1, '-o');
title('Derivative of S_{stela_{mod}} for temporal ( * temporal frequency)');
subplot(3, 3, 6);
plot(t_frequency, abs(derivative_stela_mod), '-o');
title('Derivative of S_{stela_{mod}} for temporal');

subplot(3, 3, 7);
plot(t_frequency, result_barten_mod, '-o');
title('S_{barten_{mod}} for temporal');
subplot(3, 3, 8);
plot(t_frequency, result_barten_mod_cyc_1, '-o');
title('Derivative of S_{barten_{mod}} for temporal ( * temporal frequency)');
subplot(3, 3, 9);
plot(t_frequency, abs(derivative_barten_mod), '-o');
title('Derivative of S_{barten_{mod}} for temporal');

xlabel('t\_frequency');
ylabel('Contrast Sensitivity for temporal');
