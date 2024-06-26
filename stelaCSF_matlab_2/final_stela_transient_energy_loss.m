function loss_sum = final_stela_transient_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub)
    C_t_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    loss_all = zeros(length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (37.808+62.666)/4;
        else
            radius = size_value/2;
            area_value = pi*radius^2;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [~,C_t_predict_results_energy_fit(vrr_f_i, size_i)] = final_contrast_energy_model_stela(vrr_f_value, area_value, radius, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub);
            loss = (log10(average_C_t_matrix(vrr_f_i,size_i))-log10(C_t_predict_results_energy_fit(vrr_f_i,size_i)))^2;
            if (isnan(loss))
                loss_all(vrr_f_i,size_i) = 10;
            else
                loss_all(vrr_f_i,size_i) = loss;
            end
        end
    end
    loss_sum = sum(loss_all(:));
end

function [L_thr_stela, C_t_stela] = final_contrast_energy_model_stela(t_frequency, area_value, radius, E_thr, fit_poly_degree, Luminance_lb, Luminance_ub) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    initial_L_thr = 3;
    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_transient(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_stela = @(L_thr) delta_rho * sum(integrand_stela(rho_sum, L_thr));
    options = optimset('Display', 'off');
    fun_stela = @(L_thr) abs(E_stela(L_thr) - E_thr);
    [L_thr_stela, min_difference_stela] = fmincon(fun_stela, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_stela = get_contrast_from_Luminance(L_thr_stela, fit_poly_degree, radius);
end

function value = S_stela_transient(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end