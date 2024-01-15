size = 16;
radius = size/2;
area_value = pi*radius^2;
fit_poly_degree = 4;
luminance_value = 5;
vrr_f_contiuous = logspace(log10(0.2),log10(20),100);

stelacsf_model = CSF_stelaCSF();
stelacsf_mod_model = CSF_stelaCSF_mod();
stelacsf_transient_model = CSF_stelaCSF_transient();
stelacsf_mod_transient_model = CSF_stelaCSF_mod_transient();
barten_mod_model = CSF_stmBartenVeridical();

csf_pars = struct('s_frequency', 0.0001, 't_frequency', vrr_f_contiuous', 'orientation', 0, 'luminance', luminance_value, 'area', area_value, 'eccentricity', 0);
stelacsf_result = stelacsf_model.sensitivity(csf_pars);
stelacsf_mod_result = stelacsf_mod_model.sensitivity(csf_pars);
stelacsf_transient_result = stelacsf_transient_model.sensitivity(csf_pars);
stelacsf_mod_transient_result = stelacsf_mod_transient_model.sensitivity(csf_pars);
% barten_mod_result = barten_mod_model.sensitivity(csf_pars);

figure;
plot(vrr_f_contiuous, stelacsf_result, 'DisplayName', 'stelaCSF');
hold on;
plot(vrr_f_contiuous, stelacsf_mod_result, 'DisplayName', 'stelaCSF_{HF}');
% plot(vrr_f_contiuous, barten_mod_result, 'DisplayName', 'BartenCSF_{HF}');
plot(vrr_f_contiuous, stelacsf_transient_result, 'DisplayName', 'stelaCSF transient');
plot(vrr_f_contiuous, stelacsf_mod_transient_result, 'DisplayName', 'stelaCSF_{HF} transient');
xlim([0.1,20]);
xlabel('Temporal Frequency (Hz)');
ylabel('Sensitivity');
title('Spatital Frequency 0.0001 Hz')
legend('show');
