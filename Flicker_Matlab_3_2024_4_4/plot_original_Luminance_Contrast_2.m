% Load data from JSON file
gather_result_path = 'E:\Datasets\RD-80SA\2024-4-14_gather_result_2.json';
file_data = fileread(gather_result_path);
gather_result_data = jsondecode(file_data);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();

L_list = gather_result_data.L_list;
dL_list = gather_result_data.dL_list;
change_parameters = gather_result_data.change_parameters;
ff_dict = gather_result_data.ff_dict;
VRR_F_list = change_parameters.VRR_Frequency;
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
Size_list = change_parameters.Size;
colors = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], ...
          [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560], ...
          [0.4660, 0.6740, 0.1880], [0.3010, 0.7450, 0.9330], ...
          [0.6350, 0.0780, 0.1840], [0.5, 0.5, 0.5]};
markers = {'o', '+', '*', 'x', 's', 'd', '^', 'v'};

clear length
le = 10;
index = 1;
ha = tight_subplot(1, 1, [.13 .023],[.16 .01],[.09 .01]);
axes(ha(1));
% figure('Position',[100,100,600,600]);
hh = [];
for vrr_f_index = 1:length(VRR_F_list)
    vrr_f_value = VRR_F_list(vrr_f_index);
    for size_index = 1:length(Size_list)
        size_value = Size_list{size_index};
        L_plot_array = L_list((index-1)*le+1:index*le);
        dL_plot_array = dL_list((index-1)*le+1:index*le);
        contrast_plot_list = dL_plot_array ./ L_plot_array;
        if ~ischar(size_value)
            size_value = num2str(size_value);
            index = index + 1;
            continue;
        end
        if (vrr_f_value ~= 4)
            index = index + 1;
            continue;
        end
        hh(end+1) = scatter(L_plot_array, contrast_plot_list, 'MarkerEdgeColor', colors{vrr_f_index}, 'Marker', ...
            markers{vrr_f_index}, 'DisplayName', [num2str(FRR_indices(vrr_f_index)) ' Hz, ' size_value]);
        hold on;
        t_frequency_array = ones(size(L_plot_array)) .* vrr_f_value;
        fit_sensitivity = Sensitivity_transform.LT2S(L_plot_array, t_frequency_array);
        fit_contrast = 1 ./ fit_sensitivity;
        hh(end+1) = plot(L_plot_array, fit_contrast, 'Color', colors{vrr_f_index}, 'LineWidth', 1, 'DisplayName', [num2str(FRR_indices(vrr_f_index)) ' Hz - linear fitting result']);
        hold on;
        index = index + 1;
    end
end

for L_index = 1:length(L_plot_array)
    L_value = L_plot_array(L_index);

end


axes(ha(1));
set(gca, 'XScale', 'log', 'XTick', [0.5, 1, 2, 4, 8], 'XTickLabel', [0.5, 1, 2, 4, 8]);
set(gca, 'YScale', 'log', 'YTick', [0.001, 0.01, 0.1], 'YTickLabel', [0.001, 0.01, 0.1]);
xlim([0.5,8]);
ylim([0.001,0.1]);
% legend('Location', 'Best');
legend(hh, 'Location', 'best', 'Orientation', 'horizontal', 'NumColumns', 2, FontSize=8);
xlabel('VRR Signal Average Luminance (cd/m^2)', FontSize=12);
ylabel('VRR Contrast', FontSize=12);
hold off;

% axes(ha(2));
% set(gca, 'XScale', 'log', 'XTick', [0.5, 1, 2, 4, 8], 'XTickLabel', [0.5, 1, 2, 4, 8]);
% set(gca, 'YScale', 'log', 'YTick', [0.001, 0.01, 0.1], 'YTickLabel', [0.001, 0.01, 0.1]);
% ylim([0.001,0.1]);
% % legend('Location', 'Best');
% legend(hh, 'Location', 'best', 'Orientation', 'horizontal', 'NumColumns', 2, FontSize=10);
% xlabel('VRR Signal Average Luminance (cd/m^2)', FontSize=14);
% ylabel('VRR Contrast', FontSize=14);
% hold off;
