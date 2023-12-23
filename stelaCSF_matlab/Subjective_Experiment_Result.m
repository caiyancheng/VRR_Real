size_indices = [0.5, 1, 16, -1]; %-1 means full
vrr_f_indices = [0.5, 1, 2, 4, 8];
num_obs = 1;
num_points = 1000;
c = 1;
beta = 3.5;

c_t_subjective_path = 'B:\Py_codes\VRR_Real\VRR_subjective_Quest\Result_Quest_2\Observer_Yancheng_Cai_Test_10/reorder_result_no16_D_thr_result_C_t.csv';
data = readtable(c_t_subjective_path);
average_C_t_matrix = zeros(length(vrr_f_indices), length(size_indices)); %主观实验的结果

for vrr_f_i = 1:length(vrr_f_indices)
    vrr_f_value = vrr_f_indices(vrr_f_i);
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        filtered_data = data(data.Size_Degree == size_value & data.VRR_Frequency == vrr_f_value, :);
        if (height(filtered_data) >= 1)
            valids(vrr_f_i, size_i) = 1;
        else
            continue
        end
        valid_data = filtered_data(~isnan(filtered_data.C_t), :);
        average_C_t = mean(valid_data.C_t);
        luminance = mean(valid_data.Luminance);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
        else
            area_value = size_value^2;
        end
        average_C_t_matrix(vrr_f_i, size_i) = average_C_t;
    end
end

figure;
color_display_list = ['r', 'g', 'b'];
for size_i = 1:length(size_indices)
    if (size_i == 1)
        display_name = 'Size 1*1 degree';
    elseif (size_i == 2)
        display_name = 'Size 16*16 degree';
    elseif (size_i == 3)
        display_name = 'Size 62.666 * 37.808 degree';
    end
    scatter(vrr_f_indices, average_C_t_matrix(:,size_i), 50, 'Marker', 'o', 'MarkerFaceColor', color_display_list(size_i), 'MarkerEdgeColor', 'k', 'LineWidth', 1.0, 'DisplayName', display_name);
    plot(vrr_f_indices, average_C_t_matrix(:, size_i), 'Color', color_display_list(size_i), 'LineWidth', 1.0, 'DisplayName', display_name);
    hold on;
end
set(gca, 'XScale', 'log');
xlabel('Frequency of RR Switch (Hz)','FontSize',12);
ylabel('C_t','FontSize',12);
hold off;
hLegend = legend('show','FontSize',9);
set(hLegend, 'Location', 'eastoutside', 'Orientation', 'vertical');
legendPos = get(hLegend, 'Position');
legendPos(4) = legendPos(4) * 1.5;
legendPos(1) = 0.85 - legendPos(3)/2;
legendPos(2) = 0.5 - legendPos(4)/2;


set(hLegend, 'Position', legendPos);
