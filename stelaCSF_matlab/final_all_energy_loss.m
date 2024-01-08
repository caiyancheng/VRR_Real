function loss_sum = final_all_energy_loss(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix)
    CSF_results_energy_fit = zeros(10, length(vrr_f_indices), length(size_indices));
    loss_all = zeros(10, length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (37.808+62.666)/2;
        else
            area_value = pi*size_value^2;
            radius = size_value;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [~,~,~,CSF_results_energy_fit(1,vrr_f_i,size_i), CSF_results_energy_fit(2,vrr_f_i,size_i), CSF_results_energy_fit(3,vrr_f_i,size_i)] = ...
                final_contrast_energy_model(vrr_f_value, area_value, radius, E_thr_value(1:3), fit_poly_degree);
            [~,~,CSF_results_energy_fit(4,vrr_f_i,size_i), CSF_results_energy_fit(5,vrr_f_i,size_i)] = ...
                final_contrast_energy_model_transient(vrr_f_value, area_value, radius, E_thr_value(4:5), fit_poly_degree);
            [~,~,~,CSF_results_energy_fit(6,vrr_f_i,size_i), CSF_results_energy_fit(7,vrr_f_i,size_i), CSF_results_energy_fit(8,vrr_f_i,size_i)] = ...
                final_contrast_energy_model_fix_area(vrr_f_value, radius, E_thr_value(6:8), fit_poly_degree, area_fix);
            [~,~,CSF_results_energy_fit(9,vrr_f_i,size_i), CSF_results_energy_fit(10,vrr_f_i,size_i)] = ...
                final_contrast_energy_model_transient_fix_area(vrr_f_value, radius, E_thr_value(9:10), fit_poly_degree, area_fix);
            for model_i = 1:10
                loss_all(model_i,vrr_f_i,size_i) = abs(log10(average_C_t_matrix(vrr_f_i,size_i))-log10(CSF_results_energy_fit(model_i,vrr_f_i,size_i)));
            end
        end
    end
    loss_sum = nansum(loss_all(:));
end