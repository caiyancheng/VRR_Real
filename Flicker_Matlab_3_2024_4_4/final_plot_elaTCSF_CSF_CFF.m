clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

compute_values = 1;
plot_figures = 1;

csf_elaTCSF_model = CSF_elaTCSF_16();
fitpars_dir = "E:\Matlab_codes\csf_datasets\model_fitting\fitted_models\Final-try-CSF_elaTCSF_16_new";
fname = fullfile( fitpars_dir, strcat(csf_elaTCSF_model.short_name(), '_all_*.mat' ) );
fl = dir( fname );
if isempty(fl)
    error( 'Fitted parameters missing for %s', fit_config.csf_models{model_index}.short_name() );
end
ind_latest = find( [fl(:).datenum]==max([fl(:).datenum]) );
fitted_pars_file = fullfile( fl(ind_latest).folder, fl(ind_latest).name );
fit_data = load( fitted_pars_file );
fprintf( 1, "Loaded: %s\n", fitted_pars_file )
csf_elaTCSF_model.par = CSF_base.update_struct( fit_data.fitted_struct, csf_elaTCSF_model.par );
csf_elaTCSF_model = csf_elaTCSF_model.set_pars(csf_elaTCSF_model.get_pars());

% 固定Luminance和Area求不同Eccentricity下Sensitivity和T_frequency的关系
PLOT_1_t_frequency_list = linspace(0,100,100);
PLOT_1_luminance = 3;
PLOT_1_area = 1;
PLOT_1_eccentricity_list = [0,10,20,30,40,50,60];

% 固定Luminance, T_frequency求不同Area下Sensitivity和Eccentricity的关系
PLOT_2_eccentricity_list = linspace(0,60,60);
PLOT_2_luminance = 3;
PLOT_2_t_frequency = 20;
PLOT_2_area_list = [0.1,1,10,100,1000];

% 固定Eccentricity, T_frequency求不同Area下Sensitivity和Luminance的关系
PLOT_3_luminance_list = logspace(log10(1),log10(1000),100);
PLOT_3_eccentricity = 0;
PLOT_3_t_frequency = 20;
PLOT_3_area_list = [0.1,1,10,100,1000];

% 固定Eccentricity, T_frequency求不同Luminance下Sensitivity和Area的关系
PLOT_4_area_list = logspace(log10(1),log10(1000),100);
PLOT_4_eccentricity = 0;
PLOT_4_t_frequency = 20;
PLOT_4_luminance_list = [0.1,1,10,100,1000];

% 固定Area求不同Luminance下CFF和Eccentricity的关系
PLOT_5_eccentricity_list = linspace(0,60,60);
PLOT_5_area = 1;
PLOT_5_luminance_list = [0.1,1,10,100];

% 固定Luminance求不同Area下CFF和Eccentricity的关系
PLOT_6_eccentricity_list = linspace(0,60,60);
PLOT_6_luminance = 1;
PLOT_6_area_list = [0.1,1,10,100];

% 固定Eccentricity求不同Area下CFF和Luminance的关系
PLOT_7_luminance_list = logspace(log10(1),log10(1000),100);
PLOT_7_eccentricity = 0;
PLOT_7_area_list = [0.1,1,10,100];

% 固定Eccentricity求不同Luminance下CFF和Area的关系
PLOT_8_area_list = logspace(log10(1),log10(1000),100);
PLOT_8_eccentricity = 0;
PLOT_8_luminance_list = [0.1,1,10,100];

