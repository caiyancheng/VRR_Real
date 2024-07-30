clear all;
clc;
generate_result = 0;
plot_surface = 1;
num_samples = 30;

csf_model = CSF_castleCSF();

default_spatial_frequency = 4;
default_temporal_frequency = 4;
default_luminance = 10;
default_eccentricity = 0;
default_area = 100;

parameters_data = struct();
parameters_data.spatial_frequency_list = logspace(log10(0.1),log10(100),num_samples);
parameters_data.temporal_frequency_list = logspace(log10(0.1),log10(100),num_samples);
parameters_data.luminance_list = logspace(log10(0.1),log10(10000),num_samples);
parameters_data.eccentricity_list = linspace(0,60,num_samples);
parameters_data.area_list = logspace(log10(0.1),log10(1000),num_samples);

parameters_cell = {'spatial_frequency', 'temporal_frequency', 'luminance', 'eccentricity', 'area'};
parameters_Label_name = {'Spatial Frequency (cpd)', 'Temporal Frequency (Hz)', 'Luminance (cd/m^2)', ...
    'Eccentricity (degree)', 'Area (degree^2)'};
parameters_Logscale = [1, 1, 1, 0, 1];

n_parameter = numel(parameters_cell);
n_combinations = n_parameter*(n_parameter-1)/2;
sensitivity_overall_matrix = NaN(n_combinations, num_samples, num_samples);
x_surface_overall_matrix = NaN(n_combinations, num_samples, num_samples);
y_surface_overall_matrix = NaN(n_combinations, num_samples, num_samples);
combinations_all_name = {};
combinations_index = {};

for i = 1:n_parameter-1
    for j = i+1:n_parameter
        combinations_all_name{end+1} = {parameters_cell{i}, parameters_cell{j}};
        combinations_index{end+1} = {i, j};
    end
end

if (generate_result == 1)
    for combination_index = 1:length(combinations_all_name)
        combination_param_1_name = combinations_all_name{combination_index}{1};
        combination_param_2_name = combinations_all_name{combination_index}{2};
        param_i = combinations_index{combination_index}{1};
        param_j = combinations_index{combination_index}{2};
        param_1_list = parameters_data.([combination_param_1_name '_list']);
        param_2_list = parameters_data.([combination_param_2_name '_list']);
        for param_1_index = 1:num_samples
            param_1_value = param_1_list(param_1_index);
            for param_2_index = 1:num_samples
                param_2_value = param_2_list(param_2_index);
                param_input = [default_spatial_frequency, default_temporal_frequency, default_luminance, ...
                    default_eccentricity, default_area];
                param_input(param_i) = param_1_value;
                param_input(param_j) = param_2_value;
                csf_pars = struct('s_frequency', param_input(1), 't_frequency', param_input(2), 'orientation', 0, ...
                    'luminance', param_input(3), 'eccentricity', param_input(4), 'area', param_input(5));
                sensitivity = csf_model.sensitivity(csf_pars);
                if sensitivity < 0.01
                    sensitivity = NaN;
                end
                sensitivity_overall_matrix(combination_index, param_1_index, param_2_index) = sensitivity;
                x_surface_overall_matrix(combination_index, param_1_index, param_2_index) = param_1_value;
                y_surface_overall_matrix(combination_index, param_1_index, param_2_index) = param_2_value;
            end
        end
    end
    writematrix(sensitivity_overall_matrix, 'castleCSF_plot/sensitivity_overall_matrix');
    writematrix(x_surface_overall_matrix, 'castleCSF_plot/x_surface_overall_matrix');
    writematrix(y_surface_overall_matrix, 'castleCSF_plot/y_surface_overall_matrix');
else
    sensitivity_overall_matrix_flat = readmatrix('castleCSF_plot/sensitivity_overall_matrix');
    sensitivity_overall_matrix = reshape(sensitivity_overall_matrix_flat, [n_combinations, num_samples, num_samples]);
    x_surface_overall_matrix_flat = readmatrix('castleCSF_plot/x_surface_overall_matrix');
    x_surface_overall_matrix = reshape(x_surface_overall_matrix_flat, [n_combinations, num_samples, num_samples]);
    y_surface_overall_matrix_flat = readmatrix('castleCSF_plot/y_surface_overall_matrix');
    y_surface_overall_matrix = reshape(y_surface_overall_matrix_flat, [n_combinations, num_samples, num_samples]);
end


if plot_surface == 1
    ha = tight_subplot(5, 2, [.04 .1],[.04 .001],[.07 .05]);
    sensitivity_ticks = [0,1,2,3];
    sensitivity_ticks_labels = [1,10,100,1000];
    for combination_index = 1:length(combinations_all_name)
        combination_param_1_name = combinations_all_name{combination_index}{1};
        combination_param_2_name = combinations_all_name{combination_index}{2};
        param_i = combinations_index{combination_index}{1};
        param_j = combinations_index{combination_index}{2};
        param_1_list = parameters_data.([combination_param_1_name '_list']);
        param_2_list = parameters_data.([combination_param_2_name '_list']);

        axes(ha(combination_index));
        sensitivity_surface_value = squeeze(sensitivity_overall_matrix(combination_index, :, :));
        x_surface_value = squeeze(x_surface_overall_matrix(combination_index, :, :));
        y_surface_value = squeeze(y_surface_overall_matrix(combination_index, :, :));
        hh = surf(x_surface_value, y_surface_value, log10(sensitivity_surface_value), 'EdgeColor','k');
        hold on;
        colormap(flipud(hsv));
        xlabel(parameters_Label_name{param_i});
        ylabel(parameters_Label_name{param_j});
        zlabel('Sensitivity', FontSize=12);
        if parameters_Logscale(param_i) == 1
            set(gca, 'XScale', 'log');
            xticks([0.1,1,10,100,1000]);
            xticklabels([0.1,1,10,100,1000]);
        end
        if parameters_Logscale(param_j) == 1
            set(gca, 'YScale', 'log');
            yticks([0.1,1,10,100,1000]);
            yticklabels([0.1,1,10,100,1000]);
        end
        
        zticks(sensitivity_ticks);
        zticklabels(sensitivity_ticks_labels);
        zlim([min(sensitivity_ticks),max(sensitivity_ticks)]);
        xlim([min(param_1_list),max(param_1_list)]);
        ylim([min(param_2_list),max(param_2_list)]);
        view(45, 15);
    end
end

