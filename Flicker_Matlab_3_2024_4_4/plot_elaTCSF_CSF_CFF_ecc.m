clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

compute_values = 0;
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

% 固定Luminance求不同Area下CFF和Eccentricity的关系
PLOT_6_eccentricity_list = linspace(0,60,60);
PLOT_6_luminance = 1;
PLOT_6_area_list = [0.1,1,10,100];

S_response_1_flat = readmatrix('final_plot_CSF_CFF/S_response_1.csv');
S_response_1 = reshape(S_response_1_flat, [length(PLOT_1_eccentricity_list), length(PLOT_1_t_frequency_list)]);
S_response_2_flat = readmatrix('final_plot_CSF_CFF/S_response_2.csv');
S_response_2 = reshape(S_response_2_flat, [length(PLOT_2_area_list), length(PLOT_2_eccentricity_list)]);
CFF_response_6_flat = readmatrix('final_plot_CSF_CFF/CFF_response_6.csv');
CFF_response_6 = reshape(CFF_response_6_flat, [length(PLOT_6_area_list), length(PLOT_6_eccentricity_list)]);

label_y_place = -.2;
fontsize = 12;
if (plot_figures == 1)
    figure('Position', [100, 100, 1200, 400]);
    ha = tight_subplot(1, 3, [.16 .04],[.12 .06],[.05 .01]);
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
end
