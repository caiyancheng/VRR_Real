csf_elaTCSF_model = CSF_elaTCSF_16_TCSF_free();

Luminance_list = logspace(log10(0.1), log10(1000), 100);
Sensitivity_rect_list = zeros(1,length(Luminance_list));
Sensitivity_disk_list = zeros(1,length(Luminance_list));
t_frequency = 4;

width_value = 2*atan(3840/2160/3.2)/pi*180;
height_value = 2*atan(1/3.2)/pi*180;

for Luminance_index = 1:length(Luminance_list)
    Luminance_value = Luminance_list(Luminance_index);

    csf_pars_rect = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, ...
        'luminance', Luminance_value, 'width', width_value, 'height', height_value, 'eccentricity', 0);
    S_rect = csf_elaTCSF_model.sensitivity_rect(csf_pars_rect);
    Sensitivity_rect_list(Luminance_index) = S_rect;
    
    area = (width_value / 2) ^ 2 * pi;
    csf_pars_disk = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, ...
        'luminance', Luminance_value, 'area', area, 'eccentricity', 0);
    S_disk = csf_elaTCSF_model.sensitivity(csf_pars_disk);
    Sensitivity_disk_list(Luminance_index) = S_disk;
end

plot(Luminance_list, Sensitivity_rect_list);
hold on;
plot(Luminance_list, Sensitivity_disk_list);
set(gca, 'XScale', 'log');