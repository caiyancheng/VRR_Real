size = 16;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 5;
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);
delta_rho = 0.01;
num_rho_points = 5000;
rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';
E_stela_all = zeros(1,length(vrr_f_contiuous));
E_stela_mod_all = zeros(1,length(vrr_f_contiuous));
E_barten_mod_all = zeros(1,length(vrr_f_contiuous));
E_stela_transient_all = zeros(1,length(vrr_f_contiuous));
E_stela_mod_transient_all = zeros(1,length(vrr_f_contiuous));

for vrr_f_index = 1:length(vrr_f_contiuous)
    vrr_f_value = vrr_f_contiuous(vrr_f_index);

    integrand_stela = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stela = delta_rho * sum(integrand_stela(rho_sum, luminance_value));
    E_stela_all(vrr_f_index) = E_stela;

    integrand_stela_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stela_mod = delta_rho * sum(integrand_stela_mod(rho_sum, luminance_value));
    E_stela_mod_all(vrr_f_index) = E_stela_mod;

    integrand_barten_mod = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_barten_mod(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_barten_mod = delta_rho * sum(integrand_barten_mod(rho_sum, luminance_value));
    E_barten_mod_all(vrr_f_index) = E_barten_mod;

    integrand_stela_transient = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_transient(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stela_transient = delta_rho * sum(integrand_stela_transient(rho_sum, luminance_value));
    E_stela_transient_all(vrr_f_index) = E_stela_transient;

    integrand_stela_mod_transient = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stela_mod_transient(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stela_mod_transient = delta_rho * sum(integrand_stela_mod_transient(rho_sum, luminance_value));
    E_stela_mod_transient_all(vrr_f_index) = E_stela_mod_transient;
end

figure;
plot(vrr_f_contiuous, E_stela_all, 'DisplayName', 'stelaCSF');
hold on;
plot(vrr_f_contiuous, E_stela_mod_all, 'DisplayName', 'stelaCSF_{HF}');
plot(vrr_f_contiuous, E_barten_mod_all, 'DisplayName', 'BartenCSF_{HF}');
plot(vrr_f_contiuous, E_stela_transient_all, 'DisplayName', 'stelaCSF transient');
plot(vrr_f_contiuous, E_stela_mod_transient_all, 'DisplayName', 'stelaCSF_{HF} transient');
xlim([0.1,20]);
legend('show');

function value = S_stela(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function value = S_stela_mod(rho, L_b, area_value, t_frequency)
    stelacsf_mod_model = CSF_stelaCSF_mod();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_mod_model.sensitivity(csf_pars);
end

function value = S_barten_mod(rho, L_b, area_value, t_frequency)
    barten_mod_model = CSF_stmBartenVeridical();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = barten_mod_model.sensitivity(csf_pars);
end

function value = S_stela_transient(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function value = S_stela_mod_transient(rho, L_b, area_value, t_frequency)
    stelacsf_model = CSF_stelaCSF_mod_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelacsf_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end