if (compute_values == 1)
    S_response_1 = zeros(length(PLOT_1_eccentricity_list), length(PLOT_1_t_frequency_list));
    for eccentricity_index = 1:length(PLOT_1_eccentricity_list)
        eccentricity = PLOT_1_eccentricity_list(eccentricity_index);
        for t_frequency_index = 1:length(PLOT_1_t_frequency_list)
            t_frequency = PLOT_1_t_frequency_list(t_frequency_index);
            % radius = (PLOT_1_area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency, 'orientation', 0, ...
                    'luminance', PLOT_1_luminance, 'area', PLOT_1_area, 'eccentricity', eccentricity);
            S_response_1(eccentricity_index, t_frequency_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_1, 'final_plot_CSF_CFF/S_response_1.csv');

    S_response_2 = zeros(length(PLOT_2_area_list), length(PLOT_2_eccentricity_list));
    for area_index = 1:length(PLOT_2_area_list)
        area = PLOT_2_area_list(area_index);
        for eccentricity_index = 1:length(PLOT_2_eccentricity_list)
            eccentricity = PLOT_2_eccentricity_list(eccentricity_index);
            % radius = (area/pi)^0.5;
            csf_pars = struct('s_frequency', 0, 't_frequency', PLOT_2_t_frequency, 'orientation', 0, ...
                    'luminance', PLOT_2_luminance, 'area', area, 'eccentricity', eccentricity);
            S_response_2(area_index, eccentricity_index) = csf_elaTCSF_model.sensitivity(csf_pars);
        end
    end
    writematrix(S_response_2, 'final_plot_CSF_CFF/S_response_2.csv');

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
    writematrix(S_response_3, 'final_plot_CSF_CFF/S_response_3.csv');

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
    writematrix(S_response_4, 'final_plot_CSF_CFF/S_response_4.csv');

    CFF_response_5 = zeros(length(PLOT_5_luminance_list), length(PLOT_5_eccentricity_list));
    for luminance_index = 1:length(PLOT_5_luminance_list)
        luminance = PLOT_5_luminance_list(luminance_index);
        for eccentricity_index = 1:length(PLOT_5_eccentricity_list)
            eccentricity = PLOT_5_eccentricity_list(eccentricity_index);
            % radius = (PLOT_5_area/pi)^0.5;
            % bs_func = @(omega) -Energy_S_ecc(csf_elTCSF_model, omega, luminance, radius,...
            %     optimized_E_thr_s, optimized_beta, eccentricity);
            bs_func = @(omega) - csf_elaTCSF_model.sensitivity(struct('s_frequency', 0, 't_frequency', omega, 'orientation', 0, ...
                    'luminance', luminance, 'area', PLOT_5_area, 'eccentricity', eccentricity));
            CFF_response_5(luminance_index, eccentricity_index) = binary_search_vec(bs_func, -1, [8 400], 20);
        end
    end
    writematrix(CFF_response_5, 'final_plot_CSF_CFF/CFF_response_5.csv');

    CFF_response_6 = zeros(length(PLOT_6_area_list), length(PLOT_6_eccentricity_list));
    for area_index = 1:length(PLOT_6_area_list)
        area = PLOT_6_area_list(area_index);
        for eccentricity_index = 1:length(PLOT_6_eccentricity_list)
            eccentricity = PLOT_6_eccentricity_list(eccentricity_index);
            % radius = (area/pi)^0.5;
            % bs_func = @(omega) -Energy_S_ecc(csf_elTCSF_model, omega, PLOT_6_luminance, radius,...
            %     optimized_E_thr_s, optimized_beta, eccentricity);
            bs_func = @(omega) - csf_elaTCSF_model.sensitivity(struct('s_frequency', 0, 't_frequency', omega, 'orientation', 0, ...
                    'luminance', PLOT_6_luminance, 'area', area, 'eccentricity', eccentricity));
            CFF_response_6(area_index, eccentricity_index) = binary_search_vec(bs_func, -1, [8 400], 20);
        end
    end
    writematrix(CFF_response_6, 'final_plot_CSF_CFF/CFF_response_6.csv');

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
    writematrix(CFF_response_7, 'final_plot_CSF_CFF/CFF_response_7.csv');

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
    writematrix(CFF_response_8, 'final_plot_CSF_CFF/CFF_response_8.csv');
else
    S_response_1_flat = readmatrix('final_plot_CSF_CFF/S_response_1.csv');
    S_response_1 = reshape(S_response_1_flat, [length(PLOT_1_eccentricity_list), length(PLOT_1_t_frequency_list)]);
    S_response_2_flat = readmatrix('final_plot_CSF_CFF/S_response_2.csv');
    S_response_2 = reshape(S_response_2_flat, [length(PLOT_2_area_list), length(PLOT_2_eccentricity_list)]);
    S_response_3_flat = readmatrix('final_plot_CSF_CFF/S_response_3.csv');
    S_response_3 = reshape(S_response_3_flat, [length(PLOT_3_area_list), length(PLOT_3_luminance_list)]);
    S_response_4_flat = readmatrix('final_plot_CSF_CFF/S_response_4.csv');
    S_response_4 = reshape(S_response_4_flat, [length(PLOT_4_luminance_list), length(PLOT_4_area_list)]);
    CFF_response_5_flat = readmatrix('final_plot_CSF_CFF/CFF_response_5.csv');
    CFF_response_5 = reshape(CFF_response_5_flat, [length(PLOT_5_luminance_list), length(PLOT_5_eccentricity_list)]);
    CFF_response_6_flat = readmatrix('final_plot_CSF_CFF/CFF_response_6.csv');
    CFF_response_6 = reshape(CFF_response_6_flat, [length(PLOT_6_area_list), length(PLOT_6_eccentricity_list)]);
    CFF_response_7_flat = readmatrix('final_plot_CSF_CFF/CFF_response_7.csv');
    CFF_response_7 = reshape(CFF_response_7_flat, [length(PLOT_7_area_list), length(PLOT_7_luminance_list)]);
    CFF_response_8_flat = readmatrix('final_plot_CSF_CFF/CFF_response_8.csv');
    CFF_response_8 = reshape(CFF_response_8_flat, [length(PLOT_8_luminance_list), length(PLOT_8_area_list)]);
