function loss_sum = energy_fit_loss_all(csf_model, energy_model, size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub)
    C_thr_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    L_thr_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    loss_all = zeros(length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi)^0.5;
        else
            radius = size_value/2;
            area_value = pi*radius^2;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [L_thr_predict_results_energy_fit(vrr_f_i, size_i),C_thr_predict_results_energy_fit(vrr_f_i, size_i)] = energy_generate_contrast_all(csf_model, energy_model, vrr_f_value, area_value, radius, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub);
            loss = (log10(average_C_t_matrix(vrr_f_i,size_i))-log10(C_thr_predict_results_energy_fit(vrr_f_i,size_i)))^2;
            if (isnan(loss))
                printf('NAN!')
                loss_all(vrr_f_i,size_i) = 10;
            else
                loss_all(vrr_f_i,size_i) = loss;
            end
        end
    end
    loss_sum = sum(loss_all(:));
end

