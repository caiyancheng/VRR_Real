function loss_sum = final_stela_mod_transient_peak_loss(size_indices, vrr_f_indices, average_C_t_matrix, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency)
    C_t_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    loss_all = zeros(length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (62.666+37.808)/4;
        else
            area_value = pi*size_value^2;
            radius = size_value;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [~,C_t_predict_results_energy_fit(vrr_f_i, size_i)] = final_peak_stela_mod_transient(vrr_f_value, area_value, radius, k_scale, fit_poly_degree, Luminance_lb, Luminance_ub, peak_spatial_frequency);
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