end

label_y_place = -.2;
fontsize = 12;
if (plot_figures == 1)
    % ha = tight_subplot(2, 4, [.16 .023],[.07 .04],[.04 .01]);
    ha = tight_subplot(2, 4, [.13 .023],[.1 .04],[.04 .02]);
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
    xlabel( 'Temp. freq. [Hz]', FontSize=fontsize);
    ylabel( 'Sensitivity', FontSize=fontsize);
    ylim([min(S_y_range),max(S_y_range)]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Luminance = ' num2str(PLOT_1_luminance) ' cd/m^2, Area = ' num2str(PLOT_1_area) ' degree^2']);
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
    % ylabel( 'Sensitivity' );
    ylim([min(S_y_range),max(S_y_range)]);
    yticks(S_y_range);
    yticklabels(S_y_range);
    title(['Luminance = ' num2str(PLOT_2_luminance) ' cd/m^2, Temp. freq. = ' num2str(PLOT_2_t_frequency) ' Hz']);
    set(gca, 'YScale', 'log');
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(b)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(3));
    hh = [];
    for area_index = 1:length(PLOT_3_area_list)
        area = PLOT_3_area_list(area_index);
        S_response_3_area = S_response_3(area_index,:);
        hh(end+1) = plot(PLOT_3_luminance_list, S_response_3_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Luminance [cd/m^2]', FontSize=fontsize);
    % ylabel( 'Sensitivity' );
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

    axes(ha(4));
    hh = [];
    for luminance_index = 1:length(PLOT_4_luminance_list)
        luminance = PLOT_4_luminance_list(luminance_index);
        S_response_4_luminance = S_response_4(luminance_index,:);
        hh(end+1) = plot(PLOT_4_area_list, S_response_4_luminance, 'LineWidth', 2, 'DisplayName', ['luminance = ' num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Area [degree^2]', FontSize=fontsize);
    % ylabel( 'Sensitivity' );
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

    axes(ha(5));
    hh = [];
    for luminance_index = 1:length(PLOT_5_luminance_list)
        luminance = PLOT_5_luminance_list(luminance_index);
        CFF_response_5_luminance = CFF_response_5(luminance_index,:);
        hh(end+1) = plot(PLOT_5_eccentricity_list, CFF_response_5_luminance, 'LineWidth', 2, 'DisplayName', ['luminance = ' num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Eccentricity [degree]', FontSize=fontsize);
    ylabel( 'Critical Flicker Frequency [Hz]', FontSize=fontsize);
    ylim([min(CFF_y_range),max(CFF_y_range)]);
    yticks(CFF_y_range);
    yticklabels(CFF_y_range);
    title(['Area = ' num2str(PLOT_5_area) ' degree^2']);
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(e)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(6));
    hh = [];
    for area_index = 1:length(PLOT_6_area_list)
        area = PLOT_6_area_list(area_index);
        CFF_response_6_area = CFF_response_6(area_index,:);
        hh(end+1) = plot(PLOT_6_eccentricity_list, CFF_response_6_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Eccentricity [degree]', FontSize=fontsize);
    % ylabel( 'Critical Flicker Frequency [Hz]' );
    ylim([min(CFF_y_range),max(CFF_y_range)]);
    yticks(CFF_y_range);
    yticklabels(CFF_y_range);
    title(['Luminance = ' num2str(PLOT_6_luminance) ' cd/m^2']);
    legend(hh, 'Location', 'Best');
    grid on;
    text(0.5, label_y_place, '(f)', 'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');

    axes(ha(7));
    hh = [];
    for area_index = 1:length(PLOT_7_area_list)
        area = PLOT_7_area_list(area_index);
        CFF_response_7_area = CFF_response_7(area_index,:);
        hh(end+1) = plot(PLOT_7_luminance_list, CFF_response_7_area, 'LineWidth', 2, 'DisplayName', ['area = ' num2str(area) ' degree^2']);
        hold on;
    end
    xlabel( 'Luminance [cd/m^2]', FontSize=fontsize);
    % ylabel( 'Critical Flicker Frequency [Hz]' );
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

    axes(ha(8));
    hh = [];
    for luminance_index = 1:length(PLOT_8_luminance_list)
        luminance = PLOT_8_luminance_list(luminance_index);
        CFF_response_8_luminance = CFF_response_8(luminance_index,:);
        hh(end+1) = plot(PLOT_8_area_list, CFF_response_8_luminance, 'LineWidth', 2, 'DisplayName', ['luminance = ' num2str(luminance) ' cd/m^2']);
        hold on;
    end
    xlabel( 'Area [degree^2]', FontSize=fontsize);
    % ylabel( 'Critical Flicker Frequency [Hz]' );
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
