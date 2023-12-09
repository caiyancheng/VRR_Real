% Constants
size_list = [4, 16];
luminance_list = [1, 2, 3, 4, 5, 10, 100];

% Generate and plot horizontal FFT
figure;
hold on;
for size_value = size_list
    for luminance_value = luminance_list
        [horizontal_x, horizontal_y, ~, ~] = generate_signal(size_value, luminance_value, false);
        [x, amplitude] = compute_spatial_FFT(horizontal_x, horizontal_y, 200, false, false, true);
        plot(x, amplitude, 'DisplayName', ['S: ', num2str(size_value), ', L: ', num2str(luminance_value)]);
        hold on;
    end
end
xlabel('Cycles per Degree');
ylabel('Amplitude');
title('Horizontal FFT');
xlim([0, 30]);
legend;
% grid on;
% box on;
% axis tight;

% Generate and plot vertical FFT
figure;
hold on;
for size_value = size_list
    for luminance_value = luminance_list
        [~, ~, vertical_x, vertical_y] = generate_signal(size_value, luminance_value, false);
        [x, amplitude] = compute_spatial_FFT(vertical_x, vertical_y, 200, false, false, true);
        plot(x, amplitude, 'DisplayName', ['S: ', num2str(size_value), ', L: ', num2str(luminance_value)]);
        hold on;
    end
end
xlabel('Cycles per Degree');
ylabel('Amplitude');
title('Vertical FFT');
xlim([0, 30]);
legend;
% grid on;
% box on;
% axis tight;
