function [x_freq_sub, K_FFT_sub] = compute_signal_FFT(x_time_array, y_luminance_array, frequency_upper, plot_FFT, skip_0, force_equal)
    if force_equal
        y_luminance_array(end) = y_luminance_array(1);
    end
    w_s = 1 / mean(diff(x_time_array));
    N_s = length(x_time_array);
    K_FFT = abs(fft(y_luminance_array)) / N_s;
    x_freq = (0:N_s-1) * w_s / N_s;
    x_freq_sub = x_freq(x_freq <= frequency_upper);

    if plot_FFT
        if skip_0
            plot_pict(x_freq(2:length(x_freq_sub)), K_FFT(2:length(x_freq_sub)), 'Frequency', 'Amplitude', 'Spectrum Overall', false, false);
        else
            plot_pict(x_freq(1:length(x_freq_sub)), K_FFT(1:length(x_freq_sub)), 'Frequency', 'Amplitude', 'Spectrum Overall', false, false);
        end
    end

    x_freq_sub = x_freq_sub';
    K_FFT_sub = K_FFT(1:length(x_freq_sub))';
end