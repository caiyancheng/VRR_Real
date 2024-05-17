function loss_sum = VRR_general_loss_func(csf_model, size_indices, FRR_indices, average_S_matrix, VRR_Luminance_transform, k_scale)
S_predict_csf = zeros(length(FRR_indices), length(size_indices));
loss_all = zeros(length(FRR_indices), length(size_indices));
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        % radius = (area_value / pi) ^ 0.5;
    else
        area_value = pi*(size_value./2)^2;
        % radius = (area_value / pi) ^ 0.5;
    end
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        VRR_Luminance = VRR_Luminance_transform.AT2L_FRR(FRR_value, size_value);
        csf_pars = struct('s_frequency', 0, 't_frequency', FRR_value, 'orientation', 0, ...
            'luminance', VRR_Luminance, 'area', area_value, 'eccentricity', 0);
        S_thr_csf = csf_model.sensitivity(csf_pars) ./ k_scale;
        S_predict_csf(FRR_i, size_i) = S_thr_csf;
        S_gt = average_S_matrix(FRR_i, size_i);
        loss = ((log10(S_thr_csf))-log10(S_gt))^2;
        loss_all(FRR_i, size_i) = loss;
    end
end
loss_sum = sum(loss_all(:));