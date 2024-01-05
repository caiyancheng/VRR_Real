stelacsf_model = CSF_stelaCSF();

t_frequency_range = linspace(1, 200, 1000);
luminance_list = [0.1,1, 10, 100, 1000];
spatial_frequency_list = [0.1,1,5,10,20];
size_list = [0.1,1,10,100,1000];
y_lim_range = [0.001,2000];

figure;
ha = tight_subplot(1, 3, [.05 .06],[.15 .08],[.09 .01]);
color_list = ['r','g','b','m','c','y','w','k',];
s_value_list = [0.1,1,10,100,1000];
t_value_list = [1,5, 10,30,60,120];

axes(ha(1)); %Luminance
for i = 1:length(luminance_list)
    luminance_value = luminance_list(i);
    csf_pars = struct('s_frequency', 1, 't_frequency', t_frequency_range, 'orientation', 0, ...
        'luminance', luminance_value, 'area', 10, 'eccentricity', 0);
    sensitivity_list = stelacsf_model.sensitivity(csf_pars);
    plot(t_frequency_range, sensitivity_list, '-', 'Color', color_list(i), 'LineWidth', 1, 'DisplayName', [num2str(luminance_value), ' cd/m^2']);
    hold on;
end
grid on;
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
% xlabel('Temporal Frequency (Hz)','FontSize',11);
ylabel('Sensitivity','FontSize',11);
% text(1.5,0.01, 'Spatial Frequency = 5 cpd, Size = 10 degree^2');
title('1 cpd, 10 degree^2','FontSize',11);
hLegend = legend('show','FontSize',8);
set(hLegend, 'Location', 'best', 'Orientation', 'vertical'); 
set(ha(1),'YTick',s_value_list); 
set(ha(1),'YTickLabel',s_value_list); 
set(ha(1),'XTick',t_value_list); 
set(ha(1),'XTickLabel',t_value_list);

axes(ha(2)); %Luminance
for i = 1:length(spatial_frequency_list)
    spatial_frequency_value = spatial_frequency_list(i);
    csf_pars = struct('s_frequency', spatial_frequency_value, 't_frequency', t_frequency_range, 'orientation', 0, ...
        'luminance', 10, 'area', 10, 'eccentricity', 0);
    sensitivity_list = stelacsf_model.sensitivity(csf_pars);
    plot(t_frequency_range, sensitivity_list, '-', 'Color', color_list(i), 'LineWidth', 1, 'DisplayName', [num2str(spatial_frequency_value), ' cpd']);
    hold on;
end
grid on;
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
xlabel('Temporal Frequency (Hz)','FontSize',11);
% ylabel('Sensitivity','FontSize',12);
% text(1.5,0.01, 'Luminance = 10 nits, Size = 10 degree^2');
title('10 cd/m^2, 10 degree^2','FontSize',11);
hLegend = legend('show','FontSize',8);
set(hLegend, 'Location', 'best', 'Orientation', 'vertical'); 
set(ha(2),'YTick',s_value_list); 
set(ha(2),'YTickLabel',s_value_list); 
set(ha(2),'XTick',t_value_list); 
set(ha(2),'XTickLabel',t_value_list);

axes(ha(3)); %Luminance
for i = 1:length(size_list)
    size_value = spatial_frequency_list(i);
    csf_pars = struct('s_frequency', 1, 't_frequency', t_frequency_range, 'orientation', 0, ...
        'luminance', 10, 'area', size_value, 'eccentricity', 0);
    sensitivity_list = stelacsf_model.sensitivity(csf_pars);
    plot(t_frequency_range, sensitivity_list, '-', 'Color', color_list(i), 'LineWidth', 1, 'DisplayName', [num2str(size_value), ' degree^2']);
    hold on;
end
grid on;
set(gca, 'XScale', 'log'); 
ylim(y_lim_range);
set(gca, 'YScale', 'log');
% xlabel('Temporal Frequency (Hz)','FontSize',11);
% ylabel('Sensitivity','FontSize',12);
% text(1.5,0.01, 'Spatial Frequency = 5 cpd, Luminance = 10 cd/m^2');
title('1 cpd, 10 cd/m^2','FontSize',11);
hLegend = legend('show','FontSize',8);
set(hLegend, 'Location', 'best', 'Orientation', 'vertical'); 
set(ha(3),'YTick',s_value_list); 
set(ha(3),'YTickLabel',s_value_list); 
set(ha(3),'XTick',t_value_list); 
set(ha(3),'XTickLabel',t_value_list);