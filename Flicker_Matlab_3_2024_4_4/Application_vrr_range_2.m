clear all;
clc;

Luminance_range = logspace(log10(1),log10(1000),20);
refresh_rate_range = [24,36,48,60,90,120];
k = (log10(0.02) - log10(0.0025)) / log10(100);
contrast_function = @(RR, Lum) ((144 - RR) / (144 - 40)) * 10 ^ ((-k * log10(Lum) + log10(0.02)));

hh = [];
for RR_index = 1:length(refresh_rate_range)
    RR_value = refresh_rate_range(RR_index);
    contrast_list = [];
    for Lum_index = 1:length(Luminance_range)
        Luminance_value = Luminance_range(Lum_index);
        contrast = contrast_function(RR_value, Luminance_value);
        contrast_list(end+1) = contrast;
    end
    hh(end+1) = plot(Luminance_range, contrast_list, 'LineWidth', 2, 'DisplayName', [num2str(RR_value) ' Hz']);
    hold on;
end


Contrast_Ticks = [0.001,0.01,0.1];
xlabel('Luminance (cd/m^2)');
ylabel('VRR Contrast (Simulated)');
xlim([1,1000]);
ylim([min(Contrast_Ticks), max(Contrast_Ticks)]);
set(gca, 'XScale', 'log', 'XTick', [1, 10, 100, 1000], 'XTickLabel', [1, 10, 100, 1000]);
set(gca, 'YScale', 'log', 'YTick', Contrast_Ticks, 'YTickLabel', Contrast_Ticks);
legend (hh, 'Location', 'best','NumColumns', 2);