function loss_sum = peak_fit_loss_all_2(csf_model, size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed)
    C_thr_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    L_thr_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    loss_all = zeros(length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi)^0.5;
        else
            area_value = pi*size_value^2;
            radius = size_value;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [L_thr_predict_results_energy_fit(vrr_f_i, size_i), C_thr_predict_results_energy_fit(vrr_f_i, size_i)] = peak_generate_contrast_all_2(csf_model, vrr_f_value, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency, luminance_fixed);
            loss = (log10(average_C_t_matrix(vrr_f_i,size_i))-log10(C_thr_predict_results_energy_fit(vrr_f_i,size_i)))^2;
            if (isnan(loss))
                loss_all(vrr_f_i,size_i) = 10;
            else
                loss_all(vrr_f_i,size_i) = loss;
            end
        end
    end
    loss_sum = sum(loss_all(:));
end

