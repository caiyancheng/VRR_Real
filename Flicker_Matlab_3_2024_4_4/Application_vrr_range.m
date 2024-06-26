clear all;
clc;

degree_C2L = 7;
degree_L2C = 7;
CL_transform = Color2Luminance_LG_G1(degree_C2L, degree_L2C);
Sensitivity_transform = Luminance_VRR_2_Sensitivity();
VRR_Luminance_transform = Area_FRR_2_VRR_dataset_Luminance();

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

calculate_need = 0;
plot_need = 1;

Luminance_range = logspace(log10(0.1),log10(1000),20);
T_frequency_range = linspace(0,20,50);
Area = 62.7 * 37.8;
Peak_sensitivity_list = [];

if calculate_need == 1
    for Luminance_index = 1:length(Luminance_range)
        Luminance_value = Luminance_range(Luminance_index);
        sensitivity_list = [];
        for t_frequency_index = 1:length(T_frequency_range)
            t_frequency_value = T_frequency_range(t_frequency_index);
            csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency_value, 'orientation', 0, ...
                'luminance', Luminance_value, 'area', Area, 'eccentricity', 0);
            S = csf_elaTCSF_model.sensitivity(csf_pars);
            sensitivity_list(end+1) = S;
        end
        peak_sensitivity = max(sensitivity_list);
        Peak_sensitivity_list(end+1) = peak_sensitivity;
        writematrix(Peak_sensitivity_list, 'application_vrr_range/Peak_sensitivity_list.csv');
    end
else
    Peak_sensitivity_list = readmatrix('application_vrr_range/Peak_sensitivity_list.csv');
end

ha = tight_subplot(1, 2, [.13 .05],[.12 .07],[.08 .03]);
axes(ha(1));
Sensitivity_Ticks = [10,100,1000];
plot(Luminance_range, Peak_sensitivity_list);
xlabel('Luminance (cd/m^2)');
ylabel('Peak Sensitivity (across all temporal frequencies)');
set(gca, 'XScale', 'log', 'XTick', [0.1, 1, 10, 100, 1000], 'XTickLabel', [0.1, 1, 10, 100, 1000]);
set(gca, 'YScale', 'log', 'YTick', Sensitivity_Ticks, 'YTickLabel', Sensitivity_Ticks);
ylim([min(Sensitivity_Ticks),max(Sensitivity_Ticks)]);
xlim([0.1,1000]);

axes(ha(2));
Contrast_Ticks = [0.001,0.01,0.1];
plot(Luminance_range, 1 ./ Peak_sensitivity_list);
xlabel('Luminance (cd/m^2)');
ylabel('Corresponding Contrast');
set(gca, 'XScale', 'log', 'XTick', [0.1, 1, 10, 100, 1000], 'XTickLabel', [0.1, 1, 10, 100, 1000]);
set(gca, 'YScale', 'log', 'YTick', Contrast_Ticks, 'YTickLabel', Contrast_Ticks);
ylim([min(Contrast_Ticks),max(Contrast_Ticks)]);
xlim([0.1,1000]);