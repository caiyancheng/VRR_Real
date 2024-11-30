clear all;
clc;

compute_values = 0;
plot_figures = 1;


% 固定Luminance和Area求不同Eccentricity下Sensitivity和T_frequency的关系
PLOT_1_t_frequency_list = linspace(2,60,100);
PLOT_1_luminance = 3;
PLOT_1_area = 1;
PLOT_1_eccentricity_list = [0, 10, 20, 30];

% 固定Luminance, T_frequency求不同Area下Sensitivity和Eccentricity的关系
PLOT_2_eccentricity_list = linspace(0,60,60);
PLOT_2_luminance = 3;
PLOT_2_t_frequency = 20;
PLOT_2_area_list = [0.1,1,10,100,1000];

% 固定Luminance求不同Area下CFF和Eccentricity的关系
PLOT_6_eccentricity_list = linspace(0,60,60);
PLOT_6_luminance = 1;
PLOT_6_area_list = [1,10,100,1000];

S_response_1_flat = readmatrix('final_plot_CSF_CFF/S_response_1.csv');
S_response_1 = reshape(S_response_1_flat, [length(PLOT_1_eccentricity_list), length(PLOT_1_t_frequency_list)]);
S_response_2_flat = readmatrix('final_plot_CSF_CFF/S_response_2.csv');
S_response_2 = reshape(S_response_2_flat, [length(PLOT_2_area_list), length(PLOT_2_eccentricity_list)]);
CFF_response_6_flat = readmatrix('final_plot_CSF_CFF/CFF_response_6.csv');
CFF_response_6 = reshape(CFF_response_6_flat, [length(PLOT_6_area_list), length(PLOT_6_eccentricity_list)]);

label_y_place = -.2;
fontsize = 14;
if (plot_figures == 1)
    % ha = tight_subplot(2, 4, [.16 .023],[.07 .04],[.04 .01]);
    figure('Position', [100, 100, 1100, 380]);
    ha = tight_subplot(1, 3, [.16 .07],[.14 .09],[.05 .01]);
    
    S_y_range = [1,10,100,1000];
    CFF_y_range = [10,20,30,40,50,60,70,80,90,100,110,120];

    axes(ha(1));
    hh = [];
    for eccentricity_index = 1:length(PLOT_1_eccentricity_list)
        eccentricity = PLOT_1_eccentricity_list(eccentricity_index);
        S_response_1_ecc = S_response_1(eccentricity_index,:);
        hh(end+1) = plot(PLOT_1_t_frequency_list, S_response_1_ecc, 'LineWidth', 2, 'DisplayName', ['eccentricity = ' num2str(eccentricity) ' degree']);
        hold on;
    end
    xlabel( 'Temporal frequency [Hz]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    xlim([2,60]);
    ylim([2, 300]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Luminance = ' num2str(PLOT_1_luminance) ' cd/m^2, Area = ' num2str(PLOT_1_area) ' degree^2'])%, FontSize=fontsize);
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(a)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(2));
    hh = [];
    for area_index = 1:length(PLOT_2_area_list)
        area = PLOT_2_area_list(area_index);
        S_response_2_area = S_response_2(area_index,:);
        hh(end+1) = plot(PLOT_2_eccentricity_list, S_response_2_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Eccentricity [degree]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    ylim([min(S_y_range),max(S_y_range)]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Luminance = ' num2str(PLOT_2_luminance) ' cd/m^2, Temp. freq. = ' num2str(PLOT_2_t_frequency) ' Hz'])%, FontSize=fontsize);
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(b)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(3));
    hh = [];
    for area_index = 1:length(PLOT_6_area_list)
        area = PLOT_6_area_list(area_index);
        CFF_response_6_area = CFF_response_6(area_index,:);
        hh(end+1) = plot(PLOT_6_eccentricity_list, CFF_response_6_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Eccentricity [degree]', FontSize=fontsize);
    ylabel( 'Critical Flicker Frequency [Hz]', FontSize=fontsize);
    ylim([min(CFF_y_range),max(CFF_y_range)]);
    yticks(CFF_y_range);
    yticklabels(CFF_y_range);
    title(['Luminance = ' num2str(PLOT_6_luminance) ' cd/m^2'])%, FontSize=fontsize);
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(f)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
end
