function loss_sum = simple_fit_loss_all(csf_model_use, size_indices, vrr_f_indices, average_C_t_matrix,  k_scale_value, s_frequency_value, fit_poly_degree, Luminance_lb, Luminance_ub)
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
        [L_thr_predict_results_energy_fit(vrr_f_i, size_i), C_thr_predict_results_energy_fit(vrr_f_i, size_i)] = simple_generate_contrast_all(csf_model_use, area_value, vrr_f_value, k_scale_value, s_frequency_value, fit_poly_degree, Luminance_lb, Luminance_ub);
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

