clear all;
clc;

compute_values = 0;
plot_figures = 1;

csf_elaTCSF_model = CSF_elaTCSF_16_TCSF_free();

% 固定Luminance和Area求不同Luminance下Sensitivity和T_frequency的关系
PLOT_1_t_frequency_list = linspace(2,60,100);
PLOT_1_luminance_list = [1, 10, 100, 1000];
PLOT_1_area = 1;
PLOT_1_eccentricity = 0;

% 固定Eccentricity, T_frequency求不同Area下Sensitivity和Luminance的关系
PLOT_3_luminance_list = logspace(log10(1),log10(1000),100);
PLOT_3_eccentricity = 0;
PLOT_3_t_frequency = 20;
PLOT_3_area_list = [0.1,1,10,100,1000];

% 固定Eccentricity求不同Area下CFF和Luminance的关系
PLOT_7_luminance_list = logspace(log10(1),log10(1000),100);
PLOT_7_eccentricity = 0;
PLOT_7_area_list = [1,10,100,1000];

if (compute_values == 1)
    S_response_1 = zeros(length(PLOT_1_luminance_list), length(PLOT_1_t_frequency_list));
    for luminance_index = 1:length(PLOT_1_luminance_list)
        luminance = PLOT_1_luminance_list(luminance_index);
        for t_frequency_index = 1:length(PLOT_1_t_frequency_list)
            t_frequency = PLOT_1_t_frequency_list(t_frequency_index);
            % radius = (PLOT_1_area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, ...
                    'luminance', luminance, 'area', PLOT_1_area, 'eccentricity', PLOT_1_eccentricity);
            S_response_1(luminance_index, t_frequency_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_1, 'final_plot_CSF_CFF_luminance/S_response_1.csv');

    S_response_3 = zeros(length(PLOT_3_area_list), length(PLOT_3_luminance_list));
    for area_index = 1:length(PLOT_3_area_list)
        area = PLOT_3_area_list(area_index);
        for luminance_index = 1:length(PLOT_3_luminance_list)
            luminance = PLOT_3_luminance_list(luminance_index);
            % radius = (area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', PLOT_3_t_frequency, 'orientation', 0, ...
                    'luminance', luminance, 'area', area, 'eccentricity', PLOT_3_eccentricity);
            S_response_3(area_index, luminance_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_3, 'final_plot_CSF_CFF_luminance/S_response_3.csv');

    CFF_response_7 = zeros(length(PLOT_7_area_list), length(PLOT_7_luminance_list));
    for area_index = 1:length(PLOT_7_area_list)
        area = PLOT_7_area_list(area_index);
        for luminance_index = 1:length(PLOT_7_luminance_list)
            luminance = PLOT_7_luminance_list(luminance_index);
            % radius = (area/pi)^0.5;
            % bs_func = @(omega) -Energy_S_ecc(csf_elTCSF_model, omega, luminance, radius,...
            %     optimized_E_thr_s, optimized_beta, );
            bs_func = @(omega) - csf_elaTCSF_model.sensitivity(struct('s_frequency', 0, 't_frequency', omega, 'orientation', 0, ...
                    'luminance', luminance, 'area', area, 'eccentricity', PLOT_7_eccentricity));
            CFF_response_7(area_index, luminance_index) = binary_search_vec(bs_func, -1, [8 400], 20);
        end
    end
    writematrix(CFF_response_7, 'final_plot_CSF_CFF_luminance/CFF_response_7.csv');
else
    S_response_1_flat = readmatrix('final_plot_CSF_CFF_luminance/S_response_1.csv');
    S_response_1 = reshape(S_response_1_flat, [length(PLOT_1_luminance_list), length(PLOT_1_t_frequency_list)]);
    S_response_3_flat = readmatrix('final_plot_CSF_CFF_luminance/S_response_3.csv');
    S_response_3 = reshape(S_response_3_flat, [length(PLOT_3_area_list), length(PLOT_3_luminance_list)]);
    CFF_response_7_flat = readmatrix('final_plot_CSF_CFF_luminance/CFF_response_7.csv');
    CFF_response_7 = reshape(CFF_response_7_flat, [length(PLOT_7_area_list), length(PLOT_7_luminance_list)]);
end

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
    for luminance_index = 1:length(PLOT_1_luminance_list)
        luminance = PLOT_1_luminance_list(luminance_index);
        S_response_1_lum = S_response_1(luminance_index,:);
        hh(end+1) = plot(PLOT_1_t_frequency_list, S_response_1_lum, 'LineWidth', 2, 'DisplayName', ['luminance = ' num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Temporal frequency [Hz]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    xlim([2,60]);
    ylim([2, 300]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Eccentricity = ' num2str(PLOT_1_eccentricity) ' degree, Area = ' num2str(PLOT_1_area) ' degree^2']);
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(a)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(2));
    hh = [];
    for area_index = 1:length(PLOT_3_area_list)
        area = PLOT_3_area_list(area_index);
        S_response_3_area = S_response_3(area_index,:);
        hh(end+1) = plot(PLOT_3_luminance_list, S_response_3_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Luminance [cd/m^2]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    ylim([min(S_y_range),max(S_y_range)]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    title(['Eccentricity = ' num2str(PLOT_3_eccentricity) ' degree, Temp. freq. = ' num2str(PLOT_3_t_frequency) ' Hz']);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(c)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(3));
    hh = [];
    for area_index = 1:length(PLOT_7_area_list)
        area = PLOT_7_area_list(area_index);
        CFF_response_7_area = CFF_response_7(area_index,:);
        hh(end+1) = plot(PLOT_7_luminance_list, CFF_response_7_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Luminance [cd/m^2]', FontSize=fontsize);
    ylabel( 'Critical Flicker Frequency [Hz]', FontSize=fontsize);
    ylim([min(CFF_y_range),max(CFF_y_range)]);
    yticks(CFF_y_range);
    yticklabels(CFF_y_range);
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    xlim([1,1000]);
    title(['Eccentricity = ' num2str(PLOT_7_eccentricity) ' degree']);
    set(gca, 'XScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(g)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
end
