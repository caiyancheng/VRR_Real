function [L_thr, S_thr_csf, S_thr_transform] = VRR_find_aim_Luminance(csf_model, t_frequency, radius, k_scale, Sensitivity_transform)
Luminance_lb = 0.5;
Luminance_ub = 8;
area = pi .* radius .^ 2;

% Luminance_range = linspace(0.5,10,100)';
% Sensitivity_Value_1 = @(L_thr) Sensitivity_transform.LT2S(L_thr, t_frequency);
% Sensitivity_Value_2 = @(L_thr) S_CSF(csf_model, 0, t_frequency, L_thr, area, 0);
% Sensitivity_Value_1_L = zeros(length(Luminance_range),1);
% for index = 1:length(Luminance_range)
%     Sensitivity_Value_1_L(index) = Sensitivity_Value_1(Luminance_range(index));
% end
% Sensitivity_Value_2_L = Sensitivity_Value_2(Luminance_range) / k_scale;
% plot(Luminance_range, Sensitivity_Value_1_L, 'r');
% hold on;
% plot(Luminance_range, Sensitivity_Value_2_L, 'b');

bs_func = @(L_thr) (Sensitivity_transform.LT2S(L_thr, t_frequency) - S_CSF(csf_model, 0, t_frequency, L_thr, area, 0)/k_scale);
L_thr = binary_search_vec(bs_func, 0, [Luminance_lb Luminance_ub], 20);
S_thr_transform = Sensitivity_transform.LT2S(L_thr, t_frequency);
S_thr_csf = S_CSF(csf_model, 0, t_frequency, L_thr, area, 0) ./ k_scale;
end

function value = S_CSF(csf_model, s_frequency, t_frequency, luminance, area, eccentricity)
csf_pars = struct('s_frequency', s_frequency, 't_frequency', t_frequency, 'orientation', 0, ...
    'luminance', luminance, 'area', area, 'eccentricity', eccentricity);
value = csf_model.sensitivity(csf_pars);
end