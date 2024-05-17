function loss_sum = VRR_CSF_loss_func(csf_model, size_indices, FRR_indices, average_S_matrix, k_scale, Sensitivity_transform)
    S_predict_csf = zeros(length(FRR_indices), length(size_indices));
    loss_all = zeros(length(FRR_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            area_value = 62.666 * 37.808;
            radius = (area_value/pi).^0.5;
        else
            area_value = pi*(size_value./2)^2;
            radius = size_value./2;
        end
        for FRR_i = 1:length(FRR_indices)
            FRR_value = FRR_indices(FRR_i);
            [L_thr, S_thr_csf, S_thr_transform] = VRR_find_aim_Luminance(csf_model, FRR_value, radius, k_scale, Sensitivity_transform);
            S_predict_csf(FRR_i, size_i) = S_thr_csf;
            loss = ((log10(S_thr_csf))-log10(average_S_matrix(FRR_i, size_i)))^2;
            loss_all(FRR_i, size_i) = loss;
        end
    end
    loss_sum = sum(loss_all(:));
end