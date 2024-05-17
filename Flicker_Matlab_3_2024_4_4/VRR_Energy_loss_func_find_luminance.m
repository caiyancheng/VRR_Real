function loss_sum = VRR_Energy_loss_func_find_luminance(csf_model, size_indices, FRR_indices, average_S_matrix, E_thr, beta, Sensitivity_transform)
S_predict_csf = zeros(length(FRR_indices), length(size_indices));
loss_all = zeros(length(FRR_indices), length(size_indices));
for size_i = 1:length(size_indices)
    size_value = size_indices(size_i);
    if (size_value == -1)
        area_value = 62.666 * 37.808;
        radius = (area_value / pi) ^ 0.5;
    else
        area_value = pi*(size_value./2)^2;
        radius = (area_value / pi) ^ 0.5;
    end
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        % if (size_value == -1) || (size_value == 16)
        %     continue
        % end
        % VRR_Luminance = VRR_Luminance_transform.AT2L(area_value, FRR_value);
        % VRR_Luminance = VRR_Luminance_transform.AT2L_FRR(FRR_value, size_value);
        [L_thr, S_thr_csf, S_thr_transform] = VRR_find_aim_Luminance_flicker(csf_model, FRR_value, radius, E_thr, beta, Sensitivity_transform);
        S_predict_csf(FRR_i, size_i) = S_thr_csf;
        S_gt = average_S_matrix(FRR_i, size_i);
        loss = ((log10(S_thr_csf))-log10(S_gt))^2;
        loss_all(FRR_i, size_i) = loss;
    end
end
loss_sum = sum(loss_all(:));
end

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end