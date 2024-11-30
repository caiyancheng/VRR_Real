clear all;
clc;

calculate_need = 1;
generate_json = 1;

%先生成Luminance为横轴的图，我们生成不同t_f下的值
Luminance_range = logspace(log10(0.1), log10(1000), 100);
T_frequency_range = logspace(log10(1), log10(16), 100);
width_value = 2*atan(3840/2160/3.2)/pi*180; %58.1
height_value = 2*atan(1/3.2)/pi*180; %34.7

if calculate_need == 1
    csf_elaTCSF_model = CSF_elaTCSF_16_TCSF_free();

    Peak_sensitivity_matrix = zeros(1,length(Luminance_range));
    Sensitivity_matrix = zeros(length(T_frequency_range), length(Luminance_range));
    for Luminance_index = 1:length(Luminance_range)
        Luminance_value = Luminance_range(Luminance_index);
        area_value = width_value * height_value;
        sensitivity_list = [];
        for t_frequency_index = 1:length(T_frequency_range)
            t_frequency_value = T_frequency_range(t_frequency_index);
            csf_pars = struct('s_frequency', 0, 't_frequency', t_frequency_value, 'orientation', 0, ...
                'luminance', Luminance_value, 'area', area_value, ...
                'width', width_value, 'height', height_value, 'eccentricity', 0);
            S = csf_elaTCSF_model.sensitivity_rect(csf_pars);
            sensitivity_list(end+1) = S;
            Sensitivity_matrix(t_frequency_index, Luminance_index) = S;
        end
        peak_sensitivity = max(sensitivity_list);
        Peak_sensitivity_matrix(1, Luminance_index) = peak_sensitivity;
    end
    writematrix(Peak_sensitivity_matrix, 'compute_results_web/Peak_sensitivity_matrix');
    writematrix(Sensitivity_matrix, 'compute_results_web/Sensitivity_matrix');
else
    Peak_sensitivity_matrix_flat = readmatrix('compute_results_web/Peak_sensitivity_matrix');
    Peak_sensitivity_matrix = reshape(Peak_sensitivity_matrix_flat, [1, length(Luminance_range)]);
    Sensitivity_matrix_flat = readmatrix('compute_results_web/Sensitivity_matrix');
    Sensitivity_matrix = reshape(Sensitivity_matrix_flat, [length(T_frequency_range), length(Luminance_range)]);
end

if generate_json == 1
    jndData = struct();
    num_new_points = 1000;
    X_Luminance_list = Luminance_range;
    Y_Contrast_list = 1./Peak_sensitivity_matrix;
    x_luminance_interp = logspace(min(log10(0.1)), max(log10(1000)), num_new_points);
    y_contrast_interp = interp1(X_Luminance_list, Y_Contrast_list, x_luminance_interp);
    jndData.peak.luminance = x_luminance_interp;
    jndData.peak.contrast = y_contrast_interp;

    % 多项式拟合结果
    polynomial_fits = struct();
    for degree = 1:7
        p = polyfit(log10(X_Luminance_list), log10(Y_Contrast_list), degree);
        y_poly_fit = polyval(p, log10(X_Luminance_list));
        polynomial_fits.(['degree_' num2str(degree)]).luminance = X_Luminance_list;
        polynomial_fits.(['degree_' num2str(degree)]).contrast = 10.^y_poly_fit;
        polynomial_fits.(['degree_' num2str(degree)]).coefficients = p;
        formula_str = "log10(contrast) = ";
        for i = 1:length(p)
            if i == 1
                term = sprintf("%.4f * log10(luminance)^%d", p(i), degree+1-i);
            else
                term = sprintf(" + %.4f * log10(luminance)^%d", p(i), degree+1-i);
            end
            formula_str = strcat(formula_str, term);
        end
        polynomial_fits.(['degree_' num2str(degree)]).formula = formula_str;
    end
    jndData.polynomial_fits_plot = polynomial_fits;

    num_new_points = 100;
    x_luminance_interp = logspace(min(log10(0.1)), max(log10(1000)), num_new_points);
    jndData.each_tf.luminance = x_luminance_interp;
    jndData.each_tf.tf_list = T_frequency_range;
    for t_frequency_index = 1:length(T_frequency_range)
        t_frequency_value = T_frequency_range(t_frequency_index);
        Y_Contrast_list_tf = 1./Sensitivity_matrix(t_frequency_index,:);
        y_contrast_interp = interp1(X_Luminance_list, Y_Contrast_list_tf, x_luminance_interp);
        key_tf = ['tf_index_' num2str(t_frequency_index-1)];
        jndData.each_tf.(key_tf).contrast = y_contrast_interp;
        jndData.each_tf.(key_tf).temporal_frequency = t_frequency_value;
    end
    jsonStr = jsonencode(jndData);

    fileID = fopen('web_jndData.json', 'w');
    if fileID == -1
        error('无法打开文件进行写入');
    end
    fprintf(fileID, jsonStr);
    fclose(fileID);
end

