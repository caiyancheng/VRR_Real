function loss_sum = VRR_TCSF_5_loss_function(size_indices, FRR_indices, average_S_matrix, params)
params = exp(params);
S_predict_csf = zeros(length(FRR_indices), length(size_indices));
loss_all = zeros(length(FRR_indices), length(size_indices));
for size_i = 1:length(size_indices)
    if (size_i ~= 1) && (size_i ~= 2)
        continue
    end
    for FRR_i = 1:length(FRR_indices)
        FRR_value = FRR_indices(FRR_i);
        % if FRR_value == 0.5
        %     continue
        % end
        % VRR_Luminance = VRR_Luminance_transform.AT2L_FRR(FRR_value, size_value);
        S_thr_csf = S_TCSF_5(params(1:6), FRR_value);
        S_predict_csf(FRR_i, size_i) = S_thr_csf;
        S_gt = average_S_matrix(FRR_i, size_i);
        loss = ((log10(S_thr_csf))-log10(S_gt))^2;
        loss_all(FRR_i, size_i) = loss;
    end
end
loss_sum = sum(loss_all(:));
end