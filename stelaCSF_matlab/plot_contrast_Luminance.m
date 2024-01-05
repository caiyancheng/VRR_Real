luminance = linspace(1, 100, 1000)';
contrast = get_contrast_from_Luminance(luminance,4,0.5);
plot(luminance, contrast);
set(gca, 'XScale', 'log');