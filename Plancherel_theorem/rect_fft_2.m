% 参数设置
w = 630; % 信号宽度
r = 4;  % 方波信号的半宽度
a = 1;  % 方波信号的幅度
N = 10000; % 采样点数量

disc_F = @(radius, rho, A, w) (2*A/w)*radius.*sinc(2*rho.*radius);
% disc_F_2 = @(radius, rho, A, w) (2*A*radius.*sinc(2*pi*rho.*radius));

% 生成x坐标
x = linspace(-w/2, w/2, N);

% 生成信号
signal = zeros(size(x));
signal(abs(x) <= r) = a;

% 计算傅里叶变换
fourier_transform = fftshift(fft(signal))/N;


% 计算频率坐标
sampling_rate = 1 / (x(:,2) - x(:,1));
frequencies = linspace(-sampling_rate/2, sampling_rate/2, N);
disc_F_s = disc_F(r, frequencies', a, w);
% disc_F_s_2 = disc_F_2(r, frequencies', a, w);

figure;
% 绘制原始信号
subplot(2, 1, 1);
plot(x, signal);
title('Orignal Signal');
xlabel('x');
ylabel('Luminance');
grid on;

% 绘制傅里叶变换结果
subplot(2, 1, 2);
plot(frequencies, abs(fourier_transform));
hold on;
plot(frequencies, abs(disc_F_s));
% plot(frequencies, abs(disc_F_s_2));
title('FFT');
xlim([-2,2]);
xlabel('Spatial Frequency (cpd)');
ylabel('Amplitude');
grid on;

B = abs(fourier_transform);
B(N/2)
