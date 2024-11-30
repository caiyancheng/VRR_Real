clear all;
clc;

calculate_need = 0;
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
                'luminance', Luminance_value, 'width', width_value, 'height', height_value, 'eccentricity', 0);
            S = csf_elaTCSF_model.sensitivity_rect(csf_pars);
            sensitivity_list(end+1) = S;
            Sensitivity_matrix(t_frequency_index, Luminance_index) = S;
        end
        peak_sensitivity = max(sensitivity_list);
        Peak_sensitivity_matrix(1, Luminance_index) = peak_sensitivity;
    end
    writematrix(Peak_sensitivity_matrix, 'compute_results_web/Peak_sensitivity_matrix_3');
    writematrix(Sensitivity_matrix, 'compute_results_web/Sensitivity_matrix_3');
else
    Peak_sensitivity_matrix_flat = readmatrix('compute_results_web/Peak_sensitivity_matrix_3');
    Peak_sensitivity_matrix = reshape(Peak_sensitivity_matrix_flat, [1, length(Luminance_range)]);
    Sensitivity_matrix_flat = readmatrix('compute_results_web/Sensitivity_matrix_3');
    Sensitivity_matrix = reshape(Sensitivity_matrix_flat, [length(T_frequency_range), length(Luminance_range)]);
end

if generate_json == 1
    jndData = struct();
    num_new_points = 1000;
    X_Luminance_list = Luminance_range;
    X_T_frequency_list = T_frequency_range;

    Y_Sensitivity_list = Peak_sensitivity_matrix;
    Y_Contrast_list = 1./Peak_sensitivity_matrix;
    x_luminance_interp = logspace(min(log10(0.1)), max(log10(1000)), num_new_points);
    y_contrast_interp = interp1(X_Luminance_list, Y_Contrast_list, x_luminance_interp);
    jndData.peak.luminance = x_luminance_interp;
    jndData.peak.contrast = y_contrast_interp;

    % Fit the peak
    initial_params = [600, 1.62402, 0.533781];
    objective_function = @(params) sum((simple_lCSF(X_Luminance_list, params(1), params(2), params(3)) - 1./Y_Contrast_list).^2);
    optimized_params = fminsearch(objective_function, initial_params);
    % optimized_params = initial_params;
    fitted_sensitivity = simple_lCSF(x_luminance_interp, optimized_params(1), optimized_params(2), optimized_params(3));
    fitted_contrast = 1 ./ fitted_sensitivity;

    lCSF_fits = struct();
    lCSF_fits.luminance = x_luminance_interp;
    lCSF_fits.contrast = fitted_contrast;
    lCSF_fits.optimized_params = optimized_params;
    jndData.lCSF_fits = lCSF_fits;

    num_new_points = 100;
    x_luminance_interp = logspace(min(log10(0.1)), max(log10(1000)), num_new_points);
    jndData.each_tf.luminance = x_luminance_interp;
    jndData.each_tf.tf_list = T_frequency_range;

    % Fit for every T_frequency
    % initial_params = [1.768010000000000,1.624020000000000,0.533781000000000,0.222269000000000,0.667800000000000]
    % initial_params = [3.2815 1.661876580455645 0.534514332542537 ...
    %     0.269742781106536 0.901844326781213, 10];
    % initial_params = [3.358111131553590,1.568768030369435,0.538649958888343,0.265304902184621,0.879674661821931,6.880126586923518];
    initial_params = [3.358111131553590,1.568768030369435,0.538649958888343,0.265304902184621,0.879674661821931,1,6.880126586923518];
    X_Luminance_list_fit = zeros(1, length(Luminance_range) * length(T_frequency_range));
    X_T_frequency_list_fit = zeros(1, length(Luminance_range) * length(T_frequency_range));
    Y_Sensitivity_list_fit = zeros(1, length(Luminance_range) * length(T_frequency_range));
    overall_index = 0;
    for t_frequency_index = 1:length(T_frequency_range)
        t_frequency_value = T_frequency_range(t_frequency_index);
        for Luminance_index = 1:length(Luminance_range)
            Luminance_value = Luminance_range(Luminance_index);
            overall_index = overall_index + 1;
            X_Luminance_list_fit(overall_index) = Luminance_value;
            X_T_frequency_list_fit(overall_index) = t_frequency_value;
            Y_Sensitivity_list_fit(overall_index) = Sensitivity_matrix(t_frequency_index,Luminance_index);
        end
    end
    objective_function = @(params) sum((simple_lTCSF(X_Luminance_list_fit, X_T_frequency_list_fit, ...
        params(1), params(2), params(3), params(4), params(5), params(6), params(7)) - Y_Sensitivity_list_fit).^2);
    options = optimset('MaxIter', 10000, 'MaxFunEvals', 10000, 'TolX', 1e-8, 'TolFun', 1e-8);
    optimized_params = fminsearch(objective_function, initial_params, options);
    % optimized_params = initial_params;
    
    for t_frequency_index = 1:length(T_frequency_range)
        t_frequency_value = T_frequency_range(t_frequency_index);
        Y_Contrast_list_tf = 1./Sensitivity_matrix(t_frequency_index,:);
        y_contrast_interp = interp1(X_Luminance_list, Y_Contrast_list_tf, x_luminance_interp);

        fitted_sensitivity = simple_lTCSF(x_luminance_interp, t_frequency_value, optimized_params(1), optimized_params(2), ...
            optimized_params(3), optimized_params(4), optimized_params(5), optimized_params(6), optimized_params(7));
        fitted_contrast = 1 ./ fitted_sensitivity;
        
        % plot(x_luminance_interp, y_contrast_interp);
        % hold on;
        % plot(x_luminance_interp, fitted_contrast);
        % set(gca, 'XScale', 'log');
        % set(gca, 'YScale', 'log');
        % hold off;
        
        
        key_tf = ['tf_index_' num2str(t_frequency_index-1)];
        jndData.each_tf.(key_tf).contrast = y_contrast_interp;
        jndData.each_tf.(key_tf).temporal_frequency = t_frequency_value;
        jndData.each_tf.(key_tf).lCSF_fits.contrast = fitted_contrast;
        jndData.each_tf.(key_tf).lCSF_fits.optimized_params = optimized_params;
    end
    jsonStr = jsonencode(jndData);

    fileID = fopen('web_jndData_3.json', 'w');
    if fileID == -1
        error('无法打开文件进行写入');
    end
    fprintf(fileID, jsonStr);
    fclose(fileID);
end
