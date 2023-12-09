function [x_freq, K_FFT] = compute_spatial_FFT(x_spatial_array, y_stimulus_array, frequency_upper, plot_FFT, skip_0, force_equal)
    function plot_pict(x_array, y_array, x_label, y_label, title, save)
        if save
            saveas(gcf, [title, '.png']);
            close;
        else
            figure;
            plot(x_array, y_array);
            title(title);
            xlabel(x_label);
            ylabel(y_label);
            grid on;
            box on;
            axis tight;
        end
    end

    if force_equal
        y_stimulus_array(end) = y_stimulus_array(1);
    end

    w_s = 1 / mean(diff(x_spatial_array));
    N_s = numel(x_spatial_array);
    K_FFT = abs(fft(y_stimulus_array)) / N_s;
    x_freq = (0:N_s-1) * w_s / N_s;
    x_freq_sub = x_freq(x_freq <= frequency_upper);
    N_s_sub = numel(x_freq_sub);

    if plot_FFT
        if skip_0
            plot_pict(x_freq(2:N_s_sub), K_FFT(2:N_s_sub), 'Frequency', 'Amplitude', 'Spectrum Overall', false);
        else
            plot_pict(x_freq(1:N_s_sub), K_FFT(1:N_s_sub), 'Frequency', 'Amplitude', 'Spectrum Overall', false);
        end
    end
end
