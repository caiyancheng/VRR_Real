clear all;
clc;

compute_values = 0;
plot_figures = 1;

csf_elaTCSF_model = CSF_elaTCSF_16_TCSF_free();

% 固定Luminance和Area求不同Luminance下Sensitivity和T_frequency的关系
PLOT_1_t_frequency_list = linspace(2,60,100);
PLOT_1_luminance = 3;
PLOT_1_area_list = [0.1,1,10,100,1000];
PLOT_1_eccentricity = 0;

% 固定Eccentricity, T_frequency求不同Luminance下Sensitivity和Area的关系
PLOT_4_area_list = logspace(log10(1),log10(1000),100);
PLOT_4_eccentricity = 0;
PLOT_4_t_frequency = 20;
PLOT_4_luminance_list = [0.1,1,10,100,1000];

% 固定Eccentricity求不同Luminance下CFF和Area的关系
PLOT_8_area_list = logspace(log10(1),log10(1000),100);
PLOT_8_eccentricity = 0;
PLOT_8_luminance_list = [0.1,1,10,100];

if (compute_values == 1)
    S_response_1 = zeros(length(PLOT_1_area_list), length(PLOT_1_t_frequency_list));
    for area_index = 1:length(PLOT_1_area_list)
        area = PLOT_1_area_list(area_index);
        for t_frequency_index = 1:length(PLOT_1_t_frequency_list)
            t_frequency = PLOT_1_t_frequency_list(t_frequency_index);
            % radius = (PLOT_1_area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, ...
                    'luminance', PLOT_1_luminance, 'area', area, 'eccentricity', PLOT_1_eccentricity);
            S_response_1(area_index, t_frequency_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_1, 'final_plot_CSF_CFF_area/S_response_1.csv');

    S_response_4 = zeros(length(PLOT_4_luminance_list), length(PLOT_4_area_list));
    for luminance_index = 1:length(PLOT_4_luminance_list)
        luminance = PLOT_4_luminance_list(luminance_index);
        for area_index = 1:length(PLOT_4_area_list)
            area = PLOT_4_area_list(area_index);
            % radius = (area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', PLOT_4_t_frequency, 'orientation', 0, ...
                    'luminance', luminance, 'area', area, 'eccentricity', PLOT_4_eccentricity);
            S_response_4(luminance_index, area_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_4, 'final_plot_CSF_CFF_area/S_response_4.csv');

    CFF_response_8 = zeros(length(PLOT_8_luminance_list), length(PLOT_8_area_list));
    for luminance_index = 1:length(PLOT_8_luminance_list)
        luminance = PLOT_8_luminance_list(luminance_index);
        for area_index = 1:length(PLOT_8_area_list)
            area = PLOT_8_area_list(area_index);
            % radius = (area/pi)^0.5;
            % bs_func = @(omega) -Energy_S_ecc(csf_elTCSF_model, omega, luminance, radius,...
            %     optimized_E_thr_s, optimized_beta, eccentricity);
            bs_func = @(omega) - csf_elaTCSF_model.sensitivity(struct('s_frequency', 0, 't_frequency', omega, 'orientation', 0, ...
                    'luminance', luminance, 'area', area, 'eccentricity', PLOT_8_eccentricity));
            CFF_response_8(luminance_index, area_index) = binary_search_vec(bs_func, -1, [8 400], 20);
        end
    end
    writematrix(CFF_response_8, 'final_plot_CSF_CFF_area/CFF_response_8.csv');
else
    S_response_1_flat = readmatrix('final_plot_CSF_CFF_area/S_response_1.csv');
    S_response_1 = reshape(S_response_1_flat, [length(PLOT_1_area_list), length(PLOT_1_t_frequency_list)]);
    S_response_4_flat = readmatrix('final_plot_CSF_CFF_area/S_response_4.csv');
    S_response_4 = reshape(S_response_4_flat, [length(PLOT_4_luminance_list), length(PLOT_4_area_list)]);
    CFF_response_8_flat = readmatrix('final_plot_CSF_CFF_area/CFF_response_8.csv');
    CFF_response_8 = reshape(CFF_response_8_flat, [length(PLOT_8_luminance_list), length(PLOT_8_area_list)]);
end

label_y_place = -.2;
fontsize = 14;
if (plot_figures == 1)
    % ha = tight_subplot(2, 4, [.16 .023],[.07 .04],[.04 .01]);
    figure('Position', [100, 100, 1100, 380]);
    ha = tight_subplot(1, 3, [.16 .07],[.14 .09],[.06 .02]);
    S_y_range = [1,10,100,1000];
    CFF_y_range = [10,20,30,40,50,60,70,80,90,100,110,120];

    axes(ha(1));
    hh = [];
    for area_index = 1:length(PLOT_1_area_list)
        area = PLOT_1_area_list(area_index);
        S_response_1_area = S_response_1(area_index,:);
        hh(end+1) = plot(PLOT_1_t_frequency_list, S_response_1_area, 'LineWidth', 2, 'DisplayName', [num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Temporal frequency [Hz]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    xlim([2,60]);
    ylim([1, 1000]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Eccentricity = ' num2str(PLOT_1_eccentricity) ' degree, Luminance = ' num2str(PLOT_1_luminance) ' cd/m^2']);
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(a)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(2));
    hh = [];
    for luminance_index = 1:length(PLOT_4_luminance_list)
        luminance = PLOT_4_luminance_list(luminance_index);
        S_response_4_luminance = S_response_4(luminance_index,:);
        hh(end+1) = plot(PLOT_4_area_list, S_response_4_luminance, 'LineWidth', 2, 'DisplayName', [num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Area [degree^2]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    ylim([min(S_y_range),max(S_y_range)]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    title(['Eccentricity = ' num2str(PLOT_4_eccentricity) ' degree, Temp. freq. = ' num2str(PLOT_4_t_frequency) ' Hz']);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(d)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(3));
    hh = [];
    for luminance_index = 1:length(PLOT_8_luminance_list)
        luminance = PLOT_8_luminance_list(luminance_index);
        CFF_response_8_luminance = CFF_response_8(luminance_index,:);
        hh(end+1) = plot(PLOT_8_area_list, CFF_response_8_luminance, 'LineWidth', 2, 'DisplayName', [num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Area [degree^2]', FontSize=fontsize);
    ylabel( 'Critical Flicker Frequency [Hz]', FontSize=fontsize);
    ylim([min(CFF_y_range),max(CFF_y_range)]);
    yticks(CFF_y_range);
    yticklabels(CFF_y_range);
    xticks([1,10,100,1000]);
    xticklabels([1,10,100,1000]);
    title(['Eccentricity = ' num2str(PLOT_8_eccentricity) ' degree']);
    set(gca, 'XScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(h)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
end
