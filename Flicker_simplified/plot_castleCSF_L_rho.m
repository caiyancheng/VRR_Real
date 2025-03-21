clear all;
clc;

calculate_need = 0;
plot_need = 1;

Luminance_list = logspace(log10(0.1), log10(1000), 20);
rho_list = logspace(log10(0.5), log10(32), 20);
if calculate_need == 1
    castleCSF = CSF_castleCSF();
    Sensitivity_luminance_rho_matrix = zeros(length(Luminance_list), length(rho_list));
    Luminance_surface_matrix = zeros(length(Luminance_list), length(rho_list));
    rho_surface_matrix = zeros(length(Luminance_list), length(rho_list));
    for Luminance_index = 1:length(Luminance_list)
        Luminance_value = Luminance_list(Luminance_index);
        for rho_index = 1:length(rho_list)
            rho_value = rho_list(rho_index);
            Luminance_surface_matrix(Luminance_index, rho_index) = Luminance_value;
            rho_surface_matrix(Luminance_index, rho_index) = rho_value;
            csf_pars = struct('s_frequency', rho_value, 't_frequency', 0, 'orientation', 0, ...
                'luminance', Luminance_value, 'area', 100, 'eccentricity', 0);
            Sensitivity_luminance_rho_matrix(Luminance_index, rho_index) = castleCSF.sensitivity(csf_pars);
        end
    end
    writematrix(Luminance_surface_matrix, 'CVPR_plot/Luminance_surface_matrix');
    writematrix(rho_surface_matrix, 'CVPR_plot/rho_surface_matrix');
    writematrix(Sensitivity_luminance_rho_matrix, 'CVPR_plot/Sensitivity_luminance_rho_matrix');
else
    Luminance_surface_matrix_flat = readmatrix('CVPR_plot/Luminance_surface_matrix');
    Luminance_surface_matrix = reshape(Luminance_surface_matrix_flat, [length(Luminance_list), length(rho_list)]);
    rho_surface_matrix_flat = readmatrix('CVPR_plot/rho_surface_matrix');
    rho_surface_matrix = reshape(rho_surface_matrix_flat, [length(Luminance_list), length(rho_list)]);
    Sensitivity_luminance_rho_matrix_flat = readmatrix('CVPR_plot/Sensitivity_luminance_rho_matrix');
    Sensitivity_luminance_rho_matrix = reshape(Sensitivity_luminance_rho_matrix_flat, [length(Luminance_list), length(rho_list)]);
end


if plot_need == 1
    ha = tight_subplot(1, 1, [.13 .09],[.16 .02],[.12 .06]);
    set(gcf, 'Position', [100, 100, 600, 400]);
    X_luminance_ticks = [0.1, 1, 10, 100, 1000];
    sensitivity_ticks = [-2,-1,0,1,2,3];
    sensitivity_ticks_labels = [0.01,0.1,1,10,100,1000];
    axes(ha(1));
    surf(Luminance_surface_matrix, rho_surface_matrix, log10(Sensitivity_luminance_rho_matrix), 'EdgeColor','none', 'FaceAlpha', 1);
    hold on;
    colormap(flipud(hsv));
    xlabel('Luminance (cd/m^2)', FontSize=14);
    ylabel('Spatial Frequency (cpd)', FontSize=14);
    zlabel('Sensitivity', FontSize=14);
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    xticks(X_luminance_ticks);
    xticklabels(X_luminance_ticks);
    yticks([0.5,1,2,4,8,16,32]);
    yticklabels([0.5,1,2,4,8,16,32]);
    zticks(sensitivity_ticks);
    zticklabels(sensitivity_ticks_labels);
    zlim([min(sensitivity_ticks),max(sensitivity_ticks)]);
    axis off;
    view(235, 15);

end