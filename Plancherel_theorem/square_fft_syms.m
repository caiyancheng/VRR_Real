% 清除所有之前的符号变量和设置
clear all;
close all;

% 使用符号变量
syms x y W H r a N;

% 生成信号
X = linspace(-W/2, W/2, N);
Y = linspace(-H/2, H/2, N);
[X, Y] = meshgrid(X, Y);

% 创建信号
signal = zeros(N, N);
signal(sqrt(X.^2 + Y.^2) <= r) = a;

% 计算傅里叶变换
fft_signal = fftshift(fft2(signal)) / (N^2);

% 创建频域坐标
sampling_rate_x = 1 / (X(1, 2) - X(1, 1));
sampling_rate_y = 1 / (Y(2, 1) - Y(1, 1));
f_x = linspace(-sampling_rate_x/2, sampling_rate_x/2, N);
f_y = linspace(-sampling_rate_y/2, sampling_rate_y/2, N);

% 绘制原始信号
figure;
subplot(2, 1, 1);
imagesc(X, Y, signal);
title('Disk Signal');
xlabel('x');
ylabel('y');
axis equal;
colormap('jet');
colorbar;

% 绘制傅里叶变换结果
subplot(2, 1, 2);
abs_fft_signal = abs(fft_signal);
imagesc(f_x, f_y, abs_fft_signal);
title('Fourier Transformation');
xlabel('rho x');
ylabel('rho y');
xlim([-0.5, 0.5]); % 设置x坐标轴显示范围为-1到1
ylim([-0.5, 0.5]); % 设置y坐标轴显示范围为-1到1
axis equal;
colormap('jet');
colorbar;
