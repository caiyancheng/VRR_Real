% Load data from JSON file
gather_result_path = 'E:\Datasets\RD-80SA\2024-4-14_gather_result_2.json';
file_data = fileread(gather_result_path);
gather_result_data = jsondecode(file_data);

L_list = gather_result_data.L_list;
dL_list = gather_result_data.dL_list;
change_parameters = gather_result_data.change_parameters;
ff_dict = gather_result_data.ff_dict;
VRR_F_list = change_parameters.VRR_Frequency;
FRR_indices = [0.5, 2, 4, 8, 10, 11.9, 13.3, 14.9];
Size_list = change_parameters.Size;

clear length
le = 10;
index = 1;
figure('Position',[100,100,700,600]);
for vrr_f_index = 1:length(VRR_F_list)
    vrr_f_value = VRR_F_list(vrr_f_index);
    for size_index = 1:length(Size_list)
        size_value = Size_list{size_index};
        L_plot_array = L_list((index-1)*le+1:index*le);
        dL_plot_array = dL_list((index-1)*le+1:index*le);
        contrast_plot_list = dL_plot_array ./ L_plot_array;
        if ~ischar(size_value)
            size_value = num2str(size_value);
        end
        plot(L_plot_array, contrast_plot_list, 'LineWidth', 2, 'DisplayName', ['F_{rrs}=' num2str(FRR_indices(vrr_f_index)) 'Hz, size=' size_value]);
        hold on;
        index = index + 1;
    end
end
set(gca, 'XScale', 'log', 'XTick', [0.5, 1, 2, 4, 8], 'XTickLabel', [0.5, 1, 2, 4, 8]);
legend('Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 2);
xlabel('VRR Signal Average Luminance (cd/m^2)', FontSize=12);
ylabel('Contrast', FontSize=12);
hold off;
