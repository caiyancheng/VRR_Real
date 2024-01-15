size = 0.5;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 5;
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);
delta_rho = 0.01;
num_rho_points = 10000;
rho_sum = linspace(0, num_rho_points * delta_rho, num_rho_points)';
E_stelaCSF_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_HF_all = zeros(1,length(vrr_f_contiuous));
E_Barten_HF_all = zeros(1,length(vrr_f_contiuous));
E_Barten_Original_all = zeros(1,length(vrr_f_contiuous));
E_castleCSF_all = zeros(1,length(vrr_f_contiuous));
E_A_Daly_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_transient_all = zeros(1,length(vrr_f_contiuous));
E_stelaCSF_HF_transient_all = zeros(1,length(vrr_f_contiuous));

for vrr_f_index = 1:length(vrr_f_contiuous)
    vrr_f_value = vrr_f_contiuous(vrr_f_index);

    integrand_stelaCSF = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stelaCSF(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stelaCSF = delta_rho * sum(integrand_stelaCSF(rho_sum, luminance_value));
    E_stelaCSF_all(vrr_f_index) = E_stelaCSF;

    integrand_stelaCSF_HF = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stelaCSF_HF(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stelaCSF_HF = delta_rho * sum(integrand_stelaCSF_HF(rho_sum, luminance_value));
    E_stelaCSF_HF_all(vrr_f_index) = E_stelaCSF_HF;

    integrand_Barten_HF = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_Barten_HF(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_Barten_HF = delta_rho * sum(integrand_Barten_HF(rho_sum, luminance_value));
    E_Barten_HF_all(vrr_f_index) = E_Barten_HF;

    integrand_Barten_Original = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_Barten_Original(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_Barten_Original = delta_rho * sum(integrand_Barten_Original(rho_sum, luminance_value));
    E_Barten_Original_all(vrr_f_index) = E_Barten_Original;

    integrand_castleCSF = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_castleCSF(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_castleCSF = delta_rho * sum(integrand_castleCSF(rho_sum, luminance_value));
    E_castleCSF_all(vrr_f_index) = E_castleCSF;

    % integrand_A_Daly = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_A_Daly(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    % E_A_Daly = delta_rho * sum(integrand_A_Daly(rho_sum, luminance_value));
    % E_A_Daly_all(vrr_f_index) = E_A_Daly;

    integrand_stelaCSF_transient = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stelaCSF_transient(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stelaCSF_transient = delta_rho * sum(integrand_stelaCSF_transient(rho_sum, luminance_value));
    E_stelaCSF_transient_all(vrr_f_index) = E_stelaCSF_transient;

    integrand_stelaCSF_HF_transient = @(rho, L_thr) 2 * pi * get_contrast_from_Luminance(L_thr, fit_poly_degree, radius)^2 * ((D(rho, radius) .* S_stelaCSF_HF_transient(rho, L_thr, area_value, vrr_f_value)).^2) .* rho;
    E_stelaCSF_HF_transient = delta_rho * sum(integrand_stelaCSF_HF_transient(rho_sum, luminance_value));
    E_stelaCSF_HF_transient_all(vrr_f_index) = E_stelaCSF_HF_transient;
end

figure;
plot(vrr_f_contiuous, E_stelaCSF_all, 'DisplayName', 'stelaCSF');
hold on;
plot(vrr_f_contiuous, E_stelaCSF_HF_all, 'DisplayName', 'stelaCSF_{HF}');
plot(vrr_f_contiuous, E_Barten_HF_all, 'DisplayName', 'BartenCSF_{HF}');
plot(vrr_f_contiuous, E_Barten_Original_all, 'DisplayName', 'BartenCSF_{Original}');
plot(vrr_f_contiuous, E_castleCSF_all, 'DisplayName', 'castleCSF');
% plot(vrr_f_contiuous, E_A_Daly_all, 'DisplayName', 'DalyCSF');
plot(vrr_f_contiuous, E_stelaCSF_transient_all, 'DisplayName', 'stelaCSF transient');
plot(vrr_f_contiuous, E_stelaCSF_HF_transient_all, 'DisplayName', 'stelaCSF_{HF} transient');
xlabel('Frequency of RR Switch (Hz)');
ylabel('Energy')
title('16 degree diameter, 1 cd/m^2');
xlim([0.1,20]);
legend('show');

function value = S_stelaCSF(rho, L_b, area_value, t_frequency)
    stelaCSF_model = CSF_stelaCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelaCSF_model.sensitivity(csf_pars);
end

function value = S_stelaCSF_HF(rho, L_b, area_value, t_frequency)
    stelaCSF_HF_model = CSF_stelaCSF_HF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelaCSF_HF_model.sensitivity(csf_pars);
end

function value = S_Barten_HF(rho, L_b, area_value, t_frequency)
    Barten_HF_model = CSF_Barten_HF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = Barten_HF_model.sensitivity(csf_pars);
end

function value = S_Barten_Original(rho, L_b, area_value, t_frequency)
    Barten_Original_model = CSF_Barten_Original();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = Barten_Original_model.sensitivity(csf_pars);
end

function value = S_castleCSF(rho, L_b, area_value, t_frequency)
    castleCSF_model = CSF_castleCSF();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = castleCSF_model.sensitivity(csf_pars);
end

% function value = S_A_Daly(rho, L_b, area_value, t_frequency)
%     A_Daly_model = CSF_A_Daly();
%     csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
%     value = A_Daly_model.sensitivity(csf_pars);
% end

function value = S_stelaCSF_transient(rho, L_b, area_value, t_frequency)
    stelaCSF_transient_model = CSF_stelaCSF_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelaCSF_transient_model.sensitivity(csf_pars);
end

function value = S_stelaCSF_HF_transient(rho, L_b, area_value, t_frequency)
    stelaCSF_HF_transient_model = CSF_stelaCSF_HF_transient();
    csf_pars = struct('s_frequency', rho, 't_frequency', t_frequency, 'orientation', 0, 'luminance', L_b, 'area', area_value, 'eccentricity', 0);
    value = stelaCSF_HF_transient_model.sensitivity(csf_pars);
end

function fft_D_value = D(rho, r)
    fft_D_value = r * sinc(2*rho*r);
end