clear;
clc;
% 定义符号变量
syms t w r a;

% 定义信号
signal = a * (heaviside(t + r) - heaviside(t - r));

% 定义傅里叶变换
fourier_transform = fourier(signal, t, w);

% 定义频率范围
frequencies = linspace(-w/2, w/2, 1000);

% 计算傅里叶变换的幅度和相位
amplitude = abs(fourier_transform);
phase = angle(fourier_transform);

% 绘制原始信号
subplot(2, 1, 1);
fplot(signal, [-w/2, w/2]);
title('原始信号');

% 绘制傅里叶变换的幅度
subplot(2, 1, 2);
plot(frequencies, amplitude);
title('傅里叶变换幅度');
xlabel('频率');
ylabel('幅度');

% 显示图形
grid on;
max = max(amplitude)

% 在信号是这样的，采样信号长度为[-w/2, w/2]，其中信号在[-r,r]上值为a, 其他地方的值为0，求这个信号的一维傅里叶变换