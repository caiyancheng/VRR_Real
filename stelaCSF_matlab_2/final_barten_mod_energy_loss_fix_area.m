function loss_sum = final_barten_mod_energy_loss_fix_area(size_indices, vrr_f_indices, average_C_t_matrix, E_thr_value, fit_poly_degree, area_fix, Luminance_lb, Luminance_ub)
    C_t_predict_results_energy_fit = zeros(length(vrr_f_indices), length(size_indices));
    loss_all = zeros(length(vrr_f_indices), length(size_indices));
    for size_i = 1:length(size_indices)
        size_value = size_indices(size_i);
        if (size_value == -1)
            radius = (37.808+62.666)/4;
        else
            radius = size_value/2;
        end
        for vrr_f_i = 1:length(vrr_f_indices)
            vrr_f_value = vrr_f_indices(vrr_f_i);
            [~,C_t_predict_results_energy_fit(vrr_f_i, size_i)] = final_contrast_energy_model_barten_mod(vrr_f_value, area_fix, radius, E_thr_value, fit_poly_degree, Luminance_lb, Luminance_ub);
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

function [L_thr_barten_mod, C_t_barten_mod] = final_contrast_energy_model_barten_mod(t_frequency, area_value, radius, E_thr, fit_poly_degree, Luminance_lb, Luminance_ub) 
    delta_rho = 0.01;  % Width of each small interval
    num_rho_points = 5000;
    initial_L_thr = 3;
    rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';  % Transpose to make it a column vector
    integrand_barten_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_barten_mod(rho, L_thr, area_value, t_frequency)).^2) .* rho;
    E_barten_mod = @(L_thr) delta_rho * sum(integrand_barten_mod(rho_sum, L_thr));
    options = optimset('Display', 'off');
    fun_barten_mod = @(L_thr) abs(E_barten_mod(L_thr) - E_thr);
    [L_thr_barten_mod, min_difference_barten_mod] = fmincon(fun_barten_mod, initial_L_thr, [], [], [], [], Luminance_lb, Luminance_ub, [], options);
    C_t_barten_mod = get_contrast_from_Luminance(L_thr_barten_mod, fit_poly_degree, radius);
end

function value = S_barten_mod(rho, L_b, area_value, t_frequency)
    barten_mod_model = CSF_stmBartenVeridical();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = barten_mod_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end